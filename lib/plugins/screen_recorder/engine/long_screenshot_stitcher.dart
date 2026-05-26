import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../../core/engine/ffmpeg_engine.dart';

enum StitchAxis { vertical, horizontal }

class LongScreenshotStitcher {
  static const double _minNccThreshold = 0.2;

  /// Main entry point to stitch a video into a single long screenshot.
  ///
  /// If [direction] is provided, uses that axis directly. Otherwise
  /// auto-detects by comparing NCC scores for both axes.
  ///
  /// Returns a Uint8List containing the PNG bytes of the final stitched image.
  static Future<Uint8List?> stitch(String videoPath,
      {StitchAxis? direction}) async {
    final tempDir = await Directory.systemTemp.createTemp('sqa_stitching_');
    try {
      // Phase 1: Extract frames
      debugPrint('[LongScreenshotStitcher] Extracting frames to ${tempDir.path}...');
      final framePaths = await _extractFrames(videoPath, tempDir.path);
      if (framePaths.isEmpty) {
        debugPrint('[LongScreenshotStitcher] No frames extracted.');
        return null;
      }

      // Phase 2: Compute projections (on main thread to allow dart:ui)
      debugPrint('[LongScreenshotStitcher] Computing projections on main thread...');
      final rowProjections = <Float32List>[];
      final colProjections = <Float32List>[];
      int frameWidth = 0;
      int frameHeight = 0;

      for (int i = 0; i < framePaths.length; i++) {
        final bytes = await File(framePaths[i]).readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        final frameInfo = await codec.getNextFrame();
        final image = frameInfo.image;

        if (i == 0) {
          frameWidth = image.width;
          frameHeight = image.height;
        }

        final rgbaData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        if (rgbaData != null) {
          final rowProj = Float32List(frameHeight);
          final colProj = Float32List(frameWidth);
          final rawBytes = rgbaData.buffer.asUint8List();

          // Single pass: accumulate row and column luminance sums simultaneously
          for (int y = 0; y < frameHeight; y++) {
            double rowSum = 0;
            final rowOffset = y * frameWidth * 4;
            for (int x = 0; x < frameWidth; x++) {
              final idx = rowOffset + (x * 4);
              final gray = 0.2126 * rawBytes[idx] +
                  0.7152 * rawBytes[idx + 1] +
                  0.0722 * rawBytes[idx + 2];
              rowSum += gray;
              colProj[x] += gray;
            }
            rowProj[y] = rowSum / frameWidth;
          }

          // Normalize column projections by frame height
          for (int x = 0; x < frameWidth; x++) {
            colProj[x] /= frameHeight;
          }

          rowProjections.add(rowProj);
          colProjections.add(colProj);
        }
        image.dispose();

        if (i % 5 == 0) {
          await Future<void>.delayed(Duration.zero);
        }
      }

      if (rowProjections.isEmpty) {
        debugPrint('[LongScreenshotStitcher] No projections calculated.');
        return null;
      }

      // Phase 3 & 4: Compute offsets (in isolate, pure math)
      final StitchAxis axis;
      final List<int> offsets;

      if (direction != null) {
        debugPrint('[LongScreenshotStitcher] Using explicit axis: $direction');
        final projections = direction == StitchAxis.vertical
            ? rowProjections
            : colProjections;
        final dim = direction == StitchAxis.vertical ? frameHeight : frameWidth;
        final singleResult = await compute(
            _computeSingleAxisIsolate,
            {'projections': projections, 'frameDimension': dim});
        offsets = singleResult['offsets'] as List<int>;
        axis = direction;
      } else {
        debugPrint('[LongScreenshotStitcher] Computing offsets (dual NCC) in background...');
        final result = await compute(_computeOffsetsIsolate, {
          'rowProjections': rowProjections,
          'colProjections': colProjections,
          'frameWidth': frameWidth,
          'frameHeight': frameHeight,
        });
        offsets = result['offsets'] as List<int>;
        axis = StitchAxis.values[result['axis'] as int];
        debugPrint('[LongScreenshotStitcher] Auto-detected axis: $axis '
            '(${offsets.length} frames, ${offsets.last} px offset)');
      }

      if (offsets.isEmpty) {
        debugPrint('[LongScreenshotStitcher] No offsets calculated.');
        return null;
      }

      // Phase 5: Composite frames onto canvas
      debugPrint('[LongScreenshotStitcher] Compositing frames on main thread...');
      final finalImageBytes = await _compositeFrames(framePaths, offsets, axis: axis);

      debugPrint('[LongScreenshotStitcher] Stitching complete.');
      return finalImageBytes;
    } catch (e, stack) {
      debugPrint('[LongScreenshotStitcher] Error during stitching: $e\n$stack');
      return null;
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  static Future<List<String>> _extractFrames(String videoPath, String outDir) async {
    final executable = await FfmpegEngine.getExecutablePath();
    if (executable == null) throw Exception("FFmpeg not found");

    final outPattern = p.join(outDir, 'frame_%04d.png');

    final result = await Process.run(executable, [
      '-i', videoPath,
      '-vf', 'fps=10',
      outPattern,
    ]);

    if (result.exitCode != 0) {
      debugPrint('[LongScreenshotStitcher] FFmpeg extract failed: ${result.stderr}');
      return [];
    }

    final dir = Directory(outDir);
    final files = dir.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .toList();

    files.sort((a, b) => a.path.compareTo(b.path));

    return files.map((f) => f.path).toList();
  }

  /// Computes 1D global offsets via Normalized Cross-Correlation.
  ///
  /// [projections] is a list of [Float32List], one per frame.
  /// [frameDimension] is the length of each projection (frameHeight for
  /// vertical, frameWidth for horizontal).
  ///
  /// Returns a map with:
  ///   'offsets'  — `List<int>` of global pixel offsets for each frame
  ///   'avgNcc'   — `double`, average NCC score across all matched pairs
  @visibleForTesting
  static Map<String, dynamic> computeOffsets1D(
      List<Float32List> projections, int frameDimension) {
    if (projections.isEmpty) {
      return {'offsets': <int>[], 'avgNcc': 0.0};
    }

    final globalOffsets = <int>[0];
    final canvasProj = List<double>.from(projections[0]);
    double totalNcc = 0.0;
    int pairCount = 0;

    for (int i = 1; i < projections.length; i++) {
      final currentProj = projections[i];
      final canvasHeight = canvasProj.length;

      // Ignore top/bottom 15% to avoid static headers/footers matching
      final margin = (frameDimension * 0.15).toInt();
      final querySize = (frameDimension * 0.25).toInt();

      final queryStart = math.max(0, canvasHeight - margin - querySize);

      final query = canvasProj.sublist(queryStart, queryStart + querySize);

      final minSearchOffset = margin;
      final maxSearchOffset = frameDimension - margin - querySize;

      double bestNcc = -1.0;
      int bestLocalOffset = minSearchOffset;

      // Query statistics
      double queryMean = 0;
      for (final v in query) {
        queryMean += v;
      }
      queryMean /= query.length;

      double queryStd = 0;
      for (final v in query) {
        queryStd += math.pow(v - queryMean, 2);
      }
      queryStd = math.sqrt(queryStd / query.length);
      if (queryStd < 0.001) queryStd = 1.0;

      for (int offset = minSearchOffset; offset <= maxSearchOffset; offset++) {
        double localMean = 0;
        for (int k = 0; k < query.length; k++) {
          localMean += currentProj[offset + k];
        }
        localMean /= query.length;

        double localStd = 0;
        for (int k = 0; k < query.length; k++) {
          localStd += math.pow(currentProj[offset + k] - localMean, 2);
        }
        localStd = math.sqrt(localStd / query.length);
        if (localStd < 0.001) localStd = 1.0;

        double ncc = 0;
        for (int k = 0; k < query.length; k++) {
          ncc += (query[k] - queryMean) * (currentProj[offset + k] - localMean);
        }
        ncc /= (queryStd * localStd * query.length);

        if (ncc > bestNcc) {
          bestNcc = ncc;
          bestLocalOffset = offset;
        }
      }

      totalNcc += bestNcc;
      pairCount++;

      // newFrame[bestLocalOffset] aligns with canvas[queryStart]
      // Therefore newFrame[0] aligns with canvas[queryStart - bestLocalOffset]
      int newGlobalOffset = queryStart - bestLocalOffset;

      // Constrain scroll direction: monotonically increasing offsets
      if (newGlobalOffset < globalOffsets.last) {
        newGlobalOffset = globalOffsets.last;
      }

      globalOffsets.add(newGlobalOffset);

      // Expand the canvas projection with the new non-overlapping content
      final startK = canvasHeight - newGlobalOffset;
      if (startK > 0 && startK < frameDimension) {
        for (int k = startK; k < frameDimension; k++) {
          canvasProj.add(currentProj[k]);
        }
      }
    }

    final avgNcc = pairCount > 0 ? totalNcc / pairCount : 0.0;
    return {'offsets': globalOffsets, 'avgNcc': avgNcc};
  }

  /// Runs in a compute isolate to avoid UI freeze.
  /// Computes NCC offsets for a single axis and returns the offsets.
  static Future<Map<String, dynamic>> _computeSingleAxisIsolate(
      Map<String, dynamic> args) async {
    final List<Float32List> projections =
        args['projections'] as List<Float32List>;
    final int frameDimension = args['frameDimension'] as int;

    final result = computeOffsets1D(projections, frameDimension);
    return {
      'offsets': result['offsets'],
      'axis': StitchAxis.vertical.index, // unused by caller for single axis
    };
  }

  /// Runs in a compute isolate to avoid UI freeze.
  /// Computes NCC offsets for both vertical and horizontal axes, then picks
  /// the winner based on average NCC score.
  static Future<Map<String, dynamic>> _computeOffsetsIsolate(
      Map<String, dynamic> args) async {
    final List<Float32List> rowProjections =
        args['rowProjections'] as List<Float32List>;
    final List<Float32List> colProjections =
        args['colProjections'] as List<Float32List>;
    final int frameWidth = args['frameWidth'] as int;
    final int frameHeight = args['frameHeight'] as int;

    if (rowProjections.isEmpty || colProjections.isEmpty) {
      return {'offsets': <int>[], 'axis': StitchAxis.vertical.index};
    }

    final vertResult = computeOffsets1D(rowProjections, frameHeight);
    final horizResult = computeOffsets1D(colProjections, frameWidth);

    final double vertAvgNcc = vertResult['avgNcc'] as double;
    final double horizAvgNcc = horizResult['avgNcc'] as double;

    final bool horizontalWins =
        horizAvgNcc > vertAvgNcc && horizAvgNcc >= _minNccThreshold;

    StitchAxis winner;
    List<int> offsets;

    if (horizontalWins) {
      winner = StitchAxis.horizontal;
      offsets = horizResult['offsets'] as List<int>;
    } else {
      winner = StitchAxis.vertical;
      offsets = vertResult['offsets'] as List<int>;
    }

    debugPrint('[LongScreenshotStitcher] Auto-detected axis: $winner '
        '(vertical NCC=${vertAvgNcc.toStringAsFixed(3)}, '
        'horizontal NCC=${horizAvgNcc.toStringAsFixed(3)})');

    return {
      'offsets': offsets,
      'axis': winner.index,
    };
  }

  static Future<Uint8List> _compositeFrames(
      List<String> framePaths, List<int> globalOffsets,
      {StitchAxis axis = StitchAxis.vertical}) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final firstFrame = await _loadImage(framePaths[0]);
    final frameWidth = firstFrame.width;
    final frameHeight = firstFrame.height;
    firstFrame.dispose();

    int totalWidth;
    int totalHeight;

    if (axis == StitchAxis.vertical) {
      totalWidth = frameWidth;
      totalHeight = frameHeight;
      if (globalOffsets.length > 1) {
        totalHeight = globalOffsets.last + frameHeight;
      }
    } else {
      totalWidth = frameWidth;
      totalHeight = frameHeight;
      if (globalOffsets.length > 1) {
        totalWidth = globalOffsets.last + frameWidth;
      }
    }

    int currentPos = 0;

    for (int i = 0; i < framePaths.length; i++) {
      final frame = await _loadImage(framePaths[i]);

      if (i == 0) {
        canvas.drawImage(frame, ui.Offset.zero, ui.Paint());
        currentPos = axis == StitchAxis.vertical ? frameHeight : frameWidth;
      } else {
        final gOffset = globalOffsets[i];

        if (axis == StitchAxis.vertical) {
          final newContentStartY = currentPos - gOffset;

          if (newContentStartY < frameHeight) {
            final srcRect = ui.Rect.fromLTWH(
              0, newContentStartY.toDouble(),
              frame.width.toDouble(),
              (frameHeight - newContentStartY).toDouble(),
            );
            final dstRect = ui.Rect.fromLTWH(
              0, currentPos.toDouble(),
              frame.width.toDouble(),
              (frameHeight - newContentStartY).toDouble(),
            );
            canvas.drawImageRect(frame, srcRect, dstRect, ui.Paint());
            currentPos += (frameHeight - newContentStartY);
          }
        } else {
          final newContentStartX = currentPos - gOffset;

          if (newContentStartX < frameWidth) {
            final srcRect = ui.Rect.fromLTWH(
              newContentStartX.toDouble(), 0,
              (frameWidth - newContentStartX).toDouble(),
              frame.height.toDouble(),
            );
            final dstRect = ui.Rect.fromLTWH(
              currentPos.toDouble(), 0,
              (frameWidth - newContentStartX).toDouble(),
              frame.height.toDouble(),
            );
            canvas.drawImageRect(frame, srcRect, dstRect, ui.Paint());
            currentPos += (frameWidth - newContentStartX);
          }
        }
      }
      frame.dispose();
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(totalWidth, totalHeight);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    return bytes!.buffer.asUint8List();
  }

  static Future<ui.Image> _loadImage(String path) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}

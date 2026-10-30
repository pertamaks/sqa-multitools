import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
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
  static Future<Uint8List?> stitch(
    String videoPath, {
    StitchAxis? direction,
  }) async {
    try {
      // Phase 1: Extract frames in-memory via stdout pipe at 20 FPS (prevents temporal gap/drift)
      debugPrint('[LongScreenshotStitcher] Extracting frames in-memory via pipe (20 FPS)...');
      final framesBytes = await _extractFramesInMemory(videoPath);
      if (framesBytes.isEmpty) {
        debugPrint('[LongScreenshotStitcher] No frames extracted.');
        return null;
      }

      // Phase 2: Compute projections (on main thread to allow dart:ui)
      debugPrint(
        '[LongScreenshotStitcher] Computing multi-strip projections on main thread...',
      );
      final rowProjections = <Float32List>[];
      final colProjections = <Float32List>[];
      final filteredFrames = <Uint8List>[];
      int frameWidth = 0;
      int frameHeight = 0;

      for (int i = 0; i < framesBytes.length; i++) {
        final codec = await ui.instantiateImageCodec(framesBytes[i]);
        final frameInfo = await codec.getNextFrame();
        final image = frameInfo.image;

        if (filteredFrames.isEmpty) {
          frameWidth = image.width;
          frameHeight = image.height;
        }

        final rgbaData = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        if (rgbaData != null) {
          final rowProj = Float32List(frameHeight);
          final colProj = Float32List(frameWidth);
          final rawBytes = rgbaData.buffer.asUint8List();

          // Focus on active 20%-80% center region to avoid scrollbars/margins
          final startX = (frameWidth * 0.15).toInt();
          final endX = (frameWidth * 0.85).toInt();
          final activeWidth = math.max(1, endX - startX);

          final startY = (frameHeight * 0.15).toInt();
          final endY = (frameHeight * 0.85).toInt();
          final activeHeight = math.max(1, endY - startY);

          for (int y = 0; y < frameHeight; y++) {
            double rowSum = 0;
            final rowOffset = y * frameWidth * 4;
            for (int x = startX; x < endX; x++) {
              final idx = rowOffset + (x * 4);
              final gray =
                  0.2126 * rawBytes[idx] +
                  0.7152 * rawBytes[idx + 1] +
                  0.0722 * rawBytes[idx + 2];
              rowSum += gray;
            }
            rowProj[y] = rowSum / activeWidth;
          }

          for (int x = 0; x < frameWidth; x++) {
            double colSum = 0;
            for (int y = startY; y < endY; y++) {
              final idx = (y * frameWidth + x) * 4;
              final gray =
                  0.2126 * rawBytes[idx] +
                  0.7152 * rawBytes[idx + 1] +
                  0.0722 * rawBytes[idx + 2];
              colSum += gray;
            }
            colProj[x] = colSum / activeHeight;
          }

          // Duplicate detection against previous frame
          bool isDuplicate = false;
          if (rowProjections.isNotEmpty) {
            final prevRow = rowProjections.last;
            double diff = 0;
            for (int k = 0; k < frameHeight; k += 4) {
              diff += (rowProj[k] - prevRow[k]).abs();
            }
            final avgDiff = diff / (frameHeight / 4);
            if (avgDiff < 0.5) {
              isDuplicate = true;
            }
          }

          if (!isDuplicate || filteredFrames.isEmpty) {
            rowProjections.add(rowProj);
            colProjections.add(colProj);
            filteredFrames.add(framesBytes[i]);
          }
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

      debugPrint(
        '[LongScreenshotStitcher] Processed ${filteredFrames.length} unique frames out of ${framesBytes.length}.',
      );

      // Phase 3 & 4: Compute offsets (in isolate, pure math)
      final StitchAxis axis;
      final List<int> offsets;

      if (direction != null) {
        debugPrint('[LongScreenshotStitcher] Using explicit axis: $direction');
        final projections = direction == StitchAxis.vertical
            ? rowProjections
            : colProjections;
        final dim = direction == StitchAxis.vertical ? frameHeight : frameWidth;
        final singleResult = await compute(_computeSingleAxisIsolate, {
          'projections': projections,
          'frameDimension': dim,
        });
        offsets = singleResult['offsets'] as List<int>;
        axis = direction;
      } else {
        debugPrint(
          '[LongScreenshotStitcher] Computing offsets (dual NCC) in background...',
        );
        final result = await compute(_computeOffsetsIsolate, {
          'rowProjections': rowProjections,
          'colProjections': colProjections,
          'frameWidth': frameWidth,
          'frameHeight': frameHeight,
        });
        offsets = result['offsets'] as List<int>;
        axis = StitchAxis.values[result['axis'] as int];
        debugPrint(
          '[LongScreenshotStitcher] Auto-detected axis: $axis '
          '(${offsets.length} frames, ${offsets.last} px offset)',
        );
      }

      if (offsets.isEmpty) {
        debugPrint('[LongScreenshotStitcher] No offsets calculated.');
        return null;
      }

      // Phase 5: Composite frames onto canvas
      debugPrint(
        '[LongScreenshotStitcher] Compositing frames on main thread...',
      );
      final finalImageBytes = await _compositeFrames(
        filteredFrames,
        offsets,
        axis: axis,
      );

      debugPrint('[LongScreenshotStitcher] Stitching complete.');
      return finalImageBytes;
    } catch (e, stack) {
      debugPrint('[LongScreenshotStitcher] Error during stitching: $e\n$stack');
      return null;
    }
  }

  /// Extracts video frames as PNG bytes directly into memory via FFmpeg stdout pipe.
  /// Avoids writing and deleting hundreds of image files to disk.
  static Future<List<Uint8List>> _extractFramesInMemory(String videoPath) async {
    final executable = await FfmpegEngine.getExecutablePath();
    if (executable == null) throw Exception("FFmpeg not found");

    final process = await Process.start(executable, [
      '-i',
      videoPath,
      '-vf',
      'fps=20',
      '-f',
      'image2pipe',
      '-vcodec',
      'png',
      'pipe:1',
    ]);

    final List<int> accumulatedBytes = [];
    final List<Uint8List> frames = [];

    // PNG standard header: 89 50 4E 47 0D 0A 1A 0A
    final pngHeader = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
    // PNG IEND chunk trailer: 49 45 4E 44 AE 42 60 82 (IEND + 4-byte CRC)
    final pngIend = [0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82];

    final stdoutFuture = process.stdout.forEach((chunk) {
      accumulatedBytes.addAll(chunk);

      // Extract complete PNG frames from buffer as they arrive
      while (accumulatedBytes.isNotEmpty) {
        final startIdx = _indexOfSubsequence(accumulatedBytes, pngHeader);
        if (startIdx == -1) {
          accumulatedBytes.clear();
          break;
        }

        final endIdx = _indexOfSubsequence(
          accumulatedBytes,
          pngIend,
          startIndex: startIdx + pngHeader.length,
        );
        if (endIdx == -1) {
          // Frame not yet complete; wait for more data
          if (startIdx > 0) {
            accumulatedBytes.removeRange(0, startIdx);
          }
          break;
        }

        final frameLength = (endIdx + pngIend.length) - startIdx;
        final frameBytes = Uint8List.fromList(
          accumulatedBytes.sublist(startIdx, startIdx + frameLength),
        );
        frames.add(frameBytes);

        accumulatedBytes.removeRange(0, startIdx + frameLength);
      }
    });

    final stderrFuture = process.stderr.drain<void>();

    await Future.wait([stdoutFuture, stderrFuture]);
    final exitCode = await process.exitCode;

    if (exitCode != 0 && frames.isEmpty) {
      debugPrint('[LongScreenshotStitcher] FFmpeg in-memory extract failed with code $exitCode');
      return [];
    }

    return frames;
  }

  static int _indexOfSubsequence(
    List<int> source,
    List<int> target, {
    int startIndex = 0,
  }) {
    if (target.isEmpty) return startIndex;
    if (source.length - startIndex < target.length) return -1;

    for (int i = startIndex; i <= source.length - target.length; i++) {
      bool match = true;
      for (int j = 0; j < target.length; j++) {
        if (source[i + j] != target[j]) {
          match = false;
          break;
        }
      }
      if (match) return i;
    }
    return -1;
  }

  /// Computes 1D global offsets via Sequential Pairwise Normalized Cross-Correlation (Anti-Drift).
  ///
  /// Matches Frame[i] against Frame[i-1] directly, then accumulates verified deltas.
  /// Returns a map with:
  ///   'offsets'  — `List<int>` of global pixel offsets for each frame
  ///   'avgNcc'   — `double`, average NCC score across all matched pairs
  @visibleForTesting
  static Map<String, dynamic> computeOffsets1D(
    List<Float32List> projections,
    int frameDimension,
  ) {
    if (projections.isEmpty) {
      return {'offsets': <int>[], 'avgNcc': 0.0};
    }

    final globalOffsets = <int>[0];
    int cumulativeOffset = 0;
    double totalNcc = 0.0;
    int pairCount = 0;

    // Minimum template size to match (30% of frame dimension)
    final templateSize = math.max(10, (frameDimension * 0.35).toInt());
    // Margin to avoid sticky headers or footers
    final topMargin = (frameDimension * 0.10).toInt();
    final bottomMargin = (frameDimension * 0.10).toInt();

    for (int i = 1; i < projections.length; i++) {
      final prevProj = projections[i - 1];
      final currProj = projections[i];

      // Template taken from the lower section of prevProj
      final templateStart = math.max(0, frameDimension - bottomMargin - templateSize);
      final template = prevProj.sublist(templateStart, templateStart + templateSize);

      // Search template inside currProj (from topMargin down to bottomMargin)
      final minSearch = topMargin;
      final maxSearch = frameDimension - bottomMargin - templateSize;

      double bestNcc = -1.0;
      int bestOffset = templateStart;

      // Calculate template statistics
      double tMean = 0;
      for (final v in template) {
        tMean += v;
      }
      tMean /= template.length;

      double tStd = 0;
      for (final v in template) {
        tStd += math.pow(v - tMean, 2);
      }
      tStd = math.sqrt(tStd / template.length);
      if (tStd < 0.001) tStd = 1.0;

      for (int offset = minSearch; offset <= maxSearch; offset++) {
        double cMean = 0;
        for (int k = 0; k < templateSize; k++) {
          cMean += currProj[offset + k];
        }
        cMean /= templateSize;

        double cStd = 0;
        for (int k = 0; k < templateSize; k++) {
          cStd += math.pow(currProj[offset + k] - cMean, 2);
        }
        cStd = math.sqrt(cStd / templateSize);
        if (cStd < 0.001) cStd = 1.0;

        double ncc = 0;
        for (int k = 0; k < templateSize; k++) {
          ncc += (template[k] - tMean) * (currProj[offset + k] - cMean);
        }
        ncc /= (tStd * cStd * templateSize);

        if (ncc > bestNcc) {
          bestNcc = ncc;
          bestOffset = offset;
        }
      }

      totalNcc += math.max(0.0, bestNcc);
      pairCount++;

      // Shift delta between consecutive frames:
      // prev[templateStart] aligned with curr[bestOffset] => delta = templateStart - bestOffset
      int delta = templateStart - bestOffset;

      // In downward/forward scroll, delta must be >= 0
      if (delta < 0 || bestNcc < _minNccThreshold) {
        delta = 0;
      }

      cumulativeOffset += delta;
      globalOffsets.add(cumulativeOffset);
    }

    final avgNcc = pairCount > 0 ? totalNcc / pairCount : 0.0;
    return {'offsets': globalOffsets, 'avgNcc': avgNcc};
  }

  /// Runs in a compute isolate to avoid UI freeze.
  /// Computes NCC offsets for a single axis and returns the offsets.
  static Future<Map<String, dynamic>> _computeSingleAxisIsolate(
    Map<String, dynamic> args,
  ) async {
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
    Map<String, dynamic> args,
  ) async {
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

    debugPrint(
      '[LongScreenshotStitcher] Auto-detected axis: $winner '
      '(vertical NCC=${vertAvgNcc.toStringAsFixed(3)}, '
      'horizontal NCC=${horizAvgNcc.toStringAsFixed(3)})',
    );

    return {'offsets': offsets, 'axis': winner.index};
  }

  static Future<Uint8List> _compositeFrames(
    List<Uint8List> framesBytes,
    List<int> globalOffsets, {
    StitchAxis axis = StitchAxis.vertical,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    final firstFrame = await _loadImage(framesBytes[0]);
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

    for (int i = 0; i < framesBytes.length; i++) {
      final frame = await _loadImage(framesBytes[i]);

      if (i == 0) {
        canvas.drawImage(frame, ui.Offset.zero, ui.Paint());
        currentPos = axis == StitchAxis.vertical ? frameHeight : frameWidth;
      } else {
        final gOffset = globalOffsets[i];

        if (axis == StitchAxis.vertical) {
          final newContentStartY = currentPos - gOffset;

          if (newContentStartY < frameHeight) {
            final srcRect = ui.Rect.fromLTWH(
              0,
              newContentStartY.toDouble(),
              frame.width.toDouble(),
              (frameHeight - newContentStartY).toDouble(),
            );
            final dstRect = ui.Rect.fromLTWH(
              0,
              currentPos.toDouble(),
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
              newContentStartX.toDouble(),
              0,
              (frameWidth - newContentStartX).toDouble(),
              frame.height.toDouble(),
            );
            final dstRect = ui.Rect.fromLTWH(
              currentPos.toDouble(),
              0,
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

  static Future<ui.Image> _loadImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}

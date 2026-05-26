import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../../../core/engine/ffmpeg_engine.dart';

class LongScreenshotStitcher {
  /// Main entry point to stitch a video into a single long screenshot.
  /// Returns a Uint8List containing the PNG bytes of the final stitched image.
  static Future<Uint8List?> stitch(String videoPath) async {
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
      final projections = <Float32List>[];
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
          final proj = Float32List(frameHeight);
          final rawBytes = rgbaData.buffer.asUint8List();

          for (int y = 0; y < frameHeight; y++) {
            double rowSum = 0;
            final rowOffset = y * frameWidth * 4;
            for (int x = 0; x < frameWidth; x++) {
              final idx = rowOffset + (x * 4);
              final r = rawBytes[idx];
              final g = rawBytes[idx + 1];
              final b = rawBytes[idx + 2];
              // Grayscale luminance
              final gray = 0.2126 * r + 0.7152 * g + 0.0722 * b;
              rowSum += gray;
            }
            proj[y] = rowSum / frameWidth;
          }
          projections.add(proj);
        }
        image.dispose();
        
        // Yield to event loop every few frames to prevent UI freeze
        if (i % 5 == 0) {
          await Future.delayed(Duration.zero);
        }
      }

      if (projections.isEmpty) {
        debugPrint('[LongScreenshotStitcher] No projections calculated.');
        return null;
      }

      // Phase 3 & 4: Compute offsets (in isolate, pure math)
      debugPrint('[LongScreenshotStitcher] Computing offsets (NCC) in background...');
      final offsets = await compute(_computeOffsetsIsolate, {
        'projections': projections,
        'frameHeight': frameHeight,
      });

      if (offsets.isEmpty) {
        debugPrint('[LongScreenshotStitcher] No offsets calculated.');
        return null;
      }

      // Phase 5: Composite frames onto canvas
      debugPrint('[LongScreenshotStitcher] Compositing frames on main thread...');
      final finalImageBytes = await _compositeFrames(framePaths, offsets);
      
      debugPrint('[LongScreenshotStitcher] Stitching complete.');
      return finalImageBytes;
    } catch (e, stack) {
      debugPrint('[LongScreenshotStitcher] Error during stitching: $e\n$stack');
      return null;
    } finally {
      // Cleanup
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  static Future<List<String>> _extractFrames(String videoPath, String outDir) async {
    // Extract at 10 fps to match recording framerate and reduce computation.
    // ffmpeg -i input.mp4 -vf "fps=10" outDir/frame_%04d.png
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
    
    // Sort alphabetically (frame_0001, frame_0002, etc.)
    files.sort((a, b) => a.path.compareTo(b.path));
    
    return files.map((f) => f.path).toList();
  }

  /// This runs in a compute isolate to avoid UI freeze.
  /// Expects a map with 'projections': List<Float32List> and 'frameHeight': int
  static Future<List<int>> _computeOffsetsIsolate(Map<String, dynamic> args) async {
    final List<Float32List> projections = args['projections'];
    final int frameHeight = args['frameHeight'];
    
    if (projections.isEmpty) return [];

    // Phase 3 & 4: Global Canvas Alignment Offset Computation
    // We compute the offset of each frame relative to the FIRST frame (global offset)
    // To avoid accumulated drift, we stitch against the previously placed frames (in projection space).
    
    // globalOffsets[i] = pixel Y coordinate where frame i starts on the global canvas
    final List<int> globalOffsets = [0]; 
    
    // A projection of the stitched canvas so far
    List<double> canvasProj = List.from(projections[0]);

    for (int i = 1; i < projections.length; i++) {
      final currentProj = projections[i];
      final canvasHeight = canvasProj.length;
      
      // Ignore top 15% and bottom 15% to avoid static headers/footers matching
      final topMargin = (frameHeight * 0.15).toInt();
      final bottomMargin = (frameHeight * 0.15).toInt();
      
      // Query height is 25% of frame height
      final queryHeight = (frameHeight * 0.25).toInt();
      
      // We take a query strip from the bottom of the safe zone of the current canvas.
      // The canvas ends with the previous frame, so its safe zone ends at canvasHeight - bottomMargin.
      final queryStart = math.max(0, canvasHeight - bottomMargin - queryHeight);
      
      final query = canvasProj.sublist(queryStart, queryStart + queryHeight);
      
      // We slide this query across the safe zone of the new frame.
      final minSearchOffset = topMargin;
      final maxSearchOffset = frameHeight - bottomMargin - queryHeight;
      
      double bestNcc = -1.0;
      int bestLocalOffset = minSearchOffset; // offset inside the new frame where query matches
      
      // Calculate query stats
      double queryMean = 0;
      for (final v in query) queryMean += v;
      queryMean /= query.length;
      
      double queryStd = 0;
      for (final v in query) queryStd += math.pow(v - queryMean, 2);
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

      // newFrame[bestLocalOffset] aligns with canvas[queryStart]
      // Therefore newFrame[0] aligns with canvas[queryStart - bestLocalOffset]
      int newGlobalOffset = queryStart - bestLocalOffset;
      
      // Constrain scroll direction: we assume downward scrolling, so global offset should not decrease
      if (newGlobalOffset < globalOffsets.last) {
        newGlobalOffset = globalOffsets.last;
      }
      
      globalOffsets.add(newGlobalOffset);
      
      // Expand the canvas projection with the new non-overlapping content
      final startK = canvasHeight - newGlobalOffset;
      if (startK > 0 && startK < frameHeight) {
        for (int k = startK; k < frameHeight; k++) {
          canvasProj.add(currentProj[k]);
        }
      }
    }
    
    return globalOffsets;
  }

  static Future<Uint8List> _compositeFrames(List<String> framePaths, List<int> globalOffsets) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // Calculate total height needed
    final firstFrame = await _loadImage(framePaths[0]);
    final frameWidth = firstFrame.width;
    final frameHeight = firstFrame.height;
    firstFrame.dispose();

    int totalHeight = frameHeight;
    if (globalOffsets.length > 1) {
      final lastOffset = globalOffsets.last;
      totalHeight = lastOffset + frameHeight;
    }

    int currentY = 0;

    for (int i = 0; i < framePaths.length; i++) {
      final frame = await _loadImage(framePaths[i]);
      
      if (i == 0) {
        canvas.drawImage(frame, ui.Offset.zero, ui.Paint());
        currentY = frameHeight;
      } else {
        final gOffset = globalOffsets[i];
        // The overlapping part is from globalY=gOffset to globalY=currentY
        // So the new content starts at local Y = currentY - gOffset
        final newContentStartY = currentY - gOffset;
        
        if (newContentStartY < frameHeight) {
          final srcRect = ui.Rect.fromLTWH(
            0, newContentStartY.toDouble(), 
            frame.width.toDouble(), 
            (frameHeight - newContentStartY).toDouble()
          );
          final dstRect = ui.Rect.fromLTWH(
            0, currentY.toDouble(), 
            frame.width.toDouble(), 
            (frameHeight - newContentStartY).toDouble()
          );
          
          canvas.drawImageRect(frame, srcRect, dstRect, ui.Paint());
          currentY += (frameHeight - newContentStartY);
        }
      }
      frame.dispose();
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(frameWidth, totalHeight);
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

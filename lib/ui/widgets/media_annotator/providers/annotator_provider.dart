import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import '../../../../core/models/annotation.dart';
import '../../../../core/models/screenshot_tool.dart';
import '../../../../core/engine/ffmpeg_engine.dart';
import '../../../../core/services/logging_service.dart';
import '../models/annotator_state.dart';
import '../../../../main.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'annotator_provider.g.dart';

@riverpod
class AnnotatorNotifier extends _$AnnotatorNotifier {
  @override
  AnnotatorState build({required String filePath, required String format}) {
    return AnnotatorState(filePath: filePath, format: format);
  }

  void setTool(ScreenshotTool tool) => state = state.copyWith(currentTool: tool);
  void setColor(Color color) => state = state.copyWith(annotationColor: color);
  void setTextHasBackground(bool hasBg) => state = state.copyWith(textHasBackground: hasBg);
  void addAnnotation(Annotation ann) {
    final list = state.annotations.toList();
    list.add(ann);
    state = state.copyWith(annotations: list);
  }
  void updateLastAnnotation(Annotation ann) {
    if (state.annotations.isEmpty) return;
    final list = state.annotations.toList();
    list[list.length - 1] = ann;
    state = state.copyWith(annotations: list);
  }
  void removeAnnotation(Annotation ann) => state = state.copyWith(
    annotations: state.annotations.where((a) => a != ann).toList(),
  );
  void clearAnnotations() => state = state.copyWith(annotations: []);

  Future<void> save(GlobalKey boundaryKey, {required bool isVideo}) async {
    state = state.copyWith(isProcessing: true);
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      // Calculate a dynamic pixelRatio to guarantee at least a 2K resolution export.
      // This prevents the annotations from looking pixelated when upscaled by FFmpeg.
      final double logicalWidth = boundary.size.width;
      final double pixelRatio = (2560.0 / logicalWidth).clamp(1.0, 4.0);

      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final dir = p.dirname(state.filePath);
      final base = p.basenameWithoutExtension(state.filePath);
      final ext = p.extension(state.filePath);
      final outputPath = p.join(dir, '${base}_annotated$ext');
      
      // Fire background task so the annotator window can close immediately
      _processSaveInBackground(pngBytes, state.filePath, outputPath, isVideo);
      
    } catch (e) {
      ref.read(loggingServiceProvider.notifier).logError('Media annotator failed to save: $e');
    }
    // We intentionally DO NOT set isProcessing=false here, because the save method 
    // finishes immediately, and the background task handles its own global state.
  }

  Future<void> _processSaveInBackground(Uint8List pngBytes, String inputPath, String outputPath, bool isVideo) async {
    // Show the global blur loading indicator over the main app
    globalProviderContainer.read(globalProcessingProvider.notifier).setProcessing(true);

    try {
      final tempPngPath = p.join(p.dirname(inputPath), '${p.basenameWithoutExtension(inputPath)}_temp_overlay.png');
      await File(tempPngPath).writeAsBytes(pngBytes);

      final exe = await FfmpegEngine.getExecutablePath();
      if (exe != null) {
        ProcessResult result;
        if (isVideo) {
          result = await Process.run(exe, [
            '-y',
            '-i', state.filePath,
            '-i', tempPngPath,
            '-filter_complex', '[1:v][0:v]scale2ref[ovrl][main];[main][ovrl]overlay=0:0',
            '-c:a', 'copy',
            outputPath
          ]);
        } else {
          result = await Process.run(exe, [
            '-y',
            '-i', state.filePath,
            '-i', tempPngPath,
            '-filter_complex', '[1:v][0:v]scale2ref[ovrl][main];[main][ovrl]overlay=0:0',
            outputPath
          ]);
        }
        
        if (result.exitCode != 0) {
          globalProviderContainer.read(loggingServiceProvider.notifier).logError('Media annotator FFmpeg failed: ${result.stderr}');
        }
      }
      
      await File(tempPngPath).delete();
    } catch (e) {
      globalProviderContainer.read(loggingServiceProvider.notifier).logError('Media annotator background process failed: $e');
    } finally {
      // Hide the global blur loading indicator
      globalProviderContainer.read(globalProcessingProvider.notifier).setProcessing(false);
    }
  }
}

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
import '../models/annotator_state.dart';

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

      final ui.Image image = await boundary.toImage(pixelRatio: 1.0); // We assume pixelRatio 1.0 for output, but maybe need to scale? We'll capture exactly the video dimensions.
      // Actually, if it's a video, the boundary only wraps the AnnotationCanvas, not the video (to be safe).
      // Wait, we can just extract the AnnotationCanvas to PNG, and run ffmpeg!
      
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final dir = p.dirname(state.filePath);
      final base = p.basenameWithoutExtension(state.filePath);
      final ext = p.extension(state.filePath);
      final outputPath = p.join(dir, '${base}_annotated$ext');
      
      final tempPngPath = p.join(dir, '${base}_temp_overlay.png');
      await File(tempPngPath).writeAsBytes(pngBytes);

      final exe = await FfmpegEngine.getExecutablePath();
      if (exe != null) {
        if (isVideo) {
          await Process.run(exe, [
            '-y',
            '-i', state.filePath,
            '-i', tempPngPath,
            '-filter_complex', '[1:v]scale=iw:ih[ovrl];[0:v][ovrl]overlay=0:0',
            '-c:a', 'copy',
            outputPath
          ]);
        } else {
          await Process.run(exe, [
            '-y',
            '-i', state.filePath,
            '-i', tempPngPath,
            '-filter_complex', '[1:v]scale=iw:ih[ovrl];[0:v][ovrl]overlay=0:0',
            outputPath
          ]);
        }
      }
      
      await File(tempPngPath).delete();
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }
}

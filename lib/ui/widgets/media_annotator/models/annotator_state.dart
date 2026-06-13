import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/models/annotation.dart';
import '../../../../core/models/screenshot_tool.dart';

part 'annotator_state.freezed.dart';

@freezed
abstract class AnnotatorState with _$AnnotatorState {
  const factory AnnotatorState({
    required String filePath,
    required String format,
    @Default(ScreenshotTool.pointer) ScreenshotTool currentTool,
    @Default(Colors.red) Color annotationColor,
    @Default([]) List<Annotation> annotations,
    @Default(false) bool isProcessing,
    @Default(false) bool textHasBackground,
  }) = _AnnotatorState;
}

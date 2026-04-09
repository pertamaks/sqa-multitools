import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart' show Color, Colors, Rect;
import 'capture_mode.dart';
import 'screenshot_tool.dart';
import 'annotation.dart';

part 'screenshot_state.freezed.dart';

@freezed
abstract class ScreenshotState with _$ScreenshotState {
  const factory ScreenshotState({
    @Default(CaptureMode.area) CaptureMode captureMode,
    @Default('PNG') String format,
    @Default(0) int delaySeconds,
    @Default(true) bool includeCursor,
    @Default(false) bool isCapturing,
    @Default(ScreenshotTool.pen) ScreenshotTool currentTool,
    @Default(Colors.red) Color annotationColor,
    @Default(false) bool isOverlayVisible,
    @Default(null) Rect? selectionRect,
    @Default([]) List<Annotation> annotations,
  }) = _ScreenshotState;
}

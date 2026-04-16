import 'package:flutter/material.dart' show Color, Colors, Rect;
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/screenshot_tool.dart';
import '../../../core/models/annotation.dart';

part 'screenshot_state.freezed.dart';

@freezed
abstract class ScreenshotState with _$ScreenshotState {
  const factory ScreenshotState({
    @Default(CaptureMode.area) CaptureMode captureMode,
    @Default('PNG') String format,
    @Default(0) int delaySeconds,
    @Default(true) bool includeCursor,
    @Default(false) bool isCapturing,
    @Default(ScreenshotTool.pointer) ScreenshotTool currentTool,
    @Default(Colors.red) Color annotationColor,
    @Default(false) bool isOverlayVisible,
    @Default(null) Rect? selectionRect,
    @Default([]) List<Annotation> annotations,
    @Default(false) bool isTargetingWindow,
    Rect? targetedWindowRect,
    String? targetWindowName,
  }) = _ScreenshotState;
}

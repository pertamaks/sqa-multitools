import 'dart:io';
import 'package:flutter/material.dart' show Color, Colors, Rect, Size, Offset;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/screenshot_tool.dart';
import '../../../core/models/annotation.dart';

part 'screenshot_state.freezed.dart';

@freezed
abstract class ScreenshotState with _$ScreenshotState {
  const factory ScreenshotState({
    @Default(CaptureMode.area) CaptureMode captureMode,
    @Default('PNG') String format,
    @Default(false) bool isCapturing,
    @Default(ScreenshotTool.pointer) ScreenshotTool currentTool,
    @Default(Colors.red) Color annotationColor,
    @Default(false) bool isOverlayVisible,
    @Default(null) Rect? selectionRect,
    @Default([]) List<Annotation> annotations,
    @Default(false) bool isTargetingWindow,
    Rect? targetedWindowRect,
    String? targetWindowName,
    int? targetedWindowHwnd,
    String? saveDirectory,
    Size? previousWindowSize,
    Offset? previousWindowPos,
    @Default([]) List<Display> availableDisplays,
    @Default([]) List<CaptureInfo> recentCaptures,
    Display? lockedDisplay,
  }) = _ScreenshotState;
}

@freezed
abstract class CaptureInfo with _$CaptureInfo {
  const factory CaptureInfo({
    required File file,
    required int size,
    required DateTime modified,
  }) = _CaptureInfo;
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'capture_mode.dart';
import '../../screenshot/models/annotation.dart';
import '../../screenshot/models/screenshot_tool.dart';

part 'screen_recorder_state.freezed.dart';

@freezed
abstract class ScreenRecorderState with _$ScreenRecorderState {
  const factory ScreenRecorderState({
    @Default(false) bool isRecording,
    @Default(false) bool isPaused,
    @Default(0) int durationSeconds,
    @Default(true) bool microphoneEnabled,
    @Default(true) bool systemAudioEnabled,
    @Default(true) bool showCursor,
    @Default('1080p') String resolution,
    @Default('MP4') String format,
    @Default(CaptureMode.fullScreen) CaptureMode captureMode,
    @Default('Active Window') String targetWindowName,
    @Default(false) bool isOverlayVisible,
    @Default([]) List<Annotation> annotations,
    @Default(ScreenshotTool.pen) ScreenshotTool currentTool,
    @Default(Colors.red) Color annotationColor,
    @Default(0) int delaySeconds,
    Rect? selectionRect,
  }) = _ScreenRecorderState;
}

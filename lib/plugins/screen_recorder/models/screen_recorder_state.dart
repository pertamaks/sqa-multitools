import 'dart:io';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/annotation.dart';
import '../../../core/models/screenshot_tool.dart';

import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

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
    @Default(false) bool isTargetingWindow,
    Rect? targetedWindowRect,
    int? targetedWindowHwnd,
    @Default([]) List<String> availableAudioDevices,
    String? selectedAudioDevice,
    @Default(Colors.white) Color clickFeedbackColor,
    @Default(Colors.amber) Color rightClickFeedbackColor,
    @Default([]) List<Annotation> annotations,
    @Default(ScreenshotTool.pointer) ScreenshotTool currentTool,
    @Default(Colors.red) Color annotationColor,
    @Default(0) int delaySeconds,
    @Default(0) int countdownSeconds, // Live countdown before recording starts
    @Default(30) int framerate,
    String? saveDirectory,
    Size? previousWindowSize,
    Offset? previousWindowPos,
    Rect? selectionRect,
    Rect? captureRect,
    @Default([]) List<Display> availableDisplays,
    @Default({}) Map<String, String> monitorNames, // id -> friendlyName
    @Default({}) Map<String, String> displayThumbnails, // id -> filePath
    String? primaryDisplayId,
    @Default([]) List<RecordingInfo> recentRecordings,
    Display? lockedDisplay,
    @Default(false) bool textHasBackground,
    @JsonKey(includeFromJson: false, includeToJson: false)
    HotKey? registeredHotKey,
  }) = _ScreenRecorderState;
}

@freezed
abstract class RecordingInfo with _$RecordingInfo {
  const factory RecordingInfo({
    required File file,
    required int size,
    required DateTime modified,
  }) = _RecordingInfo;
}

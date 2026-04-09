import 'dart:async';
import 'package:flutter/material.dart' show Color, Rect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/screen_recorder_state.dart';
import '../models/capture_mode.dart';
import '../../screenshot/models/annotation.dart';
import '../../screenshot/models/screenshot_tool.dart';

part 'screen_recorder_provider.g.dart';

@riverpod
class ScreenRecorderNotifier extends _$ScreenRecorderNotifier {
  Timer? _timer;

  @override
  ScreenRecorderState build() {
    ref.onDispose(() => _timer?.cancel());
    return const ScreenRecorderState();
  }

  void toggleRecording() {
    if (state.isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    state = state.copyWith(
      isRecording: true,
      isPaused: false,
      durationSeconds: 0,
      isOverlayVisible: true,
      annotations: [],
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused) {
        state = state.copyWith(durationSeconds: state.durationSeconds + 1);
      }
    });
  }

  void _stopRecording() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(
      isRecording: false,
      isPaused: false,
      isOverlayVisible: false,
      annotations: [],
    );
  }

  void togglePause() {
    if (state.isRecording) {
      state = state.copyWith(isPaused: !state.isPaused);
    }
  }

  void setMicrophone(bool value) =>
      state = state.copyWith(microphoneEnabled: value);
  void setSystemAudio(bool value) =>
      state = state.copyWith(systemAudioEnabled: value);
  void setShowCursor(bool value) => state = state.copyWith(showCursor: value);
  void setResolution(String value) => state = state.copyWith(resolution: value);
  void setFormat(String value) => state = state.copyWith(format: value);
  void setDelay(int value) => state = state.copyWith(delaySeconds: value);

  void setCaptureMode(CaptureMode mode) =>
      state = state.copyWith(captureMode: mode);
  void setTargetWindow(String name) =>
      state = state.copyWith(targetWindowName: name);

  // Overlay & Annotation Methods
  void setOverlayVisible(bool visible) {
    state = state.copyWith(isOverlayVisible: visible);
  }

  void setSelection(Rect? rect) {
    state = state.copyWith(selectionRect: rect);
  }

  void addAnnotation(Annotation annotation) {
    state = state.copyWith(annotations: [...state.annotations, annotation]);
  }

  void updateLastAnnotation(Annotation annotation) {
    if (state.annotations.isEmpty) return;
    final updated = [
      ...state.annotations.sublist(0, state.annotations.length - 1),
      annotation,
    ];
    state = state.copyWith(annotations: updated);
  }

  void clearAnnotations() {
    state = state.copyWith(annotations: []);
  }

  void setTool(ScreenshotTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setColor(Color color) {
    state = state.copyWith(annotationColor: color);
  }

  void startAreaSelection() {
    state = state.copyWith(
      isOverlayVisible: true,
      selectionRect: null,
      captureMode: CaptureMode.area,
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart' show Color, Rect;
import '../models/screenshot_state.dart';
import '../models/capture_mode.dart';
import '../models/screenshot_tool.dart';
import '../models/annotation.dart';

part 'screenshot_provider.g.dart';

@riverpod
class ScreenshotNotifier extends _$ScreenshotNotifier {
  @override
  ScreenshotState build() {
    return const ScreenshotState();
  }

  void setCaptureMode(CaptureMode mode) {
    state = state.copyWith(captureMode: mode);
  }

  void setFormat(String format) {
    state = state.copyWith(format: format);
  }

  void setDelay(int seconds) {
    state = state.copyWith(delaySeconds: seconds);
  }

  void toggleIncludeCursor(bool value) {
    state = state.copyWith(includeCursor: value);
  }

  void setTool(ScreenshotTool tool) {
    state = state.copyWith(currentTool: tool);
  }

  void setColor(Color color) {
    state = state.copyWith(annotationColor: color);
  }

  void startCapture() {
    state = state.copyWith(
      isOverlayVisible: true,
      annotations: [],
      selectionRect: null,
    );
  }

  void stopCapture() {
    state = state.copyWith(isOverlayVisible: false);
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

  Future<void> finalize({bool shouldCopy = false}) async {
    state = state.copyWith(isCapturing: true);

    // Mock processing delay
    await Future<void>.delayed(const Duration(milliseconds: 800));

    if (ref.mounted) {
      state = state.copyWith(isCapturing: false, isOverlayVisible: false);
    }
  }

  Future<void> capture() async {
    startCapture();
  }
}

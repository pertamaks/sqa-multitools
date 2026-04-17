import 'package:flutter/material.dart';
import 'screenshot_tool.dart';
import 'annotation.dart';
import 'capture_mode.dart';
import 'package:screen_retriever/screen_retriever.dart';

abstract class CaptureOverlayDelegate {
  // --- Shared State Reads ---
  bool get isOverlayVisible;
  bool get isTargetingWindow;
  CaptureMode get captureMode;
  Rect? get selectionRect;
  Rect? get targetedWindowRect;
  String? get targetWindowName;
  List<Annotation> get annotations;
  Color get annotationColor;
  ScreenshotTool get currentTool;
  List<Display> get availableDisplays;

  // --- Recording State Reads (defaults for non-recording plugins) ---
  bool get isRecording => false;
  bool get isPaused => false;
  int get durationSeconds => 0;
  int get countdownSeconds => 0;
  bool get isCapturing => false; // Screenshot "processing" flag

  // --- Feature Flags (Config) ---
  bool get enableClickFeedback => false;
  bool get enableMousePassthrough => false;
  Color get clickFeedbackColor => Colors.white;
  Color get rightClickFeedbackColor => Colors.amber;

  // --- Shared Mutations ---
  void setSelection(Rect? rect);
  void addAnnotation(Annotation annotation);
  void updateLastAnnotation(Annotation annotation);
  void updateTargetedWindow(Rect? rect, String? name, [int? hwnd]);
  void confirmTargetWindow(Rect rect, String title);

  // --- Recording Mutations (no-op defaults for Screenshot) ---
  Future<void> setIgnoreMouseEvents(bool ignore) async {}
  Future<void> cancelOverlay() async {}
}

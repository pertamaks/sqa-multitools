import 'package:flutter/material.dart';
import 'window_native_api.dart';

/// A no-op implementation of [WindowNativeApi] used as a fallback on
/// unsupported platforms or during testing.
class WindowNativeApiStub implements WindowNativeApi {
  const WindowNativeApiStub();

  @override
  bool get supportsGlobalMousePolling => false;

  @override
  WindowInfo? getWindowInfoAt() => null;

  @override
  Offset getAppWindowPosition() => Offset.zero;

  @override
  Future<List<String>> getActiveWindowTitles() async => [];

  @override
  Future<List<String>> getFriendlyMonitorNames() async => [];

  @override
  bool isLeftMouseDown() => false;

  @override
  bool isRightMouseDown() => false;

  @override
  void focusWindow(int hwnd) {}
}

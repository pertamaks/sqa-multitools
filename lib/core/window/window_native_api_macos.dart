import 'package:flutter/material.dart';
import 'window_native_api.dart';

/// macOS implementation of [WindowNativeApi].
/// Currently a shell to be implemented using AppKit/Swift bridging.
class WindowNativeApiMacOS implements WindowNativeApi {
  @override
  WindowInfo? getWindowInfoAt() {
    // TBD: Implement using CGWindowListCopyWindowInfo or similar
    return null;
  }

  @override
  Offset getAppWindowPosition() {
    // Handled via window_manager usually, but can be refined here
    return Offset.zero;
  }

  @override
  Future<List<String>> getActiveWindowTitles() async {
    // TBD: Implement using NSWorkspace.shared.runningApplications
    return [];
  }

  @override
  Future<List<String>> getFriendlyMonitorNames() async {
    // TBD: Implement using NSScreen
    return [];
  }

  @override
  bool isLeftMouseDown() {
    // TBD: Implement using NSEvent.pressedMouseButtons
    return false;
  }

  @override
  bool isRightMouseDown() {
    return false;
  }

  @override
  void focusWindow(int hwnd) {
    // TBD: Implement using NSRunningApplication activate
  }
}

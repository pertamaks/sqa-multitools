import 'package:flutter/material.dart';
import 'window_native_api.dart';

/// Linux implementation of [WindowNativeApi].
/// Currently a shell to be implemented using xdotool/wmctrl (X11)
/// or portal APIs (Wayland).
class WindowNativeApiLinux implements WindowNativeApi {
  @override
  WindowInfo? getWindowInfoAt() {
    // TBD: Implement using xwininfo / xdotool getwindowfocus
    return null;
  }

  @override
  Offset getAppWindowPosition() {
    return Offset.zero;
  }

  @override
  Future<List<String>> getActiveWindowTitles() async {
    // TBD: Implement using wmctrl -l
    return [];
  }

  @override
  Future<List<String>> getFriendlyMonitorNames() async {
    // TBD: Implement using xrandr
    return [];
  }

  @override
  bool isLeftMouseDown() {
    // TBD: Implement using xinput or reading /dev/input
    return false;
  }

  @override
  bool isRightMouseDown() {
    return false;
  }

  @override
  void focusWindow(int hwnd) {
    // TBD: Implement using wmctrl -a
  }
}

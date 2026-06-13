import 'package:flutter/material.dart';
import 'window_native_api.dart';

/// Linux implementation of [WindowNativeApi].
/// Provides safe defaults for Wayland compatibility. Wayland's security model
/// strictly isolates applications, meaning global window positions, mouse
/// tracking, and external window titles are inaccessible by design without
/// specific compositor plugins or portals.
class WindowNativeApiLinux implements WindowNativeApi {
  @override
  // Global mouse polling is not permitted on Wayland.
  bool get supportsGlobalMousePolling => false;

  @override
  Offset getAppWindowPosition() {
    return Offset.zero;
  }

  @override
  Future<List<String>> getFriendlyMonitorNames() async {
    // Requires xrandr or wayland-specific protocols. Safe default: empty.
    return [];
  }

  @override
  bool isLeftMouseDown() {
    return false;
  }

  @override
  bool isRightMouseDown() {
    return false;
  }

  @override
  void focusWindow(int hwnd) {
    // Window IDs are not globally meaningful or accessible on Wayland.
  }
}

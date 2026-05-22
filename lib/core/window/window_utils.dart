import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart' as window_manager;
import 'window_native_api.dart';

// Re-export WindowInfo so existing callers keep their current import path.
export 'window_native_api.dart' show WindowInfo;

/// High-level facade for window and OS utility operations.
///
/// Cross-platform helpers ([safeShow], [safeHide]) are implemented here
/// directly using [window_manager], which supports all desktop platforms.
///
/// All other methods delegate to the platform-specific [WindowNativeApi]
/// implementation registered at app startup in `main.dart`.
class WindowUtils {
  // ---------------------------------------------------------------------------
  // Cross-platform helpers (window_manager — no native API required)
  // ---------------------------------------------------------------------------

  /// Hides the window from the user while keeping it "alive" for global
  /// hotkeys. Uses opacity and skipTaskbar instead of windowManager.hide()
  /// which can pause the Flutter engine.
  static Future<void> safeHide() async {
    final wm = window_manager.windowManager;
    await wm.setOpacity(0.0);
    await wm.setSkipTaskbar(true);
    await wm.setIgnoreMouseEvents(true);
  }

  /// Restores the window from its "safe hide" state.
  static Future<void> safeShow() async {
    final wm = window_manager.windowManager;
    await wm.show(); // Ensure OS window is visible
    await wm.setOpacity(1.0);
    await wm.setSkipTaskbar(false);
    await wm.setIgnoreMouseEvents(false);
    await wm.focus();
  }

  // ---------------------------------------------------------------------------
  // Platform-delegated methods
  // ---------------------------------------------------------------------------

  /// Finds the top-level window at the current mouse position and returns its
  /// info, skipping windows from our own process (the overlay).
  static WindowInfo? getWindowInfoAt() =>
      WindowNativeApi.instance.getWindowInfoAt();

  /// Fetches the current application window's position synchronously.
  static Offset getAppWindowPosition() =>
      WindowNativeApi.instance.getAppWindowPosition();

  /// Fetches a list of active window titles.
  static Future<List<String>> getActiveWindowTitles() =>
      WindowNativeApi.instance.getActiveWindowTitles();

  /// Fetches human-readable monitor names (e.g., "BenQ RL2455").
  static Future<List<String>> getFriendlyMonitorNames() =>
      WindowNativeApi.instance.getFriendlyMonitorNames();

  /// Whether the current platform supports global mouse button state polling.
  /// If [false], callers should use Flutter's gesture system instead.
  static bool get supportsGlobalMousePolling =>
      WindowNativeApi.instance.supportsGlobalMousePolling;

  /// Checks if the left mouse button is currently pressed.
  static bool isLeftMouseDown() => WindowNativeApi.instance.isLeftMouseDown();

  /// Checks if the right mouse button is currently pressed.
  static bool isRightMouseDown() =>
      WindowNativeApi.instance.isRightMouseDown();

  /// Brings the given window to the front and focuses it.
  static void focusWindow(int hwnd) =>
      WindowNativeApi.instance.focusWindow(hwnd);
}

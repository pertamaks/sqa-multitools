import 'dart:io';
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
    await wm.hide();
  }

  /// Restores the window from its "safe hide" state.
  /// On Windows, also issues a 1-pixel resize nudge to flush the DWM swap
  /// chain — without this the Flutter renderer may display a stale frame
  /// with the wrong DPI when the window is re-shown after an overlay session.
  static Future<void> safeShow() async {
    final wm = window_manager.windowManager;
    await wm.setOpacity(1.0);
    await wm.show();
    await wm.focus();
    if (!Platform.isWindows) return;
    // DWM 1-pixel nudge: force re-rasterisation at the correct pixel ratio.
    try {
      final s = await wm.getSize();
      await wm.setSize(Size(s.width + 1, s.height));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await wm.setSize(s);
    } catch (_) {
      // Non-critical: ignore if the size cannot be read (e.g. window minimised).
    }
  }

  // ---------------------------------------------------------------------------
  // Platform-delegated methods
  // ---------------------------------------------------------------------------

  /// Fetches the current application window's position synchronously.
  static Offset getAppWindowPosition() =>
      WindowNativeApi.instance.getAppWindowPosition();

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
  static bool isRightMouseDown() => WindowNativeApi.instance.isRightMouseDown();

  /// Brings the given window to the front and focuses it.
  static void focusWindow(int hwnd) =>
      WindowNativeApi.instance.focusWindow(hwnd);
}

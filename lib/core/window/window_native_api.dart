import 'package:flutter/material.dart';
import 'window_native_api_stub.dart';

/// Platform-agnostic data class for a discovered OS window.
///
/// [hwnd] is Windows-specific (HWND handle). On non-Windows platforms
/// this field will be 0 and should not be used.
class WindowInfo {
  final int hwnd;
  final String title;
  final Rect rect;

  WindowInfo({required this.hwnd, required this.title, required this.rect});
}

/// Abstract contract for native OS window and input operations.
///
/// Each supported platform provides a concrete subclass. Register the
/// correct implementation once at app startup via [WindowNativeApi.register].
/// If no implementation is registered, the built-in [WindowNativeApiStub]
/// is used, which returns safe no-op defaults for all methods.
///
/// ## Adding a new platform
/// 1. Create `window_native_api_<platform>.dart` implementing this class.
/// 2. Update `window_native_api_loader_io.dart` to register your class
///    for the target platform.
/// 3. See `docs/platform_porting_guide.md` for full details.
abstract class WindowNativeApi {
  // ---------------------------------------------------------------------------
  // Singleton registry
  // ---------------------------------------------------------------------------

  static WindowNativeApi _instance = const WindowNativeApiStub();

  /// The currently registered platform implementation.
  static WindowNativeApi get instance => _instance;

  /// Registers the platform-specific implementation.
  /// Call this once in [main] before [runApp].
  static void register(WindowNativeApi api) => _instance = api;

  // ---------------------------------------------------------------------------
  // Window discovery
  // ---------------------------------------------------------------------------

  /// Returns info about the topmost non-SQA-Multitools window under the
  /// current cursor position. Returns [null] if unavailable or not supported.
  WindowInfo? getWindowInfoAt();

  /// Returns the current logical screen position of the SQA-Multitools
  /// application window. Returns [Offset.zero] if unavailable.
  Offset getAppWindowPosition();

  /// Returns a list of visible application window titles.
  /// Returns an empty list if unavailable or not supported.
  Future<List<String>> getActiveWindowTitles();

  /// Returns human-readable monitor/display names (e.g. "BenQ RL2455").
  /// Returns an empty list if unavailable or not supported.
  Future<List<String>> getFriendlyMonitorNames();

  // ---------------------------------------------------------------------------
  // Input state
  // ---------------------------------------------------------------------------

  /// Returns [true] if the left mouse button is currently held down.
  /// Returns [false] if unavailable or not supported.
  bool isLeftMouseDown();

  /// Returns [true] if the right mouse button is currently held down.
  /// Returns [false] if unavailable or not supported.
  bool isRightMouseDown();

  // ---------------------------------------------------------------------------
  // Window control
  // ---------------------------------------------------------------------------

  /// Brings the window identified by [hwnd] to the foreground.
  /// On non-Windows platforms, [hwnd] will be 0 — implementations must
  /// no-op gracefully when [hwnd] is 0.
  void focusWindow(int hwnd);
}

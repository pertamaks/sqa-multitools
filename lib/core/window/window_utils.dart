import 'dart:io';
import 'package:flutter/material.dart';
import '../models/window_info.dart';
import 'window_utils_windows.dart';
import 'window_utils_linux.dart';

class WindowUtils {
  /// Fetches a list of active window titles.
  static Future<List<String>> getActiveWindowTitles() {
    if (Platform.isWindows) return WindowUtilsWindows.getActiveWindowTitles();
    if (Platform.isLinux) return WindowUtilsLinux.getActiveWindowTitles();
    return Future.value([]);
  }

  /// Finds the top-level window at the current mouse position.
  static WindowInfo? getWindowInfoAt() {
    if (Platform.isWindows) return WindowUtilsWindows.getWindowInfoAt();
    if (Platform.isLinux) return WindowUtilsLinux.getWindowInfoAt();
    return null;
  }

  /// Fetches human-readable monitor names.
  static Future<List<String>> getFriendlyMonitorNames() {
    if (Platform.isWindows) return WindowUtilsWindows.getFriendlyMonitorNames();
    if (Platform.isLinux) return WindowUtilsLinux.getFriendlyMonitorNames();
    return Future.value([]);
  }

  /// Brings the given window to the front and focuses it.
  static void focusWindow(int hwnd) {
    if (Platform.isWindows) WindowUtilsWindows.focusWindow(hwnd);
    if (Platform.isLinux) WindowUtilsLinux.focusWindow(hwnd);
  }

  /// Checks if the left mouse button is currently pressed.
  static bool isLeftMouseDown() {
    if (Platform.isWindows) return WindowUtilsWindows.isLeftMouseDown();
    if (Platform.isLinux) return WindowUtilsLinux.isLeftMouseDown();
    return false;
  }

  /// Checks if the right mouse button is currently pressed.
  static bool isRightMouseDown() {
    if (Platform.isWindows) return WindowUtilsWindows.isRightMouseDown();
    if (Platform.isLinux) return WindowUtilsLinux.isRightMouseDown();
    return false;
  }

  /// Fetches the current application window's position synchronously.
  static Offset getAppWindowPosition() {
    if (Platform.isWindows) return WindowUtilsWindows.getAppWindowPosition();
    if (Platform.isLinux) return WindowUtilsLinux.getAppWindowPosition();
    return Offset.zero;
  }

  /// Hides the window from the user while keeping it "alive" for global hotkeys.
  static Future<void> safeHide() {
    if (Platform.isWindows) return WindowUtilsWindows.safeHide();
    if (Platform.isLinux) return WindowUtilsLinux.safeHide();
    return Future.value();
  }

  /// Restores the window from its "safe hide" state.
  static Future<void> safeShow() {
    if (Platform.isWindows) return WindowUtilsWindows.safeShow();
    if (Platform.isLinux) return WindowUtilsLinux.safeShow();
    return Future.value();
  }
}

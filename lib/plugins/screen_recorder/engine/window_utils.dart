import 'dart:io';
import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:flutter/material.dart';

class WindowInfo {
  final int hwnd;
  final String title;
  final Rect rect;

  WindowInfo({required this.hwnd, required this.title, required this.rect});
}

class WindowUtils {
  /// Fetches a list of active window titles on Windows using PowerShell.
  static Future<List<String>> getActiveWindowTitles() async {
    if (!Platform.isWindows) return [];

    try {
      final result = await Process.run(
        'powershell',
        [
          '-Command',
          r'Get-Process | Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -and $_.ProcessName -notmatch "InputApp|ShellExperienceHost|StartMenuExperienceHost|TextInputHost" } | Select-Object -ExpandProperty MainWindowTitle',
        ],
      );

      if (result.exitCode == 0) {
        final titles = const LineSplitter()
            .convert(result.stdout.toString())
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty && !e.contains('sqa-multitools')) // Exclude ourselves
            .toSet() 
            .toList();
        titles.sort();
        return titles;
      }
    } catch (_) {}

    return [];
  }

  /// Finds the top-level window at the given screen coordinates and returns its info.
  static WindowInfo? getWindowInfoAt(Offset screenPosition) {
    if (!Platform.isWindows) return null;

    final point = calloc<POINT>();
    point.ref.x = screenPosition.dx.toInt();
    point.ref.y = screenPosition.dy.toInt();

    try {
      final hwnd = WindowFromPoint(point.ref);
      if (hwnd == 0) return null;

      // Get the top-level root window
      final rootHwnd = GetAncestor(hwnd, GA_ROOT);
      if (rootHwnd == 0) return null;

      // Get Title
      final textBuffer = calloc<Uint16>(256).cast<Utf16>();
      GetWindowText(rootHwnd, textBuffer, 256);
      final title = textBuffer.toDartString();
      calloc.free(textBuffer);

      // Get precise bounds (DWM aware)
      final rectPointer = calloc<RECT>();
      final hr = DwmGetWindowAttribute(
        rootHwnd,
        DWMWA_EXTENDED_FRAME_BOUNDS,
        rectPointer,
        sizeOf<RECT>(),
      );

      Rect rect;
      if (hr == 0) {
        rect = Rect.fromLTRB(
          rectPointer.ref.left.toDouble(),
          rectPointer.ref.top.toDouble(),
          rectPointer.ref.right.toDouble(),
          rectPointer.ref.bottom.toDouble(),
        );
      } else {
        // Fallback to basic window rect if DWM call fails
        GetWindowRect(rootHwnd, rectPointer);
        rect = Rect.fromLTRB(
          rectPointer.ref.left.toDouble(),
          rectPointer.ref.top.toDouble(),
          rectPointer.ref.right.toDouble(),
          rectPointer.ref.bottom.toDouble(),
        );
      }
      
      calloc.free(rectPointer);

      // Convert Physical Rect (Windows API) to Logical Rect (Flutter)
      // Using the DPI of the specific window for maximum accuracy.
      final dpi = GetDpiForWindow(rootHwnd);
      final scaleFactor = dpi / 96.0;

      return WindowInfo(
        hwnd: rootHwnd, 
        title: title, 
        rect: Rect.fromLTRB(
          rect.left / scaleFactor,
          rect.top / scaleFactor,
          rect.right / scaleFactor,
          rect.bottom / scaleFactor,
        ),
      );
    } finally {
      calloc.free(point);
    }
  }

  /// Fetches human-readable monitor names (e.g., "BenQ RL2455") using PowerShell.
  static Future<List<String>> getFriendlyMonitorNames() async {
    if (!Platform.isWindows) return [];

    try {
      final result = await Process.run(
        'powershell',
        [
          '-Command',
          '(Get-CimInstance Win32_PnPEntity | Where-Object { \$_.Service -eq "monitor" }).Name',
        ],
      );

      if (result.exitCode == 0) {
        return const LineSplitter()
            .convert(result.stdout.toString())
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    } catch (_) {}

    return [];
  }
}

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
      final result = await Process.run('powershell', [
        '-Command',
        r'Get-Process | Where-Object { $_.MainWindowHandle -ne 0 -and $_.MainWindowTitle -and $_.ProcessName -notmatch "InputApp|ShellExperienceHost|StartMenuExperienceHost|TextInputHost" } | Select-Object -ExpandProperty MainWindowTitle',
      ]);

      if (result.exitCode == 0) {
        final titles = const LineSplitter()
            .convert(result.stdout.toString())
            .map((e) => e.trim())
            .where(
              (e) => e.isNotEmpty && !e.contains('sqa-multitools'),
            ) // Exclude ourselves
            .toSet()
            .toList();
        titles.sort();
        return titles;
      }
    } catch (_) {}

    return [];
  }

  /// Finds the top-level window at the current mouse position and returns its info,
  /// skipping windows from our own process (the overlay).
  static WindowInfo? getWindowInfoAt() {
    if (!Platform.isWindows) return null;

    final point = calloc<POINT>();
    final myPid = GetCurrentProcessId();
    final lpdwProcessId = calloc<Uint32>();
    final rectPointer = calloc<RECT>();
    final classNameBuffer = calloc<Uint16>(512).cast<Utf16>();

    int targetHwnd = 0;
    Pointer<Utf16>? textBuffer;

    try {
      GetCursorPos(point);

      // Start from the very first (top-most) child of the Desktop
      int hwnd = GetWindow(GetDesktopWindow(), GW_CHILD);

      while (hwnd != 0) {
        // 1. Must be visible
        if (IsWindowVisible(hwnd) != 0) {
          // 2. Window Rect must contain the point (physical pixels)
          GetWindowRect(hwnd, rectPointer);
          if (point.ref.x >= rectPointer.ref.left &&
              point.ref.x < rectPointer.ref.right &&
              point.ref.y >= rectPointer.ref.top &&
              point.ref.y < rectPointer.ref.bottom) {
            // 3. Check Process ID
            GetWindowThreadProcessId(hwnd, lpdwProcessId);
            if (lpdwProcessId.value != myPid) {
              // 4. Filter out system background windows
              final classLen = GetClassName(hwnd, classNameBuffer, 512);
              if (classLen > 0) {
                final className = classNameBuffer.toDartString();

                final ignoreClasses = [
                  'Progman',
                  'WorkerW',
                  'Shell_TrayWnd',
                  'Shell_SecondaryTrayWnd',
                ];

                if (!ignoreClasses.contains(className)) {
                  // Found it! This is the top-most app window under our overlay
                  targetHwnd = hwnd;
                  break;
                }
              }
            }
          }
        }
        // Move to the next window down in the Z-order stack
        hwnd = GetWindow(hwnd, GW_HWNDNEXT);
      }

      if (targetHwnd == 0 || IsWindow(targetHwnd) == 0) return null;

      // Get Title
      String title = 'Active Window';
      textBuffer = calloc<Uint16>(512).cast<Utf16>();
      final textLen = GetWindowText(targetHwnd, textBuffer, 512);
      if (textLen > 0) {
        title = textBuffer.toDartString();
      }

      // Get Precise Bounds (DWM aware)
      Rect rect;
      if (IsWindow(targetHwnd) != 0) {
        final hr = DwmGetWindowAttribute(
          targetHwnd,
          DWMWA_EXTENDED_FRAME_BOUNDS,
          rectPointer,
          sizeOf<RECT>(),
        );

        if (hr == 0) {
          rect = Rect.fromLTRB(
            rectPointer.ref.left.toDouble(),
            rectPointer.ref.top.toDouble(),
            rectPointer.ref.right.toDouble(),
            rectPointer.ref.bottom.toDouble(),
          );
        } else {
          // Fallback to basic window rect
          GetWindowRect(targetHwnd, rectPointer);
          rect = Rect.fromLTRB(
            rectPointer.ref.left.toDouble(),
            rectPointer.ref.top.toDouble(),
            rectPointer.ref.right.toDouble(),
            rectPointer.ref.bottom.toDouble(),
          );
        }
      } else {
        return null;
      }

      // Convert Physical Rect (Windows API) to Logical Rect (Flutter)
      final dpi = GetDpiForWindow(targetHwnd);
      final scaleFactor = (dpi > 0) ? dpi / 96.0 : 1.0;

      return WindowInfo(
        hwnd: targetHwnd,
        title: title,
        rect: Rect.fromLTRB(
          rect.left / scaleFactor,
          rect.top / scaleFactor,
          rect.right / scaleFactor,
          rect.bottom / scaleFactor,
        ),
      );
    } catch (e) {
      debugPrint('[WindowUtils] Error in getWindowInfoAt: $e');
      return null;
    } finally {
      calloc.free(point);
      calloc.free(lpdwProcessId);
      calloc.free(rectPointer);
      calloc.free(classNameBuffer);
      if (textBuffer != null) calloc.free(textBuffer);
    }
  }

  /// Fetches human-readable monitor names (e.g., "BenQ RL2455") using PowerShell.
  static Future<List<String>> getFriendlyMonitorNames() async {
    if (!Platform.isWindows) return [];

    try {
      final result = await Process.run('powershell', [
        '-Command',
        '(Get-CimInstance Win32_PnPEntity | Where-Object { \$_.Service -eq "monitor" }).Name',
      ]);

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

  /// Brings the given window to the front and focuses it.
  static void focusWindow(int hwnd) {
    if (!Platform.isWindows || hwnd == 0) return;

    // Check if minimized
    if (IsIconic(hwnd) != 0) {
      ShowWindow(hwnd, SW_RESTORE);
    } else {
      ShowWindow(hwnd, SW_SHOW);
    }

    // Bring to top and focus
    SetForegroundWindow(hwnd);
  }

  /// Checks if the left mouse button is currently pressed.
  static bool isLeftMouseDown() {
    if (!Platform.isWindows) return false;
    return (GetAsyncKeyState(VK_LBUTTON) & 0x8000) != 0;
  }

  /// Checks if the right mouse button is currently pressed.
  static bool isRightMouseDown() {
    if (!Platform.isWindows) return false;
    return (GetAsyncKeyState(VK_RBUTTON) & 0x8000) != 0;
  }

  static int _cachedAppHwnd = 0;

  /// Fetches the current application window's position synchronously.
  /// Bypasses focus dependency by searching for our process window if needed.
  static Offset getAppWindowPosition() {
    if (!Platform.isWindows) return Offset.zero;

    final rectPointer = calloc<RECT>();
    final lpdwProcessId = calloc<Uint32>();

    try {
      // 1. Try Cached Handle first for performance
      int hwnd = _cachedAppHwnd;

      // 2. Validate or find new handle if missing/invalid
      if (hwnd == 0 || IsWindow(hwnd) == 0 || IsWindowVisible(hwnd) == 0) {
        final myPid = GetCurrentProcessId();
        int searchHwnd = GetWindow(GetDesktopWindow(), GW_CHILD);

        while (searchHwnd != 0) {
          if (IsWindowVisible(searchHwnd) != 0) {
            GetWindowThreadProcessId(searchHwnd, lpdwProcessId);
            if (lpdwProcessId.value == myPid) {
              hwnd = searchHwnd;
              _cachedAppHwnd = hwnd;
              break;
            }
          }
          searchHwnd = GetWindow(searchHwnd, GW_HWNDNEXT);
        }
      }

      if (hwnd == 0) return Offset.zero;

      GetWindowRect(hwnd, rectPointer);

      // Convert Physical to Logical
      final dpi = GetDpiForWindow(hwnd);
      final scaleFactor = (dpi > 0) ? dpi / 96.0 : 1.0;

      return Offset(
        rectPointer.ref.left.toDouble() / scaleFactor,
        rectPointer.ref.top.toDouble() / scaleFactor,
      );
    } catch (e) {
      debugPrint('[WindowUtils] Error in getAppWindowPosition: $e');
      return Offset.zero;
    } finally {
      calloc.free(rectPointer);
      calloc.free(lpdwProcessId);
    }
  }
}

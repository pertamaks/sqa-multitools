import 'dart:io';
import 'dart:convert';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'package:flutter/material.dart';
import 'window_native_api.dart';

/// Windows implementation of [WindowNativeApi].
///
/// Uses the win32 package (FFI bindings to kernel32, user32, dwmapi) and
/// PowerShell for window/monitor enumeration.
///
/// All methods include a runtime [Platform.isWindows] guard as a safety net,
/// consistent with the original window_utils.dart behaviour.
class WindowNativeApiWindows implements WindowNativeApi {
  int _cachedAppHwnd = 0;

  @override
  bool get supportsGlobalMousePolling => true;

  // ---------------------------------------------------------------------------
  // Window discovery
  // ---------------------------------------------------------------------------



  @override
  Offset getAppWindowPosition() {
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
      debugPrint('[WindowNativeApiWindows] Error in getAppWindowPosition: $e');
      return Offset.zero;
    } finally {
      calloc.free(rectPointer);
      calloc.free(lpdwProcessId);
    }
  }



  @override
  Future<List<String>> getFriendlyMonitorNames() async {
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

  // ---------------------------------------------------------------------------
  // Input state
  // ---------------------------------------------------------------------------

  @override
  bool isLeftMouseDown() {
    if (!Platform.isWindows) return false;
    return (GetAsyncKeyState(VK_LBUTTON) & 0x8000) != 0;
  }

  @override
  bool isRightMouseDown() {
    if (!Platform.isWindows) return false;
    return (GetAsyncKeyState(VK_RBUTTON) & 0x8000) != 0;
  }

  // ---------------------------------------------------------------------------
  // Window control
  // ---------------------------------------------------------------------------

  @override
  void focusWindow(int hwnd) {
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
}

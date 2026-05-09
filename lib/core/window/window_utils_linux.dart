import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart' as window_manager;
import '../models/window_info.dart';
import 'window_utils.dart';

class WindowUtilsLinux {
  /// Fetches a list of active window titles on Linux using wmctrl.
  static Future<List<String>> getActiveWindowTitles() async {
    try {
      final result = await Process.run('wmctrl', ['-l']);

      if (result.exitCode == 0) {
        return const LineSplitter()
            .convert(result.stdout.toString())
            .map((line) {
              // wmctrl -l output: <window_id> <desktop_id> <machine_name> <window_title>
              final parts = line.split(RegExp(r'\s+'));
              if (parts.length >= 4) {
                return parts.sublist(3).join(' ').trim();
              }
              return '';
            })
            .where((title) => title.isNotEmpty && !title.contains('sqa-multitools'))
            .toSet()
            .toList();
      }
    } catch (_) {
      // Return empty if wmctrl is not installed
    }
    return [];
  }

  /// Finds the top-level window at the current mouse position.
  static WindowInfo? getWindowInfoAt() {
    try {
      // 1. Get Mouse Location
      final mouseRes = Process.runSync('xdotool', ['getmouselocation', '--shell']);
      if (mouseRes.exitCode != 0) return null;

      final mouseData = mouseRes.stdout.toString();
      final xMatch = RegExp(r'X=(\d+)').firstMatch(mouseData);
      final yMatch = RegExp(r'Y=(\d+)').firstMatch(mouseData);
      if (xMatch == null || yMatch == null) return null;

      final mx = int.parse(xMatch.group(1)!);
      final my = int.parse(yMatch.group(1)!);

      // 2. Get all windows with geometry
      final winRes = Process.runSync('wmctrl', ['-lG']);
      if (winRes.exitCode != 0) return null;

      final lines = const LineSplitter().convert(winRes.stdout.toString());
      
      // Iterate backwards (top-most windows are usually last in wmctrl output, 
      // but Z-order is tricky. We'll find the smallest window containing the point
      // as a heuristic for "top-most").
      WindowInfo? bestMatch;
      double minArea = double.infinity;

      for (final line in lines) {
        final parts = line.split(RegExp(r'\s+'));
        if (parts.length < 8) continue;

        // parts: [id, desktop, x, y, w, h, machine, title...]
        final x = int.parse(parts[2]);
        final y = int.parse(parts[3]);
        final w = int.parse(parts[4]);
        final h = int.parse(parts[5]);
        final title = parts.sublist(7).join(' ');

        if (title.contains('sqa-multitools')) continue;

        final rect = Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble());
        if (rect.contains(Offset(mx.toDouble(), my.toDouble()))) {
          final area = rect.width * rect.height;
          if (area < minArea) {
            minArea = area;
            bestMatch = WindowInfo(
              hwnd: int.tryParse(parts[0].replaceFirst('0x', ''), radix: 16) ?? 0,
              title: title,
              rect: rect,
            );
          }
        }
      }
      return bestMatch;
    } catch (_) {
      return null;
    }
  }

  /// Fetches monitor names using xrandr.
  static Future<List<String>> getFriendlyMonitorNames() async {
    try {
      final result = await Process.run('xrandr', ['--listmonitors']);
      if (result.exitCode == 0) {
        return const LineSplitter()
            .convert(result.stdout.toString())
            .where((line) => line.contains('Monitor'))
            .map((line) => line.split(RegExp(r'\s+')).last)
            .toList();
      }
    } catch (_) {}
    return ['Default Monitor'];
  }

  /// Brings the given window to the front.
  static void focusWindow(int hwnd) {
    try {
      // Use wmctrl -ia to activate the window by its numerical ID
      final hexId = '0x${hwnd.toRadixString(16)}';
      Process.runSync('wmctrl', ['-ia', hexId]);
    } catch (_) {
      // Silent fail
    }
  }

  static bool isLeftMouseDown() {
    return false;
  }

  static bool isRightMouseDown() {
    return false;
  }

  static Offset getAppWindowPosition() {
    return Offset.zero;
  }

  static Future<void> safeHide() async {
    final wm = window_manager.windowManager;
    await wm.setOpacity(0.0);
    await wm.setSkipTaskbar(true);
  }

  static Future<void> safeShow() async {
    final wm = window_manager.windowManager;
    await wm.show();
    await wm.setOpacity(1.0);
    await wm.setSkipTaskbar(false);
    await wm.focus();
  }
}

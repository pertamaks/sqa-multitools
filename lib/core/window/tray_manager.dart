import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'window_utils.dart';

class TrayManager {
  static final SystemTray _systemTray = SystemTray();

  static Future<void> init() async {
    String path = Platform.isWindows
        ? 'assets/app_icon.ico'
        : 'assets/app_icon.png';

    try {
      await _systemTray.initSystemTray(title: "SQA-Multitools", iconPath: path);
    } catch (e) {
      debugPrint("System Tray Exception: $e");
    }

    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Show Main Toolbar',
        onClicked: (menuItem) async {
          await WindowUtils.safeShow();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Settings',
        onClicked: (menuItem) async {
          // Future: Open settings window directly
          await WindowUtils.safeShow();
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Quit App',
        onClicked: (menuItem) async {
          await windowManager.destroy();
          exit(0);
        },
      ),
    ]);

    await _systemTray.setContextMenu(menu);

    _systemTray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        await WindowUtils.safeShow();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }
}

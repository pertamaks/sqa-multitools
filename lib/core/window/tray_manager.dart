import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'window_utils.dart';
import '../providers/plugin_provider.dart';
import '../models/sqa_plugin.dart';

class TrayManager {
  static final SystemTray _systemTray = SystemTray();

  static Future<void> init(ProviderContainer container) async {
    String path = Platform.isWindows
        ? 'assets/app_icon.ico'
        : 'assets/app_icon.png';

    try {
      await _systemTray.initSystemTray(title: "SQA-Multitools", iconPath: path);
    } catch (e) {
      debugPrint("System Tray Exception: $e");
    }

    // Initial menu build
    final initialPlugins = container.read(enabledPluginsProvider);
    await _updateMenu(initialPlugins, container);

    // Listen for changes and update dynamically
    container.listen(enabledPluginsProvider, (previous, next) async {
      await _updateMenu(next, container);
    });

    _systemTray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        await WindowUtils.safeShow();
      } else if (eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  static Future<void> _updateMenu(
    List<SqaPlugin> plugins,
    ProviderContainer container,
  ) async {
    final Menu menu = Menu();

    final pluginItems = plugins
        .map(
          (p) => MenuItemLabel(
            label: p.name,
            onClicked: (menuItem) async {
              await WindowUtils.safeShow();
              container
                  .read(navigationServiceProvider)
                  .togglePlugin(p, forceOpen: true);
            },
          ),
        )
        .toList();

    await menu.buildFrom([
      MenuItemLabel(
        label: 'Show Main Toolbar',
        onClicked: (menuItem) async {
          await WindowUtils.safeShow();
        },
      ),
      MenuSeparator(),
      ...pluginItems,
      MenuSeparator(),
      MenuItemLabel(
        label: 'Settings',
        onClicked: (menuItem) async {
          await WindowUtils.safeShow();
          final settingsPlugin = container.read(settingsPluginProvider);
          container
              .read(navigationServiceProvider)
              .togglePlugin(settingsPlugin, forceOpen: true);
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
  }
}

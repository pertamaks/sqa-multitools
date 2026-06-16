import 'package:flutter/material.dart' show Size;
import 'package:window_manager/window_manager.dart';
import '../window/window_constants.dart';
import 'window_provider.dart';
import '../models/sqa_plugin.dart';
import '../../plugins/magic_8ball/magic_8ball_plugin.dart';
import '../../plugins/timer/timer_plugin.dart';
import '../../plugins/data_generator/data_generator_plugin.dart';
import '../../plugins/screen_recorder/screen_recorder_plugin.dart';
import '../../plugins/screenshot/screenshot_plugin.dart';
import '../../plugins/settings/settings_plugin.dart';
import '../../plugins/security_payloads/security_payloads_plugin.dart';
import '../../plugins/beautifier/beautifier_plugin.dart';
import '../../plugins/text_editor/text_editor_plugin.dart';
import '../../plugins/requirement_obfuscator/requirement_obfuscator_plugin.dart';
import '../../plugins/todo/todo_plugin.dart';
import '../../plugins/qa_cheatsheet/qa_cheatsheet_plugin.dart';
import '../../plugins/curl_requester/curl_requester_plugin.dart';
import '../../plugins/swagger_explorer/swagger_explorer_plugin.dart';
import '../services/preferences_service.dart';
import '../services/coffee_shop_service.dart';
import '../services/logging_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plugin_provider.g.dart';

@Riverpod(keepAlive: true)
List<SqaPlugin> availablePlugins(Ref ref) {
  final plugins = [
    TimerPlugin(),
    DataGeneratorPlugin(),
    ScreenRecorderPlugin(),
    ScreenshotPlugin(),
    SecurityPayloadsPlugin(),
    BeautifierPlugin(),
    TextEditorPlugin(),
    RequirementObfuscatorPlugin(),
    TodoPlugin(),
    QaCheatsheetPlugin(),
    CurlRequesterPlugin(),
    SwaggerExplorerPlugin(),
    if (ref.watch(supporterTierProvider) >= 2) QaOraclePlugin(),
  ];

  // Proactively initialize plugins for warm-up (Rule 6)
  final logger = ref.read(loggingServiceProvider.notifier);
  for (final plugin in plugins) {
    plugin.initialize().catchError((Object e, StackTrace stack) {
      logger.logError(
        'Error initializing plugin ${plugin.id}: $e',
        'PluginInit',
        e,
        stack,
      );
    });
  }
  return plugins;
}

/// Provides all available plugins in their user-defined order
@Riverpod(keepAlive: true)
List<SqaPlugin> orderedAvailablePlugins(Ref ref) {
  final all = ref.watch(availablePluginsProvider);
  final orderIds = ref.watch(preferencesServiceProvider).getPluginOrder();

  if (orderIds == null) return all;

  final sorted = List<SqaPlugin>.from(all);
  sorted.sort((a, b) {
    int indexA = orderIds.indexOf(a.id);
    int indexB = orderIds.indexOf(b.id);
    // If a plugin isn't in the order list, put it at the end
    if (indexA == -1) indexA = 999;
    if (indexB == -1) indexB = 999;
    return indexA.compareTo(indexB);
  });
  return sorted;
}

@Riverpod(keepAlive: true)
class EnabledPlugins extends _$EnabledPlugins {
  @override
  List<SqaPlugin> build() {
    final prefs = ref.watch(preferencesServiceProvider);
    final allOrdered = ref.watch(orderedAvailablePluginsProvider);
    final enabledIds = prefs.getEnabledPluginIds();

    if (enabledIds == null) {
      // Default State: Only stable tools (badge: null) are enabled
      final defaultEnabled = allOrdered.where((p) => p.badge == null).toList();
      final defaultIds = defaultEnabled.map((p) => p.id).toList();

      // If no stable tools found (due to BETA badges), fallback to all
      if (defaultEnabled.isEmpty) {
        return allOrdered.take(5).toList();
      }

      prefs.setEnabledPluginIds(defaultIds);
      return defaultEnabled;
    }

    return allOrdered.where((p) => enabledIds.contains(p.id)).toList();
  }

  void togglePlugin(String pluginId, bool enable) {
    final prefs = ref.read(preferencesServiceProvider);
    final currentEnabledIds = prefs.getEnabledPluginIds()?.toList() ?? [];

    if (enable && !currentEnabledIds.contains(pluginId)) {
      currentEnabledIds.add(pluginId);
    } else if (!enable && currentEnabledIds.contains(pluginId)) {
      currentEnabledIds.remove(pluginId);
    }

    prefs.setEnabledPluginIds(currentEnabledIds);

    // Re-build state based on the new enabled set while preserving order
    final allOrdered = ref.read(orderedAvailablePluginsProvider);
    state = allOrdered.where((p) => currentEnabledIds.contains(p.id)).toList();
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final prefs = ref.read(preferencesServiceProvider);
    final allOrdered = List<SqaPlugin>.from(
      ref.read(orderedAvailablePluginsProvider),
    );
    final item = allOrdered.removeAt(oldIndex);
    allOrdered.insert(newIndex, item);

    // Persist the new full order
    prefs.setPluginOrder(allOrdered.map((p) => p.id).toList());

    // Update state for anyone watching enabledPluginsProvider
    final enabledIds = prefs.getEnabledPluginIds() ?? [];
    state = allOrdered.where((p) => enabledIds.contains(p.id)).toList();

    // Force rebuild of orderedAvailablePluginsProvider
    ref.invalidate(orderedAvailablePluginsProvider);
  }
}

@Riverpod(keepAlive: true)
class ActivePlugin extends _$ActivePlugin {
  @override
  SqaPlugin? build() => null;
  void setPlugin(SqaPlugin? plugin) => state = plugin;
}

@Riverpod(keepAlive: true)
SqaPlugin settingsPlugin(Ref ref) => SettingsPlugin();

// --- Navigation Layer ---

/// Tracks the ID of the plugin we should return to from Settings
@Riverpod(keepAlive: true)
class NavigationHistory extends _$NavigationHistory {
  @override
  String? build() => null;
  void setHistory(String? id) => state = id;
}

/// Tracks the active tab in the Settings view
@Riverpod(keepAlive: true)
class SettingsTab extends _$SettingsTab {
  @override
  int build() => 0;
  void setTab(int index) => state = index;
}

@Riverpod(keepAlive: true)
class PluginEditMode extends _$PluginEditMode {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

/// Centralized service for jumping between plugins/settings
@Riverpod(keepAlive: true)
NavigationService navigationService(Ref ref) => NavigationService(ref);

class NavigationService {
  final Ref _ref;
  NavigationService(this._ref);

  /// Jumps to the Settings plugin, specifically the 'Plugins' tab
  void jumpToPluginSettings(String sourcePluginId) {
    _ref.read(navigationHistoryProvider.notifier).setHistory(sourcePluginId);
    _ref.read(settingsTabProvider.notifier).setTab(1); // Index 1 is 'Plugins'

    final settingsPlugin = _ref.read(settingsPluginProvider);
    _ref.read(activePluginProvider.notifier).setPlugin(settingsPlugin);
  }

  /// Jumps to the Todo plugin
  void jumpToTodo(String sourcePluginId) {
    _ref.read(navigationHistoryProvider.notifier).setHistory(sourcePluginId);

    final allPlugins = _ref.read(availablePluginsProvider);
    final todoPlugin = allPlugins
        .where((p) => p.id == 'com.sqa.plugin.todo')
        .firstOrNull;
    if (todoPlugin != null) {
      _ref.read(activePluginProvider.notifier).setPlugin(todoPlugin);
    }
  }

  /// Returns to the previous plugin if history exists, otherwise closes the active plugin
  void goBack() {
    // Revert any theme previews when navigating back
    _ref.read(themeSettingsProvider.notifier).resetToSaved();

    final history = _ref.read(navigationHistoryProvider);
    if (history != null) {
      final allPlugins = _ref.read(availablePluginsProvider);
      final plugin =
          allPlugins.where((p) => p.id == history).firstOrNull ??
          _ref.read(availablePluginsProvider).first;

      _ref.read(activePluginProvider.notifier).setPlugin(plugin);
      _ref.read(navigationHistoryProvider.notifier).setHistory(null);
    } else {
      _ref.read(activePluginProvider.notifier).setPlugin(null);
    }
  }

  /// Toggles a plugin's visibility, managing navigation history and window sizes.
  /// If [forceOpen] is true, it will not close the plugin if it's already active.
  Future<void> togglePlugin(SqaPlugin plugin, {bool forceOpen = false}) async {
    final current = _ref.read(activePluginProvider);

    // If we're leaving the settings plugin, revert any theme previews
    if (current?.id == 'com.sqa.settings' && plugin.id != 'com.sqa.settings') {
      _ref.read(themeSettingsProvider.notifier).resetToSaved();
    }

    if (current?.id == plugin.id && !forceOpen) {
      _ref.read(activePluginProvider.notifier).setPlugin(null);
      // Clear history when closing
      _ref.read(navigationHistoryProvider.notifier).setHistory(null);
      if (plugin.id == 'com.sqa.settings') {
        _ref.read(themeSettingsProvider.notifier).resetToSaved();
      }
      _ref.read(windowSizeModeProvider.notifier).reset();
      await windowManager.setMinimumSize(
        const Size(
          WindowConstants.kDefaultWindowWidth,
          WindowConstants.kToolbarWindowHeight,
        ),
      );
      await windowManager.setSize(
        const Size(
          WindowConstants.kDefaultWindowWidth,
          WindowConstants.kToolbarWindowHeight,
        ),
      );
    } else {
      // HANDLE NAVIGATION HISTORY
      if (plugin.id == 'com.sqa.settings') {
        // Entering Settings: record where we came from if it's a real plugin
        if (current != null && current.id != 'com.sqa.settings') {
          _ref.read(navigationHistoryProvider.notifier).setHistory(current.id);
        }
        // Default to 'General' tab (0) when accessed from the toolbar
        _ref.read(settingsTabProvider.notifier).setTab(0);
      } else {
        // Entering any other plugin: clear the back-navigation history
        _ref.read(navigationHistoryProvider.notifier).setHistory(null);
      }

      _ref.read(windowSizeModeProvider.notifier).reset();
      _ref.read(activePluginProvider.notifier).setPlugin(plugin);
      await windowManager.setMinimumSize(
        const Size(
          WindowConstants.kDefaultWindowWidth,
          WindowConstants.kExpandedWindowHeight,
        ),
      );
      await windowManager.setSize(
        const Size(
          WindowConstants.kDefaultWindowWidth,
          WindowConstants.kExpandedWindowHeight,
        ),
      );
    }
  }
}

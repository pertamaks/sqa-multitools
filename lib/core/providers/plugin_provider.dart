import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sqa_plugin.dart';
import '../../plugins/magic_8ball/magic_8ball_plugin.dart';
import '../../plugins/timer/timer_plugin.dart';
import '../../plugins/data_generator/data_generator_plugin.dart';
import '../../plugins/color_picker/color_picker_plugin.dart';
import '../../plugins/clipboard/clipboard_plugin.dart';
import '../../plugins/screen_recorder/screen_recorder_plugin.dart';
import '../../plugins/screenshot/screenshot_plugin.dart';
import '../../plugins/settings/settings_plugin.dart';
import '../../plugins/security_payloads/security_payloads_plugin.dart';
import '../../plugins/beautifier/beautifier_plugin.dart';
import '../services/preferences_service.dart';
import '../services/coffee_shop_service.dart';

final availablePluginsProvider = Provider<List<SqaPlugin>>((ref) {
  return [
    TimerPlugin(),
    DataGeneratorPlugin(),
    ColorPickerPlugin(),
    ClipboardPlugin(),
    ScreenRecorderPlugin(),
    ScreenshotPlugin(),
    SecurityPayloadsPlugin(),
    BeautifierPlugin(),
    if (ref.watch(supporterTierProvider) >= 2) QaOraclePlugin(),
  ];
});

/// Provides all available plugins in their user-defined order
final orderedAvailablePluginsProvider = Provider<List<SqaPlugin>>((ref) {
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
});

class EnabledPluginsNotifier extends Notifier<List<SqaPlugin>> {
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

final enabledPluginsProvider =
    NotifierProvider<EnabledPluginsNotifier, List<SqaPlugin>>(() {
      return EnabledPluginsNotifier();
    });

class ActivePluginNotifier extends Notifier<SqaPlugin?> {
  @override
  SqaPlugin? build() => null;
  void setPlugin(SqaPlugin? plugin) => state = plugin;
}

final activePluginProvider = NotifierProvider<ActivePluginNotifier, SqaPlugin?>(
  () {
    return ActivePluginNotifier();
  },
);

final settingsPluginProvider = Provider<SqaPlugin>((ref) => SettingsPlugin());

// --- Navigation Layer ---

/// Tracks the ID of the plugin we should return to from Settings
class NavigationHistoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setHistory(String? id) => state = id;
}

final navigationHistoryProvider =
    NotifierProvider<NavigationHistoryNotifier, String?>(
      () => NavigationHistoryNotifier(),
    );

/// Tracks the active tab in the Settings view
class SettingsTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void setTab(int index) => state = index;
}

final settingsTabProvider = NotifierProvider<SettingsTabNotifier, int>(
  () => SettingsTabNotifier(),
);

class PluginEditModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
  void set(bool value) => state = value;
}

/// State provider to track if we are in 'Edit Order' mode for plugins
final pluginEditModeProvider = NotifierProvider<PluginEditModeNotifier, bool>(
  () => PluginEditModeNotifier(),
);

/// Centralized service for jumping between plugins/settings
final navigationServiceProvider = Provider((ref) => NavigationService(ref));

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
}

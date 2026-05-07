import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqa_multitools/core/providers/plugin_provider.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'default_state_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    // Generic mock for any other getStringList (like plugin_order)
    when(mockPrefs.getStringList(any)).thenReturn(null);
    // Return null for enabled_plugins to trigger default state logic
    when(
      mockPrefs.getStringList(PreferencesService.keyEnabledPlugins),
    ).thenReturn(null);
    when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

    // Setup for other possible prefs
    when(mockPrefs.getInt(any)).thenReturn(null);
    when(mockPrefs.getBool(any)).thenReturn(null);
  });

  test('EnabledPluginsNotifier enables only stable tools by default', () async {
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(mockPrefs)],
    );

    final enabledPlugins = container.read(enabledPluginsProvider);

    // Verify that every enabled plugin has no badge (stable)
    for (final plugin in enabledPlugins) {
      expect(
        plugin.badge,
        isNull,
        reason: '${plugin.name} should be stable to be enabled by default',
      );
    }

    // Verify that Alpha/Beta plugins are NOT in the enabled list
    final allPlugins = container.read(availablePluginsProvider);
    final alphaBetaPlugins = allPlugins.where(
      (p) => p.badge == 'ALPHA' || p.badge == 'BETA',
    );

    for (final plugin in alphaBetaPlugins) {
      expect(
        enabledPlugins.any((p) => p.id == plugin.id),
        isFalse,
        reason:
            '${plugin.name} (${plugin.badge}) should be disabled by default',
      );
    }
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqa_multitools/core/providers/plugin_provider.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:mockito/mockito.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('All plugins successfully register and build', () async {
    final prefs = await SharedPreferences.getInstance();
    final mockSecure = MockSecureStorage();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStorageProvider.overrideWithValue(mockSecure),
      ],
    );

    // Verify plugins register correctly
    final plugins = container.read(availablePluginsProvider);
    expect(plugins.isNotEmpty, true);

    // Check specific known plugins are registered
    final pluginIds = plugins.map((p) => p.id).toList();
    expect(pluginIds.contains('com.sqa.timer'), true);
    expect(pluginIds.contains('com.sqa.data_generator'), true);

    // Verify ThemeSettings initializes without exceptions
    final theme = container.read(themeSettingsProvider);
    expect(theme.modeIndex, 0);
  });
}

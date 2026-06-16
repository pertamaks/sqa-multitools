import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:sqa_multitools/core/services/coffee_shop_service.dart';
import 'package:mockito/mockito.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockSupporterTier extends SupporterTier {
  @override
  int build() => 3;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('ThemeSettings updates correctly', () async {
    final prefs = await SharedPreferences.getInstance();
    final mockSecure = MockSecureStorage();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStorageProvider.overrideWithValue(mockSecure),
        supporterTierProvider.overrideWith(() => MockSupporterTier()), // Ensure all features unlocked
      ],
    );

    // Initial check
    final initialSettings = container.read(themeSettingsProvider);
    expect(initialSettings.modeIndex, 0); // Default

    // Change mode
    container.read(themeSettingsProvider.notifier).setModeIndex(2);
    expect(container.read(themeSettingsProvider).modeIndex, 2);

    // Change seed color
    container.read(themeSettingsProvider.notifier).setSeedColor(0xFF123456);
    expect(container.read(themeSettingsProvider).seedColorValue, 0xFF123456);

    // Toggle transparency
    container.read(themeSettingsProvider.notifier).toggleTransparencyMode(true);
    expect(container.read(themeSettingsProvider).isTransparencyModeEnabled, true);
    expect(container.read(themeSettingsProvider).opacity, 0.85);
  });
}

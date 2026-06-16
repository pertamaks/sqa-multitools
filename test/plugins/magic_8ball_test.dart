import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/magic_8ball/providers/magic_8ball_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:mockito/mockito.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Oracle settings mode changes correctly', () async {
    final prefs = await SharedPreferences.getInstance();
    final mockSecure = MockSecureStorage();
    final container = ProviderContainer(
      overrides: [
        preferencesServiceProvider.overrideWithValue(PreferencesService(prefs, mockSecure)),
      ],
    );

    // Initial should be the default from prefs
    final initialSettings = container.read(oracleSettingsProvider);
    expect(initialSettings.mode, isNotNull);

    // Change mode
    container.read(oracleSettingsProvider.notifier).setMode(OracleMode.savage);
    expect(container.read(oracleSettingsProvider).mode, OracleMode.savage);
    
    // Verify responses match
    final responses = container.read(oracleResponsesProvider);
    expect(responses.isNotEmpty, true);
    expect(responses.length, 20); // Savage has 20 responses
  });
}

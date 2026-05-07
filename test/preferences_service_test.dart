import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';

void main() {
  group('PreferencesService Tests', () {
    test('Returns null when nothing is saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = PreferencesService(prefs);

      final enabled = service.getEnabledPluginIds();
      expect(enabled, isNull);
    });

    test('Saves and reads specific plugins', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = PreferencesService(prefs);

      await service.setEnabledPluginIds([
        'com.sqa.timer',
        'com.sqa.color_picker',
      ]);

      final enabled = service.getEnabledPluginIds()!;
      expect(enabled.length, 2);
      expect(enabled, ['com.sqa.timer', 'com.sqa.color_picker']);
    });

    test('Bug Squash toggle defaults to true and persists', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = PreferencesService(prefs);

      expect(service.getBugSquashEnabled(), isTrue);

      await service.setBugSquashEnabled(false);
      expect(service.getBugSquashEnabled(), isFalse);

      await service.setBugSquashEnabled(true);
      expect(service.getBugSquashEnabled(), isTrue);
    });
  });
}

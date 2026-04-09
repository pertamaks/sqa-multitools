import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/beautifier/beautifier_plugin.dart';
import 'package:sqa_multitools/plugins/beautifier/providers/beautifier_provider.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  group('BeautifierNotifier', () {
    test('initial state has default values', () {
      final state = container.read(beautifierProvider);
      expect(state.input, '');
      expect(state.output, '');
      expect(state.language, BeautifierLanguage.json);
      expect(state.autoFormat, true);
    });

    test('updateInput updates input and formats if autoFormat is true', () {
      final notifier = container.read(beautifierProvider.notifier);
      const input = '{"a":1}';

      notifier.updateInput(input);

      final state = container.read(beautifierProvider);
      expect(state.input, input);
      expect(state.output, '{\n  "a": 1\n}');
    });

    test('format JSON properly', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.json);
      notifier.updateInput('{"key":"value","nested":{"id":1}}');
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(state.output, contains('"key": "value"'));
      expect(state.output, contains('  "nested": {'));
    });

    test('format XML properly', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.xml);
      notifier.updateInput('<root><child id="1">text</child></root>');
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(
        state.output,
        contains('<root>\n  <child id="1">text</child>\n</root>'),
      );
    });

    test('format YAML properly', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.yaml);
      notifier.updateInput('name: Joe\nids: [10, 20]');
      notifier.format();

      final state = container.read(beautifierProvider);
      // Depending on yaml_writer's specific output format
      expect(state.output, contains('name:'));
      expect(state.output, contains('Joe'));
      expect(state.output, contains('ids:'));
    });

    test('handles invalid input gracefully', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.json);
      notifier.updateInput('{invalid json}');
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(state.output, startsWith('ERROR:'));
      expect(state.error, contains('Invalid JSON format'));
    });

    test('setAutoFormat persists choice', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setAutoFormat(false);

      final state = container.read(beautifierProvider);
      expect(state.autoFormat, false);

      final prefs = container.read(preferencesServiceProvider);
      expect(prefs.getBeautifierAutoFormat(), false);
    });
  });
}

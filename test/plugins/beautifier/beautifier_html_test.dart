import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/beautifier/beautifier_plugin.dart';
import 'package:sqa_multitools/plugins/beautifier/providers/beautifier_provider.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  group('HTML Formatter Tests', () {
    test('formats valid HTML5 with void elements', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.html);

      const input =
          '<!DOCTYPE html><html><body><section><h2>Gallery</h2><img src="1.jpg" alt="A"><img src="2.jpg" alt="B"></section></body></html>';
      notifier.updateInput(input);
      notifier.format();

      final state = container.read(beautifierProvider);

      expect(state.output, contains('<!DOCTYPE html>'));
      expect(state.output, contains('<img src="1.jpg" alt="A">'));
      expect(state.output, contains('  <img src="2.jpg" alt="B">'));
    });

    test('handles HTML entities and fragments', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.html);

      const input = '<div><p>Copyright &copy; 2026</p></div>';
      notifier.updateInput(input);
      notifier.format();

      final state = container.read(beautifierProvider);

      expect(state.output, contains('<div>'));
      expect(state.output, contains('  <p>'));
      expect(state.output, contains('Copyright \u00a9 2026')); // &copy; is ©
    });

    test('respects indentWidth for HTML', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.html);
      notifier.setIndentWidth(4);

      const input = '<div><span>test</span></div>';
      notifier.updateInput(input);
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(state.output, contains('<div>\n    <span>test</span>\n</div>'));
    });
  });
}

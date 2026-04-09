import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/plugins/beautifier/providers/beautifier_provider.dart';
import 'package:sqa_multitools/plugins/beautifier/beautifier_plugin.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('CSS Formatter Tests', () {
    test('formats complex one-line CSS snippet (User Example)', () {
      const minified = ':root{--p:#007bff;--s:#6c757d;--f:16px}.btn{padding:10px;border-radius:4px;border:none;cursor:pointer}.btn-p{background:var(--p);color:#fff}.btn-s{background:var(--s);color:#fff}.card{border:1px solid #ddd;border-radius:8px;padding:15px}.card h2{margin:0 0 10px;color:var(--p)}@media(max-width:600px){.card{padding:10px}.btn{width:100%}}';
      
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.css);
      notifier.updateInput(minified);
      notifier.format();

      final state = container.read(beautifierProvider);
      
      // Verify structure
      expect(state.output, contains(':root {'));
      expect(state.output, contains('  --p: #007bff;'));
      expect(state.output, contains('}'));
      expect(state.output, contains('.btn {'));
      expect(state.output, contains('  padding: 10px;'));
      expect(state.output, contains('.card h2 {'));
      expect(state.output, contains('@media (max-width: 600px) {'));
      expect(state.output, contains('  .card {'));
      expect(state.output, contains('    padding: 10px;'));
    });

    test('respects indentWidth for CSS', () {
      const input = '.test{color:red;}';
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.css);
      notifier.setIndentWidth(4);
      notifier.updateInput(input);
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(state.output, contains('.test {'));
      expect(state.output, contains('    color: red;'));
    });

    test('CSS Lexer Edge Cases', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.css);
      
      // Selectors with dots, hashes, colons
      notifier.updateInput('body.dark #main:hover{opacity:0.5}');
      notifier.format();
      var state = container.read(beautifierProvider);
      expect(state.output, contains('body.dark #main:hover {'));
      expect(state.output, contains('  opacity: 0.5;'));

      // Comments
      notifier.updateInput('/* Global */\n.a{color:red} /* inline */');
      notifier.format();
      state = container.read(beautifierProvider);
      expect(state.output, contains('/* Global */'));
      expect(state.output, contains('.a {'));
      expect(state.output, contains('/* inline */'));
    });
  });
}

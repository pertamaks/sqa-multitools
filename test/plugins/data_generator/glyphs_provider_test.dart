import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/data_generator/providers/glyphs_provider.dart';
import 'package:sqa_multitools/plugins/data_generator/models/glyphs_state.dart';
import 'package:sqa_multitools/plugins/data_generator/models/text_state.dart';

void main() {
  group('GlyphsGenerator Provider Tests', () {
    test('generate chinese returns CJK characters', () {
      final container = ProviderContainer();
      final notifier = container.read(glyphsGeneratorProvider.notifier);

      notifier.setCategory(GlyphsCategory.chinese);
      notifier.setType(TextType.sentence);
      notifier.setSize(5);
      notifier.generate();

      final state = container.read(glyphsGeneratorProvider);
      final results = state.resultsMap[GlyphsCategory.chinese] ?? <String>[];
      // Chinese characters should have high code units
      expect(results.first.codeUnits.any((int u) => u > 0x4E00), isTrue);
      // Should NOT contain spaces for Chinese sentences
      expect(results.first.contains(' '), isFalse);
    });

    test('generate arabic returns Arabic characters', () {
      final container = ProviderContainer();
      final notifier = container.read(glyphsGeneratorProvider.notifier);

      notifier.setCategory(GlyphsCategory.arabic);
      notifier.setType(TextType.sentence);
      notifier.setSize(5);
      notifier.generate();

      final state = container.read(glyphsGeneratorProvider);
      final results = state.resultsMap[GlyphsCategory.arabic] ?? <String>[];
      // Arabic characters are in the 0x0600 range
      expect(
        results.first.codeUnits.any((int u) => u >= 0x0600 && u <= 0x06FF),
        isTrue,
      );
      expect(results.first.contains(' '), isTrue);
    });

    test('generate japanese still works (from faker)', () {
      final container = ProviderContainer();
      final notifier = container.read(glyphsGeneratorProvider.notifier);

      notifier.setCategory(GlyphsCategory.japanese);
      notifier.setType(TextType.sentence);
      notifier.setSize(5);
      notifier.generate();

      final state = container.read(glyphsGeneratorProvider);
      final results = state.resultsMap[GlyphsCategory.japanese] ?? <String>[];
      expect(results.first.codeUnits.any((int u) => u > 127), isTrue);
    });
  });
}

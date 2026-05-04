import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/data_generator/providers/text_provider.dart';
import 'package:sqa_multitools/plugins/data_generator/models/text_state.dart';

void main() {
  group('TextGenerator Provider Tests', () {
    test('initial state is empty', () {
      final container = ProviderContainer();
      final state = container.read(textGeneratorProvider);
      expect(state.resultsMap[TextType.bytes], isNull);
    });

    test('generate bytes returns correct length', () {
      final container = ProviderContainer();
      final notifier = container.read(textGeneratorProvider.notifier);

      notifier.setType(TextType.bytes);
      notifier.setSize(50);
      notifier.generate();

      final state = container.read(textGeneratorProvider);
      final results = state.resultsMap[TextType.bytes] ?? <String>[];
      expect(results.first.length, inInclusiveRange(45, 55));
    });

    test('generate chapter starts with CHAPTER', () {
      final container = ProviderContainer();
      final notifier = container.read(textGeneratorProvider.notifier);

      notifier.setType(TextType.chapter);
      notifier.setSize(1);
      notifier.generate();

      final state = container.read(textGeneratorProvider);
      final results = state.resultsMap[TextType.chapter] ?? <String>[];
      expect(results.first, startsWith('CHAPTER:'));
    });
  });
}

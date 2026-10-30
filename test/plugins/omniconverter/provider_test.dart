import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/omniconverter/models/conversion_types.dart';
import 'package:sqa_multitools/plugins/omniconverter/providers/omniconverter_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OmniConverterNotifier Tests', () {
    test('Initial state is correct', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(omniConverterProvider);
      expect(state.category, ConversionCategory.encoding);
      expect(state.encodingMode, EncodingSubMode.base64);
      expect(state.direction, ConversionDirection.forward);
      expect(state.input, isEmpty);
      expect(state.output, isEmpty);
    });

    test('Direct encoding transforms correctly on debounce', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(omniConverterProvider.notifier);
      notifier.updateInput('Hello');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final state = container.read(omniConverterProvider);
      expect(state.output, 'SGVsbG8=');
      expect(state.errorMessage, isNull);
    });

    test('Swap input and output works seamlessly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(omniConverterProvider.notifier);
      notifier.updateInput('World');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final encoded = container.read(omniConverterProvider).output;
      expect(encoded, 'V29ybGQ=');

      // Swap
      notifier.swapInputOutput();
      final swappedState = container.read(omniConverterProvider);
      expect(swappedState.input, encoded);
      expect(swappedState.direction, ConversionDirection.reverse);
      expect(swappedState.output, 'World');
    });

    test('Handles malformed Base64 gracefully with error message', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(omniConverterProvider.notifier);
      notifier.setDirection(ConversionDirection.reverse);
      notifier.updateInput('===InvalidBase64===');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final state = container.read(omniConverterProvider);
      expect(state.output, isEmpty);
      expect(state.errorMessage, isNotNull);
    });

    test('Switching category updates result accordingly', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(omniConverterProvider.notifier);
      notifier.updateInput('{"key":"value"}');
      await Future<void>.delayed(const Duration(milliseconds: 200));

      notifier.setCategory(ConversionCategory.format);
      notifier.setFormatMode(FormatSubMode.jsonToYaml);

      final state = container.read(omniConverterProvider);
      expect(state.output, contains('key:'));
      expect(state.output, contains('value'));
    });
  });
}


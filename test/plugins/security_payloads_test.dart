import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/security_payloads/providers/security_payloads_provider.dart';

void main() {
  group('SecurityPayloadsProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state should show disclaimer and have empty URL', () {
      final state = container.read(securityPayloadsProvider);
      expect(state.showDisclaimer, true);
      expect(state.targetUrl, '');
      expect(state.generatedPayloads, isEmpty);
    });

    test('Dismissing disclaimer should update state', () {
      container.read(securityPayloadsProvider.notifier).dismissDisclaimer();
      final state = container.read(securityPayloadsProvider);
      expect(state.showDisclaimer, false);
    });

    test('Updating URL with parameters should generate payloads', () {
      const testUrl = 'https://example.com/api?id=1';
      container.read(securityPayloadsProvider.notifier).updateUrl(testUrl);

      final state = container.read(securityPayloadsProvider);
      expect(state.targetUrl, testUrl);
      expect(state.generatedPayloads, isNotEmpty);
      expect(state.generatedPayloads[0], contains('..%2F..%2F..%2F..%2Fetc%2Fpasswd'));
      expect(state.generatedPayloads[0], contains('id='));
    });

    test('Updating URL without parameters should use fallback injection', () {
      const testUrl = 'https://example.com/api';
      container.read(securityPayloadsProvider.notifier).updateUrl(testUrl);

      final state = container.read(securityPayloadsProvider);
      expect(state.targetUrl, testUrl);
      expect(state.generatedPayloads, isNotEmpty);
      expect(state.generatedPayloads[0], contains('?file='));
    });

    test('Empty URL should clear generated payloads', () {
      container
          .read(securityPayloadsProvider.notifier)
          .updateUrl('https://example.com/api?id=1');
      expect(container.read(securityPayloadsProvider).generatedPayloads,
          isNotEmpty);

      container.read(securityPayloadsProvider.notifier).updateUrl('');
      final state = container.read(securityPayloadsProvider);
      expect(state.targetUrl, '');
      expect(state.generatedPayloads, isEmpty);
    });
  });
}

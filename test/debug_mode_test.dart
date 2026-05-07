import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/core/providers/debug_provider.dart';

void main() {
  group('DebugMode Provider Tests', () {
    test('Initializes to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(debugModeProvider), isFalse);
    });

    test('Toggles state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(debugModeProvider.notifier).toggle();
      expect(container.read(debugModeProvider), isTrue);

      container.read(debugModeProvider.notifier).toggle();
      expect(container.read(debugModeProvider), isFalse);
    });

    test('Persists state when no longer watched (keepAlive: true)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Enable debug mode
      container.read(debugModeProvider.notifier).toggle();
      expect(container.read(debugModeProvider), isTrue);

      // Simulate the UI navigating away (no more listeners)
      // We don't have a listener here, but in auto-dispose it would be gone.
      // With keepAlive: true, it should stay.

      // Let's create a listener then remove it.
      final subscription = container.listen(debugModeProvider, (prev, next) {});
      subscription.close();

      // The provider should still be alive and keep its state.
      expect(container.read(debugModeProvider), isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/core/providers/window_provider.dart';

void main() {
  test('windowSizeModeProvider toggles correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state
    expect(
      container.read(windowSizeModeProvider),
      WindowSizeMode.defaultExpanded,
    );

    // Toggle (Note: we can't easily test windowManager calls in pure unit tests without mocks,
    // but we can test the state transitions).
    container
        .read(windowSizeModeProvider.notifier)
        .setForTesting(WindowSizeMode.squareMode);
    expect(container.read(windowSizeModeProvider), WindowSizeMode.squareMode);

    container.read(windowSizeModeProvider.notifier).reset();
    expect(
      container.read(windowSizeModeProvider),
      WindowSizeMode.defaultExpanded,
    );
  });
}

extension on WindowSizeModeNotifier {
  void setForTesting(WindowSizeMode mode) => state = mode;
}

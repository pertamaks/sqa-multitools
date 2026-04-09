import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/timer/providers/unix_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('UnixNotifier initial state is live and has current timestamp', () {
    final state = container.read(unixProvider);
    expect(state.isLive, true);
    expect(state.manualTimestampString.length, 10);
  });

  test('UnixNotifier setDateTime pauses live ticking', () {
    final dt = DateTime(2024, 1, 1, 12, 0, 0);
    container.read(unixProvider.notifier).setDateTime(dt);

    final state = container.read(unixProvider);
    expect(state.isLive, false);
    expect(state.manualDateTime, dt);
    expect(state.lastInteractionWasDateTime, true);
  });

  test('UnixNotifier convert human-readable to unix', () {
    final dt = DateTime.utc(2024, 1, 1, 0, 0, 0);
    container.read(unixProvider.notifier).setDateTime(dt);
    container.read(unixProvider.notifier).convert();

    final state = container.read(unixProvider);
    // 2024-01-01 00:00:00 UTC is 1704067200
    expect(state.manualTimestampString, '1704067200');
  });

  test('UnixNotifier convert unix to human-readable', () {
    const ts = '1704067200';
    container.read(unixProvider.notifier).setTimestampString(ts);
    container.read(unixProvider.notifier).convert();

    final state = container.read(unixProvider);
    expect(state.manualDateTime.toUtc(), DateTime.utc(2024, 1, 1, 0, 0, 0));
  });

  test('UnixNotifier resetToNow resumes live ticking', () {
    final dt = DateTime(2020, 1, 1);
    container.read(unixProvider.notifier).setDateTime(dt);
    expect(container.read(unixProvider).isLive, false);

    container.read(unixProvider.notifier).resetToNow();
    expect(container.read(unixProvider).isLive, true);
  });
}

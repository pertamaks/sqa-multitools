import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/timer/providers/timer_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Initial state is zero and not running', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(timerProvider);

    expect(state.initialDuration, Duration.zero);
    expect(state.remaining, Duration.zero);
    expect(state.isRunning, false);
  });

  test('setDuration sets the initial and remaining duration correctly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    const testDuration = Duration(minutes: 5);

    timerNotifier.setDuration(testDuration);
    final state = container.read(timerProvider);

    expect(state.initialDuration, testDuration);
    expect(state.remaining, testDuration);
    expect(state.isRunning, false);
  });

  test('start sets isRunning to true when duration > 0', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    const testDuration = Duration(minutes: 1);

    timerNotifier.setDuration(testDuration);
    timerNotifier.start();
    final state = container.read(timerProvider);

    expect(state.isRunning, true);
  });

  test('start launches stopwatch when duration is 0', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    timerNotifier.start();
    final state = container.read(timerProvider);

    expect(state.isRunning, true);
    expect(state.isStopwatch, true);
  });

  test('pause sets isRunning to false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    const testDuration = Duration(minutes: 1);

    timerNotifier.setDuration(testDuration);
    timerNotifier.start();
    timerNotifier.pause();

    final state = container.read(timerProvider);
    expect(state.isRunning, false);
  });

  test('reset returns remaining time to initialDuration and stops timer', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final timerNotifier = container.read(timerProvider.notifier);
    const testDuration = Duration(minutes: 1);

    timerNotifier.setDuration(testDuration);
    timerNotifier.start();
    timerNotifier.reset();

    final state = container.read(timerProvider);
    expect(state.isRunning, false);
    expect(state.remaining, testDuration);
  });
}

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/timer_state.dart';
import '../../../core/services/audio_service.dart';

part 'timer_provider.g.dart';

@riverpod
class TimerNotifier extends _$TimerNotifier {
  Timer? _ticker;
  DateTime? _lastTickTime;

  @override
  TimerState build() {
    ref.onDispose(() {
      _ticker?.cancel();
    });
    return const TimerState();
  }

  Future<void> _playAlarm() async {
    await AudioService.instance.playAsset('sounds/alarm.mp3');
  }

  void setDuration(Duration duration) {
    state = state.copyWith(
      initialDuration: duration,
      remaining: duration,
      isRunning: false,
    );
    _ticker?.cancel();
  }

  void addTime(Duration duration) {
    if (state.isRunning) {
      return; // Prevent arbitrary changes while running for simplicity, or allow them? Let's allow but we have to ensure it doesn't drop below 0 if adding negative time.
    }
    final newDuration = state.initialDuration + duration;
    if (newDuration < Duration.zero) {
      return;
    }

    state = state.copyWith(
      initialDuration: newDuration,
      remaining: newDuration,
    );
  }

  void start() {
    if (state.initialDuration > Duration.zero &&
        state.remaining <= Duration.zero) {
      return;
    }

    final isStopwatch = state.initialDuration == Duration.zero;

    state = state.copyWith(isRunning: true, isStopwatch: isStopwatch);
    _ticker?.cancel();
    _lastTickTime = DateTime.now();

    // Use 16ms for ~60fps smooth UI updates
    _ticker = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final now = DateTime.now();
      final elapsedSinceLastTick = now.difference(_lastTickTime!);
      _lastTickTime = now;

      if (state.isStopwatch) {
        final newRemaining = state.remaining + elapsedSinceLastTick;
        state = state.copyWith(remaining: newRemaining);
      } else {
        final newRemaining = state.remaining - elapsedSinceLastTick;

        if (newRemaining <= Duration.zero) {
          state = state.copyWith(remaining: Duration.zero, isRunning: false);
          timer.cancel();
          _playAlarm();
        } else {
          state = state.copyWith(remaining: newRemaining);
        }
      }
    });
  }

  void pause() {
    state = state.copyWith(isRunning: false);
    _ticker?.cancel();
  }

  void toggle() {
    if (state.isRunning) {
      pause();
    } else {
      start();
    }
  }

  void reset() {
    state = state.copyWith(
      remaining: state.initialDuration,
      isRunning: false,
      isStopwatch: false,
    );
    _ticker?.cancel();
  }
}

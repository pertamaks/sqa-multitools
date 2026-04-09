import 'package:freezed_annotation/freezed_annotation.dart';

part 'timer_state.freezed.dart';

@freezed
abstract class TimerState with _$TimerState {
  const factory TimerState({
    @Default(Duration.zero) Duration initialDuration,
    @Default(Duration.zero) Duration remaining,
    @Default(false) bool isRunning,
    @Default(false) bool isStopwatch,
  }) = _TimerState;
}

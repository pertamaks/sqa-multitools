import 'package:freezed_annotation/freezed_annotation.dart';

part 'unix_state.freezed.dart';

@freezed
abstract class UnixState with _$UnixState {
  const factory UnixState({
    required DateTime manualDateTime,
    required String manualTimestampString,
    @Default(true) bool isLive,
    @Default(false)
    bool
    lastInteractionWasDateTime, // True if DT was edited last, False if Unix was edited last
  }) = _UnixState;
}

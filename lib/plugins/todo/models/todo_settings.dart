import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_settings.freezed.dart';
part 'todo_settings.g.dart';

@freezed
abstract class TodoSettings with _$TodoSettings {
  const factory TodoSettings({
    int? wakeHour,
    int? wakeMinute,
    @Default(true) bool askWakeTimeDaily,
    @Default(false) bool autoOpenOnReminder,
    @Default(30) int historyRetentionDays,
    @Default(true) bool use24HourFormat,
    DateTime? lastWakeTimePromptDate,
  }) = _TodoSettings;

  factory TodoSettings.fromJson(Map<String, dynamic> json) => _$TodoSettingsFromJson(json);
}

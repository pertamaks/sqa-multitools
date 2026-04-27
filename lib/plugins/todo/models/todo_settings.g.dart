// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoSettings _$TodoSettingsFromJson(Map<String, dynamic> json) =>
    _TodoSettings(
      wakeHour: (json['wakeHour'] as num?)?.toInt(),
      wakeMinute: (json['wakeMinute'] as num?)?.toInt(),
      askWakeTimeDaily: json['askWakeTimeDaily'] as bool? ?? true,
      autoOpenOnReminder: json['autoOpenOnReminder'] as bool? ?? false,
      historyRetentionDays:
          (json['historyRetentionDays'] as num?)?.toInt() ?? 30,
      lastWakeTimePromptDate: json['lastWakeTimePromptDate'] == null
          ? null
          : DateTime.parse(json['lastWakeTimePromptDate'] as String),
    );

Map<String, dynamic> _$TodoSettingsToJson(
  _TodoSettings instance,
) => <String, dynamic>{
  'wakeHour': instance.wakeHour,
  'wakeMinute': instance.wakeMinute,
  'askWakeTimeDaily': instance.askWakeTimeDaily,
  'autoOpenOnReminder': instance.autoOpenOnReminder,
  'historyRetentionDays': instance.historyRetentionDays,
  'lastWakeTimePromptDate': instance.lastWakeTimePromptDate?.toIso8601String(),
};

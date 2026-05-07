// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_todo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecurringTodo _$RecurringTodoFromJson(Map<String, dynamic> json) =>
    _RecurringTodo(
      id: json['id'] as String,
      title: json['title'] as String,
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      durationPreset:
          $enumDecodeNullable(
            _$TodoDurationPresetEnumMap,
            json['durationPreset'],
          ) ??
          TodoDurationPreset.min25,
      priority:
          $enumDecodeNullable(_$TodoPriorityEnumMap, json['priority']) ??
          TodoPriority.normal,
      recurrenceType:
          $enumDecodeNullable(
            _$RecurrenceTypeEnumMap,
            json['recurrenceType'],
          ) ??
          RecurrenceType.daily,
      everyNDays: (json['everyNDays'] as num?)?.toInt() ?? 1,
      weeklyDays:
          (json['weeklyDays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      category: json['category'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? true,
      lastGeneratedDate: json['lastGeneratedDate'] == null
          ? null
          : DateTime.parse(json['lastGeneratedDate'] as String),
    );

Map<String, dynamic> _$RecurringTodoToJson(_RecurringTodo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'hour': instance.hour,
      'minute': instance.minute,
      'durationPreset': _$TodoDurationPresetEnumMap[instance.durationPreset]!,
      'priority': _$TodoPriorityEnumMap[instance.priority]!,
      'recurrenceType': _$RecurrenceTypeEnumMap[instance.recurrenceType]!,
      'everyNDays': instance.everyNDays,
      'weeklyDays': instance.weeklyDays,
      'category': instance.category,
      'notes': instance.notes,
      'isActive': instance.isActive,
      'lastGeneratedDate': instance.lastGeneratedDate?.toIso8601String(),
    };

const _$TodoDurationPresetEnumMap = {
  TodoDurationPreset.min5: 5,
  TodoDurationPreset.min15: 15,
  TodoDurationPreset.min25: 25,
  TodoDurationPreset.min45: 45,
  TodoDurationPreset.min90: 90,
};

const _$TodoPriorityEnumMap = {
  TodoPriority.low: 'low',
  TodoPriority.normal: 'normal',
  TodoPriority.high: 'high',
  TodoPriority.critical: 'critical',
};

const _$RecurrenceTypeEnumMap = {
  RecurrenceType.daily: 'daily',
  RecurrenceType.weekdays: 'weekdays',
  RecurrenceType.weekly: 'weekly',
  RecurrenceType.everyNDays: 'everyNDays',
};

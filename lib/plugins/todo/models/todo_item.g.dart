// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoItem _$TodoItemFromJson(Map<String, dynamic> json) => _TodoItem(
  id: json['id'] as String,
  title: json['title'] as String,
  timeBlock:
      $enumDecodeNullable(_$TodoTimeBlockEnumMap, json['timeBlock']) ??
      TodoTimeBlock.current,
  durationPreset:
      $enumDecodeNullable(
        _$TodoDurationPresetEnumMap,
        json['durationPreset'],
      ) ??
      TodoDurationPreset.min25,
  priority:
      $enumDecodeNullable(_$TodoPriorityEnumMap, json['priority']) ??
      TodoPriority.normal,
  status:
      $enumDecodeNullable(_$TodoStatusEnumMap, json['status']) ??
      TodoStatus.todo,
  category: json['category'] as String? ?? '',
  notes: json['notes'] as String? ?? '',
  delegatedTo: json['delegatedTo'] as String? ?? '',
  createdAt: DateTime.parse(json['createdAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  deferredUntil: json['deferredUntil'] == null
      ? null
      : DateTime.parse(json['deferredUntil'] as String),
  recurringTodoId: json['recurringTodoId'] as String?,
);

Map<String, dynamic> _$TodoItemToJson(_TodoItem instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'timeBlock': _$TodoTimeBlockEnumMap[instance.timeBlock]!,
  'durationPreset': _$TodoDurationPresetEnumMap[instance.durationPreset]!,
  'priority': _$TodoPriorityEnumMap[instance.priority]!,
  'status': _$TodoStatusEnumMap[instance.status]!,
  'category': instance.category,
  'notes': instance.notes,
  'delegatedTo': instance.delegatedTo,
  'createdAt': instance.createdAt.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'deferredUntil': instance.deferredUntil?.toIso8601String(),
  'recurringTodoId': instance.recurringTodoId,
};

const _$TodoTimeBlockEnumMap = {
  TodoTimeBlock.current: 'current',
  TodoTimeBlock.morning: 'morning',
  TodoTimeBlock.midMorning: 'midMorning',
  TodoTimeBlock.noon: 'noon',
  TodoTimeBlock.afternoon: 'afternoon',
  TodoTimeBlock.lateAfternoon: 'lateAfternoon',
  TodoTimeBlock.evening: 'evening',
  TodoTimeBlock.night: 'night',
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

const _$TodoStatusEnumMap = {
  TodoStatus.todo: 'todo',
  TodoStatus.inProgress: 'inProgress',
  TodoStatus.done: 'done',
  TodoStatus.deferred: 'deferred',
  TodoStatus.delegated: 'delegated',
};

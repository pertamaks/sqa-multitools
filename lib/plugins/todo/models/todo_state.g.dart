// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TodoState _$TodoStateFromJson(Map<String, dynamic> json) => _TodoState(
  todos:
      (json['todos'] as List<dynamic>?)
          ?.map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentTab:
      $enumDecodeNullable(_$TodoTabEnumMap, json['currentTab']) ??
      TodoTab.today,
  hasActiveReminder: json['hasActiveReminder'] as bool? ?? false,
  previousPluginId: json['previousPluginId'] as String? ?? null,
);

Map<String, dynamic> _$TodoStateToJson(_TodoState instance) =>
    <String, dynamic>{
      'todos': instance.todos,
      'currentTab': _$TodoTabEnumMap[instance.currentTab]!,
      'hasActiveReminder': instance.hasActiveReminder,
      'previousPluginId': instance.previousPluginId,
    };

const _$TodoTabEnumMap = {TodoTab.today: 'today', TodoTab.history: 'history'};

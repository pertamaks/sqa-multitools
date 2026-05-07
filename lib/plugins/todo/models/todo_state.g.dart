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
  recurringTodos:
      (json['recurringTodos'] as List<dynamic>?)
          ?.map((e) => RecurringTodo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentTab:
      $enumDecodeNullable(_$TodoTabEnumMap, json['currentTab']) ??
      TodoTab.today,
  hasActiveReminder: json['hasActiveReminder'] as bool? ?? false,
  previousPluginId: json['previousPluginId'] as String? ?? null,
  searchQuery: json['searchQuery'] as String? ?? '',
  historyFilter:
      $enumDecodeNullable(_$HistoryFilterEnumMap, json['historyFilter']) ??
      HistoryFilter.last7Days,
);

Map<String, dynamic> _$TodoStateToJson(_TodoState instance) =>
    <String, dynamic>{
      'todos': instance.todos,
      'recurringTodos': instance.recurringTodos,
      'currentTab': _$TodoTabEnumMap[instance.currentTab]!,
      'hasActiveReminder': instance.hasActiveReminder,
      'previousPluginId': instance.previousPluginId,
      'searchQuery': instance.searchQuery,
      'historyFilter': _$HistoryFilterEnumMap[instance.historyFilter]!,
    };

const _$TodoTabEnumMap = {
  TodoTab.today: 'today',
  TodoTab.recurring: 'recurring',
  TodoTab.history: 'history',
};

const _$HistoryFilterEnumMap = {
  HistoryFilter.last7Days: 'last7Days',
  HistoryFilter.thisMonth: 'thisMonth',
  HistoryFilter.lastMonth: 'lastMonth',
  HistoryFilter.custom: 'custom',
};

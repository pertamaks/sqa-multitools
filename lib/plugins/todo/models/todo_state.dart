import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'todo_item.dart';
import 'recurring_todo.dart';

part 'todo_state.freezed.dart';
part 'todo_state.g.dart';

enum TodoTab { today, recurring, history }

enum HistoryFilter { last7Days, thisMonth, lastMonth, custom }

@freezed
abstract class TodoState with _$TodoState {
  const factory TodoState({
    @Default([]) List<TodoItem> todos,
    @Default([]) List<RecurringTodo> recurringTodos,
    @Default(TodoTab.today) TodoTab currentTab,
    @Default(false) bool hasActiveReminder,
    @Default(null) String? previousPluginId,
    @Default('') String searchQuery,
    @Default(HistoryFilter.last7Days) HistoryFilter historyFilter,
    @JsonKey(includeFromJson: false, includeToJson: false)
    DateTimeRange? customDateRange,
  }) = _TodoState;

  factory TodoState.fromJson(Map<String, dynamic> json) =>
      _$TodoStateFromJson(json);
}

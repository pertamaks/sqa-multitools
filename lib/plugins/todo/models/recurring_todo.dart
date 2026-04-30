import 'package:freezed_annotation/freezed_annotation.dart';
import 'todo_item.dart';

part 'recurring_todo.freezed.dart';
part 'recurring_todo.g.dart';

enum RecurrenceType { daily, weekdays, weekly, everyNDays }

@freezed
abstract class RecurringTodo with _$RecurringTodo {
  const factory RecurringTodo({
    required String id,
    required String title,
    required int hour,
    required int minute,
    @Default(TodoDurationPreset.min25) TodoDurationPreset durationPreset,
    @Default(TodoPriority.normal) TodoPriority priority,
    @Default(RecurrenceType.daily) RecurrenceType recurrenceType,
    @Default(1) int everyNDays,
    @Default([]) List<int> weeklyDays,
    @Default('') String category,
    @Default('') String notes,
    @Default(true) bool isActive,
    DateTime? lastGeneratedDate,
  }) = _RecurringTodo;

  factory RecurringTodo.fromJson(Map<String, dynamic> json) =>
      _$RecurringTodoFromJson(json);
}

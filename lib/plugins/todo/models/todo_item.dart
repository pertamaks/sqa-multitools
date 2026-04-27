import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';
part 'todo_item.g.dart';

enum TodoTimeBlock {
  current,
  morning,
  midMorning,
  noon,
  afternoon,
  lateAfternoon,
  evening,
  night,
}

extension TodoTimeBlockX on TodoTimeBlock {
  String getDisplayName(bool use24Hour) {
    if (use24Hour) {
      switch (this) {
        case TodoTimeBlock.current: return 'Current';
        case TodoTimeBlock.morning: return 'Morning (06:00-09:00)';
        case TodoTimeBlock.midMorning: return 'Mid Morning (09:00-11:00)';
        case TodoTimeBlock.noon: return 'Noon (12:00)';
        case TodoTimeBlock.afternoon: return 'Afternoon (13:00-15:00)';
        case TodoTimeBlock.lateAfternoon: return 'Late Afternoon (15:00-17:00)';
        case TodoTimeBlock.evening: return 'Evening (18:00-20:00)';
        case TodoTimeBlock.night: return 'Night (20:00+)';
      }
    } else {
      switch (this) {
        case TodoTimeBlock.current: return 'Current';
        case TodoTimeBlock.morning: return 'Morning (6-9 AM)';
        case TodoTimeBlock.midMorning: return 'Mid Morning (9-11 AM)';
        case TodoTimeBlock.noon: return 'Noon (12 PM)';
        case TodoTimeBlock.afternoon: return 'Afternoon (1-3 PM)';
        case TodoTimeBlock.lateAfternoon: return 'Late Afternoon (3-5 PM)';
        case TodoTimeBlock.evening: return 'Evening (6-8 PM)';
        case TodoTimeBlock.night: return 'Night (8 PM+)';
      }
    }
  }

  bool isPast(DateTime now) {
    switch (this) {
      case TodoTimeBlock.current: return false;
      case TodoTimeBlock.morning: return now.hour >= 9;
      case TodoTimeBlock.midMorning: return now.hour >= 11;
      case TodoTimeBlock.noon: return now.hour >= 13;
      case TodoTimeBlock.afternoon: return now.hour >= 15;
      case TodoTimeBlock.lateAfternoon: return now.hour >= 17;
      case TodoTimeBlock.evening: return now.hour >= 20;
      case TodoTimeBlock.night: return false;
    }
  }

  // Keep for legacy or default usage
  String get displayName => getDisplayName(true);
}

enum TodoDurationPreset {
  @JsonValue(5)
  min5,
  @JsonValue(15)
  min15,
  @JsonValue(25)
  min25,
  @JsonValue(45)
  min45,
  @JsonValue(90)
  min90,
}

enum TodoPriority {
  low,
  normal,
  high,
  critical,
}

extension TodoPriorityX on TodoPriority {
  String get displayName {
    switch (this) {
      case TodoPriority.low: return 'Low';
      case TodoPriority.normal: return 'Normal';
      case TodoPriority.high: return 'High';
      case TodoPriority.critical: return 'Critical';
    }
  }
}

enum TodoStatus {
  todo,
  inProgress,
  done,
  deferred,
  delegated,
}

extension TodoStatusX on TodoStatus {
  String get displayName {
    switch (this) {
      case TodoStatus.todo: return 'Todo';
      case TodoStatus.inProgress: return 'In Progress';
      case TodoStatus.done: return 'Done';
      case TodoStatus.deferred: return 'Deferred';
      case TodoStatus.delegated: return 'Delegated';
    }
  }
}

@freezed
abstract class TodoItem with _$TodoItem {
  const factory TodoItem({
    required String id,
    required String title,
    @Default(TodoTimeBlock.current) TodoTimeBlock timeBlock,
    @Default(TodoDurationPreset.min25) TodoDurationPreset durationPreset,
    @Default(TodoPriority.normal) TodoPriority priority,
    @Default(TodoStatus.todo) TodoStatus status,
    @Default('') String category,
    @Default('') String notes,
    @Default('') String delegatedTo,
    required DateTime createdAt,
    DateTime? completedAt,
    DateTime? deferredUntil,
  }) = _TodoItem;

  factory TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);
}

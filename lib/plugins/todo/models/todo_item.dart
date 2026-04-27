import 'package:freezed_annotation/freezed_annotation.dart';

part 'todo_item.freezed.dart';
part 'todo_item.g.dart';

enum TodoTimeBlock {
  current,
  morning,
  noon,
  afternoon,
  evening,
  tonight,
}

extension TodoTimeBlockX on TodoTimeBlock {
  String get displayName {
    switch (this) {
      case TodoTimeBlock.current: return 'Current';
      case TodoTimeBlock.morning: return 'Morning';
      case TodoTimeBlock.noon: return 'Noon';
      case TodoTimeBlock.afternoon: return 'Afternoon';
      case TodoTimeBlock.evening: return 'Evening';
      case TodoTimeBlock.tonight: return 'Tonight';
    }
  }
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
}

extension TodoStatusX on TodoStatus {
  String get displayName {
    switch (this) {
      case TodoStatus.todo: return 'Todo';
      case TodoStatus.inProgress: return 'In Progress';
      case TodoStatus.done: return 'Done';
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
    required DateTime createdAt,
    DateTime? completedAt,
  }) = _TodoItem;

  factory TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);
}

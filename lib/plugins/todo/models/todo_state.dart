import 'package:freezed_annotation/freezed_annotation.dart';
import 'todo_item.dart';

part 'todo_state.freezed.dart';
part 'todo_state.g.dart';

enum TodoTab {
  today,
  history,
}

@freezed
abstract class TodoState with _$TodoState {
  const factory TodoState({
    @Default([]) List<TodoItem> todos,
    @Default(TodoTab.today) TodoTab currentTab,
    @Default(false) bool hasActiveReminder,
    @Default(null) String? previousPluginId,
  }) = _TodoState;

  factory TodoState.fromJson(Map<String, dynamic> json) => _$TodoStateFromJson(json);
}

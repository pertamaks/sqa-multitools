import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';
import '../models/todo_state.dart';
import '../models/todo_settings.dart';
import '../services/todo_storage_service.dart';

part 'todo_provider.g.dart';

@Riverpod(keepAlive: true)
class TodoStorage extends _$TodoStorage {
  @override
  TodoStorageService build() => TodoStorageService();
}

@Riverpod(keepAlive: true)
class TodoSettingsNotifier extends _$TodoSettingsNotifier {
  @override
  Future<TodoSettings> build() async {
    return ref.read(todoStorageProvider).loadSettings();
  }

  Future<void> updateSettings(TodoSettings settings) async {
    state = AsyncData(settings);
    await ref.read(todoStorageProvider).saveSettings(settings);
  }
}

@Riverpod(keepAlive: true)
class Todo extends _$Todo {
  @override
  Future<TodoState> build() async {
    final storage = ref.read(todoStorageProvider);
    final settings = await ref.watch(todoSettingsProvider.future);
    
    // 1. Prune old files
    await storage.pruneOldFiles(settings.historyRetentionDays);
    
    // 2. Load all todos
    final allTodos = await storage.loadAllTodos();
    
    // 3. Carry-over logic:
    // Incomplete tasks from previous days should stay in "Today" (but they keep their createdAt date)
    // Actually, "Today" view will show:
    // - Tasks created today
    // - Tasks created before today that are NOT done
    
    return TodoState(todos: allTodos);
  }

  Future<void> addTodo(String title, {
    TodoTimeBlock timeBlock = TodoTimeBlock.current,
    TodoDurationPreset durationPreset = TodoDurationPreset.min25,
    TodoPriority priority = TodoPriority.normal,
    String category = '',
    String notes = '',
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newItem = TodoItem(
      id: const Uuid().v4(),
      title: title,
      timeBlock: timeBlock,
      durationPreset: durationPreset,
      priority: priority,
      category: category,
      notes: notes,
      createdAt: DateTime.now(),
    );

    final List<TodoItem> updatedTodos = [...currentState.todos, newItem];
    state = AsyncData(currentState.copyWith(todos: updatedTodos));
    await ref.read(todoStorageProvider).saveTodos(updatedTodos);
  }

  Future<void> updateTodo(TodoItem updatedItem) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<TodoItem> updatedTodos = currentState.todos.map((t) => t.id == updatedItem.id ? updatedItem : t).toList();
    state = AsyncData(currentState.copyWith(todos: updatedTodos));
    await ref.read(todoStorageProvider).saveTodos(updatedTodos);
  }

  Future<void> deferTodo(String id, DateTime until) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<TodoItem> updatedTodos = currentState.todos.map((t) {
      if (t.id == id) {
        return t.copyWith(
          status: TodoStatus.deferred,
          deferredUntil: until,
        );
      }
      return t;
    }).toList();

    state = AsyncData(currentState.copyWith(todos: updatedTodos));
    await ref.read(todoStorageProvider).saveTodos(updatedTodos);
  }

  Future<void> deleteTodo(String id) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<TodoItem> updatedTodos = currentState.todos.where((t) => t.id != id).toList();
    state = AsyncData(currentState.copyWith(todos: updatedTodos));
    // Note: We'd need a way to delete from specific monthly files if we want to be clean.
    // For now, saveTodos handles updating the file where the item resided.
    // To truly delete, we might need a dedicated storage.deleteTodo(id, date).
    await ref.read(todoStorageProvider).saveTodos(updatedTodos);
  }

  void setTab(TodoTab tab) {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncData(currentState.copyWith(currentTab: tab));
  }
}

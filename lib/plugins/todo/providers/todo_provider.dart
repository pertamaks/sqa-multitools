import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';
import '../models/recurring_todo.dart';
import '../models/todo_state.dart';
import '../models/todo_settings.dart';
import 'todo_notification_provider.dart';
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
    final recurringTodos = await storage.loadRecurringTodos();
    
    final initialState = TodoState(
      todos: allTodos,
      recurringTodos: recurringTodos,
    );
    
    // 3. Sync recurring todos
    return _syncRecurringTodos(initialState, settings);
  }

  TodoState _syncRecurringTodos(TodoState currentState, TodoSettings settings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final List<TodoItem> newTodos = [...currentState.todos];
    final List<RecurringTodo> updatedRecurring = [];
    bool changed = false;

    for (final recurring in currentState.recurringTodos) {
      if (!recurring.isActive) {
        updatedRecurring.add(recurring);
        continue;
      }

      final lastGen = recurring.lastGeneratedDate != null 
          ? DateTime(recurring.lastGeneratedDate!.year, recurring.lastGeneratedDate!.month, recurring.lastGeneratedDate!.day)
          : null;

      // Skip if already generated today
      if (lastGen != null && lastGen.isAtSameMomentAs(today)) {
        updatedRecurring.add(recurring);
        continue;
      }

      bool shouldGenerate = false;
      switch (recurring.recurrenceType) {
        case RecurrenceType.daily:
          shouldGenerate = true;
          break;
        case RecurrenceType.weekdays:
          shouldGenerate = now.weekday >= 1 && now.weekday <= 5;
          break;
        case RecurrenceType.weekly:
          shouldGenerate = recurring.weeklyDays.contains(now.weekday);
          break;
        case RecurrenceType.everyNDays:
          if (lastGen == null) {
            shouldGenerate = true;
          } else {
            shouldGenerate = today.difference(lastGen).inDays >= recurring.everyNDays;
          }
          break;
      }

      if (shouldGenerate) {
        // Map hour to TimeBlock
        final timeBlock = ref.read<TodoNotification>(todoNotificationProvider.notifier).suggestTimeBlock(
          settings.wakeHour ?? 7, 
          settings.wakeMinute ?? 0, 
          DateTime(now.year, now.month, now.day, recurring.hour, recurring.minute),
        );
        
        final newItem = TodoItem(
          id: const Uuid().v4(),
          title: recurring.title,
          timeBlock: timeBlock,
          durationPreset: recurring.durationPreset,
          priority: recurring.priority,
          category: recurring.category,
          notes: recurring.notes,
          createdAt: DateTime(now.year, now.month, now.day, recurring.hour, recurring.minute),
        );
        newTodos.add(newItem);
        updatedRecurring.add(recurring.copyWith(lastGeneratedDate: now));
        changed = true;
      } else {
        updatedRecurring.add(recurring);
      }
    }

    if (changed) {
      ref.read(todoStorageProvider).saveTodos(newTodos);
      ref.read(todoStorageProvider).saveRecurringTodos(updatedRecurring);
      return currentState.copyWith(todos: newTodos, recurringTodos: updatedRecurring);
    }
    
    return currentState;
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

  Future<void> addRecurringTodo(RecurringTodo recurring) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<RecurringTodo> updated = [...currentState.recurringTodos, recurring];
    
    // Sync immediately if it should run today
    final settings = await ref.read(todoSettingsProvider.future);
    final newState = _syncRecurringTodos(currentState.copyWith(recurringTodos: updated), settings);
    
    state = AsyncData(newState);
    await ref.read(todoStorageProvider).saveRecurringTodos(newState.recurringTodos);
  }

  Future<void> updateRecurringTodo(RecurringTodo updatedItem) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<RecurringTodo> updated = currentState.recurringTodos.map((t) => t.id == updatedItem.id ? updatedItem : t).toList();
    state = AsyncData(currentState.copyWith(recurringTodos: updated));
    await ref.read(todoStorageProvider).saveRecurringTodos(updated);
  }

  Future<void> deleteRecurringTodo(String id) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<RecurringTodo> updated = currentState.recurringTodos.where((t) => t.id != id).toList();
    state = AsyncData(currentState.copyWith(recurringTodos: updated));
    await ref.read(todoStorageProvider).saveRecurringTodos(updated);
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
    await ref.read(todoStorageProvider).saveTodos(updatedTodos);
  }

  void setTab(TodoTab tab) {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncData(currentState.copyWith(currentTab: tab));
  }
}

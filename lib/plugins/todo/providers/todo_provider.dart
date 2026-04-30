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

    // 3. Auto-complete past recurring todos
    final autoCompleteState = _autoCompletePastRecurringTodos(initialState);

    // 4. Sync recurring todos
    final recurringSyncedState = _syncRecurringTodos(
      autoCompleteState,
      settings,
    );

    // 5. Sync deferred todos
    return _syncDeferredTodos(recurringSyncedState, settings);
  }

  TodoState _autoCompletePastRecurringTodos(TodoState currentState) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final List<TodoItem> updatedTodos = [];
    bool changed = false;

    for (final todo in currentState.todos) {
      if (todo.recurringTodoId != null &&
          todo.status != TodoStatus.done &&
          todo.status != TodoStatus.delegated) {
        final createdAtDate = DateTime(
          todo.createdAt.year,
          todo.createdAt.month,
          todo.createdAt.day,
        );

        // If it was created before today and is still pending, auto-complete it
        if (createdAtDate.isBefore(today)) {
          // Set completedAt to the end of its intended day so history stays accurate
          final endOfDay = DateTime(
            todo.createdAt.year,
            todo.createdAt.month,
            todo.createdAt.day,
            23,
            59,
            59,
          );

          updatedTodos.add(
            todo.copyWith(status: TodoStatus.done, completedAt: endOfDay),
          );
          changed = true;
          continue;
        }
      }
      updatedTodos.add(todo);
    }

    if (changed) {
      ref.read(todoStorageProvider).saveTodos(updatedTodos);
      return currentState.copyWith(todos: updatedTodos);
    }

    return currentState;
  }

  TodoState _syncDeferredTodos(TodoState currentState, TodoSettings settings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<TodoItem> updatedTodos = [];
    bool changed = false;

    for (final todo in currentState.todos) {
      if (todo.status == TodoStatus.deferred && todo.deferredUntil != null) {
        final deferredDate = DateTime(
          todo.deferredUntil!.year,
          todo.deferredUntil!.month,
          todo.deferredUntil!.day,
        );

        // If the deferred date is today or in the past, promote it back to the active block
        if (deferredDate.isBefore(today) ||
            deferredDate.isAtSameMomentAs(today)) {
          // Use the specific deferred time so it doesn't expire prematurely if scheduled for later today.
          // If deferred via DatePicker (midnight), fallback to 'now'.
          final bool isMidnight =
              todo.deferredUntil!.hour == 0 && todo.deferredUntil!.minute == 0;
          final targetCreatedAt = isMidnight
              ? now
              : DateTime(
                  now.year,
                  now.month,
                  now.day,
                  todo.deferredUntil!.hour,
                  todo.deferredUntil!.minute,
                );

          updatedTodos.add(
            todo.copyWith(
              status: TodoStatus.todo,
              deferredUntil: null,
              createdAt: targetCreatedAt,
              // Removed: timeBlock: TodoTimeBlock.current (so it retains its original time block like afternoon, evening, etc.)
            ),
          );
          changed = true;
          continue;
        }
      }
      updatedTodos.add(todo);
    }

    if (changed) {
      ref.read(todoStorageProvider).saveTodos(updatedTodos);
      return currentState.copyWith(todos: updatedTodos);
    }

    return currentState;
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
          ? DateTime(
              recurring.lastGeneratedDate!.year,
              recurring.lastGeneratedDate!.month,
              recurring.lastGeneratedDate!.day,
            )
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
            shouldGenerate =
                today.difference(lastGen).inDays >= recurring.everyNDays;
          }
          break;
      }

      if (shouldGenerate) {
        // Map hour to TimeBlock
        final timeBlock = ref
            .read<TodoNotification>(todoNotificationProvider.notifier)
            .suggestTimeBlock(
              settings.wakeHour ?? 7,
              settings.wakeMinute ?? 0,
              DateTime(
                now.year,
                now.month,
                now.day,
                recurring.hour,
                recurring.minute,
              ),
            );

        final newItem = TodoItem(
          id: const Uuid().v4(),
          title: recurring.title,
          timeBlock: timeBlock,
          durationPreset: recurring.durationPreset,
          priority: recurring.priority,
          category: recurring.category,
          notes: recurring.notes,
          createdAt: DateTime(
            now.year,
            now.month,
            now.day,
            recurring.hour,
            recurring.minute,
          ),
          recurringTodoId: recurring.id,
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
      return currentState.copyWith(
        todos: newTodos,
        recurringTodos: updatedRecurring,
      );
    }

    return currentState;
  }

  Future<void> addTodo(
    String title, {
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

    final List<RecurringTodo> updated = [
      ...currentState.recurringTodos,
      recurring,
    ];

    // Sync immediately if it should run today
    final settings = await ref.read(todoSettingsProvider.future);
    final newState = _syncRecurringTodos(
      currentState.copyWith(recurringTodos: updated),
      settings,
    );

    state = AsyncData(newState);
    await ref
        .read(todoStorageProvider)
        .saveRecurringTodos(newState.recurringTodos);
  }

  Future<void> updateRecurringTodo(RecurringTodo updatedItem) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<RecurringTodo> updated = currentState.recurringTodos
        .map((t) => t.id == updatedItem.id ? updatedItem : t)
        .toList();
    state = AsyncData(currentState.copyWith(recurringTodos: updated));
    await ref.read(todoStorageProvider).saveRecurringTodos(updated);
  }

  Future<void> deleteRecurringTodo(String id) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<RecurringTodo> updated = currentState.recurringTodos
        .where((t) => t.id != id)
        .toList();
    state = AsyncData(currentState.copyWith(recurringTodos: updated));
    await ref.read(todoStorageProvider).saveRecurringTodos(updated);
  }

  Future<void> updateTodo(TodoItem updatedItem) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<TodoItem> updatedTodos = currentState.todos
        .map((t) => t.id == updatedItem.id ? updatedItem : t)
        .toList();
    state = AsyncData(currentState.copyWith(todos: updatedTodos));
    await ref.read(todoStorageProvider).saveTodos(updatedTodos);
  }

  Future<void> deferTodo(String id, DateTime until) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<TodoItem> updatedTodos = currentState.todos.map((t) {
      if (t.id == id) {
        return t.copyWith(status: TodoStatus.deferred, deferredUntil: until);
      }
      return t;
    }).toList();

    state = AsyncData(currentState.copyWith(todos: updatedTodos));
    await ref.read(todoStorageProvider).saveTodos(updatedTodos);
  }

  Future<void> deleteTodo(String id) async {
    final currentState = state.value;
    if (currentState == null) return;

    final List<TodoItem> updatedTodos = currentState.todos
        .where((t) => t.id != id)
        .toList();
    state = AsyncData(currentState.copyWith(todos: updatedTodos));
    await ref.read(todoStorageProvider).saveTodos(updatedTodos);
  }

  void setTab(TodoTab tab) {
    final currentState = state.value;
    if (currentState == null) return;
    state = AsyncData(currentState.copyWith(currentTab: tab));
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqa_multitools/plugins/todo/models/todo_item.dart';
import 'package:sqa_multitools/plugins/todo/models/todo_settings.dart';
import 'package:sqa_multitools/plugins/todo/models/recurring_todo.dart';
import 'package:sqa_multitools/plugins/todo/providers/todo_provider.dart';
import 'package:sqa_multitools/plugins/todo/services/todo_storage_service.dart';

import 'todo_provider_test.mocks.dart';

@GenerateMocks([TodoStorageService])
void main() {
  late MockTodoStorageService mockStorage;
  late ProviderContainer container;

  setUp(() {
    mockStorage = MockTodoStorageService();
    
    // Default mock behavior
    when(mockStorage.loadSettings()).thenAnswer((_) async => const TodoSettings());
    when(mockStorage.loadAllTodos()).thenAnswer((_) async => []);
    when(mockStorage.loadRecurringTodos()).thenAnswer((_) async => []);
    when(mockStorage.pruneOldFiles(any)).thenAnswer((_) async {});
    when(mockStorage.saveTodos(any)).thenAnswer((_) async {});
    when(mockStorage.saveRecurringTodos(any)).thenAnswer((_) async {});
    when(mockStorage.saveSettings(any)).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        todoStorageProvider.overrideWithValue(mockStorage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Todo Provider - Initialization', () {
    test('initializes with empty data', () async {
      final state = await container.read(todoProvider.future);
      
      expect(state.todos, isEmpty);
      expect(state.recurringTodos, isEmpty);
      verify(mockStorage.loadSettings()).called(1);
      verify(mockStorage.loadAllTodos()).called(1);
    });

    test('prunes old files on build', () async {
      when(mockStorage.loadSettings()).thenAnswer((_) async => const TodoSettings(historyRetentionDays: 30));
      
      await container.read(todoProvider.future);
      
      verify(mockStorage.pruneOldFiles(30)).called(1);
    });
  });

  group('Todo Provider - CRUD', () {
    test('addTodo adds a new item and saves it', () async {
      await container.read(todoProvider.future);
      final notifier = container.read(todoProvider.notifier);

      await notifier.addTodo('Test Task');

      final state = container.read(todoProvider).value!;
      expect(state.todos.length, 1);
      expect(state.todos.first.title, 'Test Task');
      verify(mockStorage.saveTodos(any)).called(1);
    });

    test('updateTodo updates an item and saves it', () async {
      final initialTodo = TodoItem(
        id: '1',
        title: 'Initial',
        createdAt: DateTime.now(),
      );
      when(mockStorage.loadAllTodos()).thenAnswer((_) async => [initialTodo]);

      await container.read(todoProvider.future);
      final notifier = container.read(todoProvider.notifier);

      final updatedTodo = initialTodo.copyWith(title: 'Updated');
      await notifier.updateTodo(updatedTodo);

      final state = container.read(todoProvider).value!;
      expect(state.todos.first.title, 'Updated');
      verify(mockStorage.saveTodos(argThat(
        predicate<List<TodoItem>>((list) => list.first.title == 'Updated'),
      ))).called(1);
    });

    test('deleteTodo removes an item and saves it', () async {
      final todo = TodoItem(
        id: '1',
        title: 'Delete Me',
        createdAt: DateTime.now(),
      );
      when(mockStorage.loadAllTodos()).thenAnswer((_) async => [todo]);

      await container.read(todoProvider.future);
      final notifier = container.read(todoProvider.notifier);

      await notifier.deleteTodo('1');

      final state = container.read(todoProvider).value!;
      expect(state.todos, isEmpty);
      verify(mockStorage.saveTodos([])).called(1);
    });
   group('Todo Provider - Deferred Sync', () {
    test('promotes deferred todos if date is today', () async {
      final now = DateTime.now();
      final deferredTodo = TodoItem(
        id: '1',
        title: 'Deferred',
        status: TodoStatus.deferred,
        deferredUntil: now.subtract(const Duration(hours: 1)), // Past
        createdAt: now.subtract(const Duration(days: 1)),
      );
      when(mockStorage.loadAllTodos()).thenAnswer((_) async => [deferredTodo]);

      final state = await container.read(todoProvider.future);

      expect(state.todos.first.status, TodoStatus.todo);
      expect(state.todos.first.deferredUntil, isNull);
      verify(mockStorage.saveTodos(any)).called(1);
    });
  });

  group('Todo Provider - Recurring Sync', () {
    test('generates daily recurring todo', () async {
      final recurring = RecurringTodo(
        id: 'rec1',
        title: 'Daily Task',
        recurrenceType: RecurrenceType.daily,
        isActive: true,
        hour: 9,
        minute: 0,
      );
      when(mockStorage.loadRecurringTodos()).thenAnswer((_) async => [recurring]);

      final state = await container.read(todoProvider.future);

      expect(state.todos.length, 1);
      expect(state.todos.first.title, 'Daily Task');
      expect(state.todos.first.recurringTodoId, 'rec1');
      verify(mockStorage.saveTodos(any)).called(1);
      verify(mockStorage.saveRecurringTodos(any)).called(1);
    });

    test('does not generate recurring if already generated today', () async {
      final now = DateTime.now();
      final recurring = RecurringTodo(
        id: 'rec1',
        title: 'Daily Task',
        recurrenceType: RecurrenceType.daily,
        isActive: true,
        hour: 9,
        minute: 0,
        lastGeneratedDate: now,
      );
      when(mockStorage.loadRecurringTodos()).thenAnswer((_) async => [recurring]);

      final state = await container.read(todoProvider.future);

      expect(state.todos, isEmpty);
    });
  });

  group('Todo Provider - Auto-completion', () {
    test('auto-completes past pending recurring tasks', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final oldRecurringItem = TodoItem(
        id: 'old1',
        title: 'Yesterday Task',
        createdAt: yesterday,
        recurringTodoId: 'rec1',
        status: TodoStatus.todo,
      );
      when(mockStorage.loadAllTodos()).thenAnswer((_) async => [oldRecurringItem]);

      final state = await container.read(todoProvider.future);

      expect(state.todos.first.status, TodoStatus.done);
      expect(state.todos.first.completedAt, isNotNull);
      verify(mockStorage.saveTodos(any)).called(1);
    });
  });
  });
}

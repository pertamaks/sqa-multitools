import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo_item.dart';
import '../models/todo_settings.dart';
import '../models/recurring_todo.dart';

class TodoStorageService {
  static const String _folderName = 'SQA_Todo';
  static const String _settingsFile = 'todo_settings.json';
  static const String _recurringFile = 'recurring_todos.json';

  Future<Directory> get _storageDir async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${docsDir.path}${Platform.pathSeparator}$_folderName',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _getFileNameForDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    return 'todo_data_${year}_$month.json';
  }

  /// Saves a list of todos to the appropriate monthly file.
  /// It groups the provided todos by month and updates the corresponding files.
  Future<void> saveTodos(List<TodoItem> todos) async {
    final dir = await _storageDir;

    // Group todos by month
    final Map<String, List<TodoItem>> grouped = {};
    for (final todo in todos) {
      final fileName = _getFileNameForDate(todo.createdAt);
      grouped.putIfAbsent(fileName, () => []).add(todo);
    }

    // Update each file
    for (final entry in grouped.entries) {
      final file = File('${dir.path}${Platform.pathSeparator}${entry.key}');

      // We need to load existing todos from that file that ARE NOT in the current set
      // to avoid wiping out other days in the same month if we are only saving a partial list.
      // But usually, we'll pass the full active list.
      // For simplicity in this plugin, we'll assume the provider gives us the context needed.
      // A better way: Load the file, merge, and save.

      List<TodoItem> existing = [];
      if (await file.exists()) {
        try {
          final jsonList =
              jsonDecode(await file.readAsString()) as List<dynamic>;
          existing = jsonList
              .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (_) {}
      }

      // Merge: Update existing or add new
      final Map<String, TodoItem> mergedMap = {for (var t in existing) t.id: t};
      for (var t in entry.value) {
        mergedMap[t.id] = t;
      }

      final jsonContent = jsonEncode(
        mergedMap.values.map((e) => e.toJson()).toList(),
      );
      await file.writeAsString(jsonContent);
    }
  }

  Future<List<TodoItem>> loadAllTodos() async {
    final dir = await _storageDir;
    final List<TodoItem> allTodos = [];

    await for (final entity in dir.list()) {
      if (entity is File &&
          entity.path.contains('todo_data_') &&
          entity.path.endsWith('.json')) {
        try {
          final jsonList =
              jsonDecode(await entity.readAsString()) as List<dynamic>;
          allTodos.addAll(
            jsonList.map((e) => TodoItem.fromJson(e as Map<String, dynamic>)),
          );
        } catch (_) {}
      }
    }
    return allTodos;
  }

  Future<void> saveRecurringTodos(List<RecurringTodo> recurring) async {
    final dir = await _storageDir;
    final file = File('${dir.path}${Platform.pathSeparator}$_recurringFile');
    final jsonContent = jsonEncode(recurring.map((e) => e.toJson()).toList());
    await file.writeAsString(jsonContent);
  }

  Future<List<RecurringTodo>> loadRecurringTodos() async {
    final dir = await _storageDir;
    final file = File('${dir.path}${Platform.pathSeparator}$_recurringFile');
    if (await file.exists()) {
      try {
        final jsonList = jsonDecode(await file.readAsString()) as List<dynamic>;
        return jsonList
            .map((e) => RecurringTodo.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> saveSettings(TodoSettings settings) async {
    final dir = await _storageDir;
    final file = File('${dir.path}${Platform.pathSeparator}$_settingsFile');
    await file.writeAsString(jsonEncode(settings.toJson()));
  }

  Future<TodoSettings> loadSettings() async {
    final dir = await _storageDir;
    final file = File('${dir.path}${Platform.pathSeparator}$_settingsFile');
    if (await file.exists()) {
      try {
        return TodoSettings.fromJson(
          jsonDecode(await file.readAsString()) as Map<String, dynamic>,
        );
      } catch (_) {}
    }
    return const TodoSettings();
  }

  /// Prunes old monthly files based on retention settings.
  Future<void> pruneOldFiles(int retentionDays) async {
    if (retentionDays < 0) return; // Forever

    final dir = await _storageDir;
    final now = DateTime.now();
    final threshold = now.subtract(Duration(days: retentionDays));

    await for (final entity in dir.list()) {
      if (entity is File &&
          entity.path.contains('todo_data_') &&
          entity.path.endsWith('.json')) {
        // Extract year and month from filename: todo_data_YYYY_MM.json
        final baseName = entity.uri.pathSegments.last;
        final parts = baseName.replaceFirst('.json', '').split('_');
        if (parts.length >= 4) {
          final year = int.tryParse(parts[2]);
          final month = int.tryParse(parts[3]);
          if (year != null && month != null) {
            // The file represents a month. We consider it "old" if the LAST day of that month is before threshold.
            final lastDayOfMonth = DateTime(year, month + 1, 0);
            if (lastDayOfMonth.isBefore(threshold)) {
              await entity.delete();
            }
          }
        }
      }
    }
  }
}

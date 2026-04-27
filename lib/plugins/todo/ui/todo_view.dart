import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../models/todo_state.dart';
import '../models/todo_item.dart';
import 'widgets/todo_list_item.dart';
import 'widgets/todo_editor_dialog.dart';
import 'widgets/wake_time_prompt.dart';
import '../../../core/providers/plugin_provider.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import 'package:material_symbols_icons/symbols.dart';

class TodoView extends ConsumerStatefulWidget {
  const TodoView({super.key});

  @override
  ConsumerState<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends ConsumerState<TodoView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(todoProvider.notifier).setTab(
          _tabController.index == 0 ? TodoTab.today : TodoTab.history,
        );
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WakeTimePrompt.showIfNeeded(context, ref);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoStateAsync = ref.watch(todoProvider);
    final history = ref.watch(navigationHistoryProvider);
    final showBack = history != null;

    return todoStateAsync.when(
      data: (state) => _buildContent(context, state, showBack),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(BuildContext context, TodoState state, bool showBack) {
    final theme = Theme.of(context);
    
    return SqaPluginLayout(
      icon: showBack ? null : Symbols.checklist,
      title: 'Todo List',
      description: 'Cognitive energy-aware focus blocks',
      onBack: showBack ? () => ref.read(navigationServiceProvider).goBack() : null,
      tabs: const [
        Tab(text: 'Today'),
        Tab(text: 'History'),
      ],
      tabController: _tabController,
      trailing: SqaButton(
        label: 'Add Task',
        icon: Symbols.add,
        onPressed: () => _showAddTodoDialog(context),
        type: SqaButtonType.primary,
      ),
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayList(context, state),
          _buildHistoryList(context, state),
        ],
      ),
    );
  }

  Widget _buildTodayList(BuildContext context, TodoState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Today view: Tasks created today OR incomplete tasks from the past
    final todayTodos = state.todos.where((t) {
      final createdDate = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      return createdDate.isAtSameMomentAs(today) || t.status != TodoStatus.done;
    }).toList();

    // Sort: Incomplete first, then by priority, then by time block
    todayTodos.sort((a, b) {
      if (a.status != b.status) {
        return a.status == TodoStatus.done ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      return a.timeBlock.index.compareTo(b.timeBlock.index);
    });

    if (todayTodos.isEmpty) {
      return const Center(child: Text('No tasks for today. Time to rest?'));
    }

    return SqaPluginScrollableContent(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        itemCount: todayTodos.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = todayTodos[index];
          return TodoListItem(
            item: item,
            onToggle: () {
              final newStatus = item.status == TodoStatus.done ? TodoStatus.todo : TodoStatus.done;
              ref.read(todoProvider.notifier).updateTodo(
                item.copyWith(
                  status: newStatus,
                  completedAt: newStatus == TodoStatus.done ? DateTime.now() : null,
                ),
              );
            },
            onDelete: () => ref.read(todoProvider.notifier).deleteTodo(item.id),
            onTap: () => TodoEditorDialog.show(context, item: item),
          );
        },
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, TodoState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // History view: Completed tasks before today
    final historyTodos = state.todos.where((t) {
      final createdDate = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      return createdDate.isBefore(today) && t.status == TodoStatus.done;
    }).toList();

    if (historyTodos.isEmpty) {
      return const Center(child: Text('No history yet.'));
    }

    // Group by date
    final Map<DateTime, List<TodoItem>> grouped = {};
    for (final t in historyTodos) {
      final date = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      grouped.putIfAbsent(date, () => []).add(t);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return SqaPluginScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sortedDates.map((date) {
            final items = grouped[date]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    '${date.year}-${date.month}-${date.day}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TodoListItem(item: item),
                )),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    TodoEditorDialog.show(context);
  }
}

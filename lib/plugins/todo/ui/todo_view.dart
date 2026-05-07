import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../providers/todo_notification_provider.dart';
import '../models/todo_state.dart';
import '../models/todo_item.dart';
import 'widgets/todo_list_item.dart';
import 'widgets/todo_editor_dialog.dart';
import 'widgets/recurring_todo_editor_dialog.dart';
import 'widgets/recurring_todo_item.dart';
import 'widgets/wake_time_prompt.dart';
import 'widgets/todo_history_view.dart';
import 'widgets/todo_list_group.dart';
import '../../../core/providers/plugin_provider.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_toast.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_date_picker.dart';

class TodoView extends ConsumerStatefulWidget {
  const TodoView({super.key});

  @override
  ConsumerState<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends ConsumerState<TodoView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(todoProvider).value?.searchQuery ?? '',
    );
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(todoProvider.notifier)
            .setTab(TodoTab.values[_tabController.index]);
        setState(() {}); // Rebuild to update trailing button label
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      WakeTimePrompt.showIfNeeded(context, ref);
      ref.read(todoNotificationProvider.notifier).clearReminder();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoStateAsync = ref.watch(todoProvider);
    final history = ref.watch(navigationHistoryProvider);
    final showBack = history != null;

    return todoStateAsync.when(
      data: (TodoState state) => _buildContent(context, state, showBack),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, StackTrace st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildContent(BuildContext context, TodoState state, bool showBack) {
    return SqaPluginLayout(
      icon: showBack ? null : Symbols.blur_on,
      title: 'Focus Block',
      description: 'Cognitive energy-aware focus blocks',
      onBack: showBack
          ? () => ref.read(navigationServiceProvider).goBack()
          : null,
      tabs: [
        Tab(
          text: DateFormat('EEEE, MMM d').format(DateTime.now()),
          icon: const Icon(Symbols.today),
        ),
        const Tab(text: 'Recurring', icon: Icon(Symbols.sync)),
        const Tab(text: 'History', icon: Icon(Symbols.history)),
      ],
      tabController: _tabController,
      trailing: _tabController.index == 2
          ? null
          : SqaButton(
              label: _tabController.index == 1 ? '' : '',
              icon: Symbols.blur_on,
              onPressed: () => _showAddTodoDialog(context),
              type: SqaButtonType.primary,
              tooltip: _tabController.index == 1 ? 'Add Recurring Focus' : 'Add Focus',
            ),
      searchController: _searchController,
      onSearchChanged: (val) =>
          ref.read(todoProvider.notifier).setSearchQuery(val),
      searchHint: 'Filter tasks...',
      filterOptions: _tabController.index == 2
          ? _buildHistoryFilters(state)
          : null,
      isFilterActive: state.historyFilter != HistoryFilter.last7Days,
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildTodayList(context, state),
          _buildRecurringList(context, state),
          _buildHistoryList(context, state),
        ],
      ),
    );
  }

  Widget _buildTodayList(BuildContext context, TodoState state) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final theme = Theme.of(context);
    final query = (state.searchQuery).toLowerCase();

    // Today view: Tasks created today OR incomplete tasks from the past
    // BUT excluding deferred tasks
    var todayTodos = state.todos.where((t) {
      final createdDate = DateTime(
        t.createdAt.year,
        t.createdAt.month,
        t.createdAt.day,
      );
      final isTerminal =
          t.status == TodoStatus.done ||
          t.status == TodoStatus.delegated ||
          t.status == TodoStatus.exception ||
          t.status == TodoStatus.cancelled;
      final isActuallyToday =
          createdDate.isAtSameMomentAs(today) || !isTerminal;
      return isActuallyToday && t.status != TodoStatus.deferred;
    }).toList();

    if (query.isNotEmpty) {
      todayTodos = todayTodos
          .where(
            (t) =>
                (t.title).toLowerCase().contains(query) ||
                (t.notes).toLowerCase().contains(query) ||
                (t.category).toLowerCase().contains(query),
          )
          .toList();
    }

    final pending = todayTodos
        .where(
          (t) =>
              t.status != TodoStatus.done &&
              t.status != TodoStatus.delegated &&
              t.status != TodoStatus.exception &&
              t.status != TodoStatus.cancelled,
        )
        .toList();

    // Split pending into active and timesUp
    final timesUp = pending.where((t) {
      final createdAtDate = DateTime(
        t.createdAt.year,
        t.createdAt.month,
        t.createdAt.day,
      );
      final isToday = createdAtDate.isAtSameMomentAs(today);
      if (!isToday) return false;
      final duration = t.durationPreset.minutes;
      final endTime = t.createdAt.add(Duration(minutes: duration));
      return now.isAfter(endTime);
    }).toList();

    final active = pending.where((t) => !timesUp.contains(t)).toList();

    final completed = todayTodos
        .where(
          (t) =>
              t.status == TodoStatus.done ||
              t.status == TodoStatus.delegated ||
              t.status == TodoStatus.exception ||
              t.status == TodoStatus.cancelled,
        )
        .toList();

    final deferredTodos = state.todos
        .where((t) => t.status == TodoStatus.deferred)
        .toList();

    // Sort pending items
    pending.sort((a, b) {
      // 'Do Now' focuses (Critical Priority + Current Time Block) go to the absolute top
      final aDoNow =
          a.priority == TodoPriority.critical &&
          a.timeBlock == TodoTimeBlock.current;
      final bDoNow =
          b.priority == TodoPriority.critical &&
          b.timeBlock == TodoTimeBlock.current;
      if (aDoNow != bDoNow) {
        return aDoNow ? -1 : 1;
      }

      final aDate = DateTime(
        a.createdAt.year,
        a.createdAt.month,
        a.createdAt.day,
      );
      final bDate = DateTime(
        b.createdAt.year,
        b.createdAt.month,
        b.createdAt.day,
      );
      final aOverdue = aDate.isBefore(today);
      final bOverdue = bDate.isBefore(today);

      if (aOverdue != bOverdue) {
        return aOverdue ? -1 : 1;
      }

      if (a.timeBlock != b.timeBlock) {
        return a.timeBlock.index.compareTo(b.timeBlock.index);
      }
      return b.priority.index.compareTo(a.priority.index);
    });

    // Sort completed items by completion time (most recent first)
    completed.sort((a, b) {
      final aTime = a.completedAt ?? a.createdAt;
      final bTime = b.completedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });

    if (pending.isEmpty && completed.isEmpty && deferredTodos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.wb_sunny,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No focus created for today.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add a new focus block to get started.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SqaPluginScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (active.isNotEmpty) ...[
              TodoListSectionHeader(
                icon: Symbols.bolt,
                title: 'Active Focus',
                count: active.length,
                isPrimary: true,
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: active.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = active[index];
                  return TodoListItem(
                    item: item,
                    displayIndex: index,
                    onToggle: () => _toggleTodo(item),
                    onDelete: () => _deleteTodo(context, item),
                    onTap: () => TodoEditorDialog.show(context, item: item),
                  );
                },
              ),
            ] else if (timesUp.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: SqaStyles.radiusLarge,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Symbols.verified,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All Caught Up!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have completed all active focus blocks.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (timesUp.isNotEmpty) ...[
              if (active.isNotEmpty) const SizedBox(height: 16),
              TodoExpansionGroup(
                icon: Symbols.alarm_off,
                title: "Time's Up — How did it go?",
                items: timesUp,
                onToggle: _toggleTodo,
                onDelete: (item) => _deleteTodo(context, item),
                onTap: (item) => TodoEditorDialog.show(context, item: item),
              ),
            ],
            if (completed.isNotEmpty) ...[
              const SizedBox(height: 16),
              TodoExpansionGroup(
                icon: Symbols.check_circle,
                title: 'Completed Focus Blocks',
                items: completed,
                opacity: 0.7,
                onToggle: (item) {
                  ref
                      .read(todoProvider.notifier)
                      .updateTodo(
                        item.copyWith(
                          status: TodoStatus.todo,
                          completedAt: null,
                          delegatedTo: '',
                        ),
                      );
                },
                onDelete: (item) => _deleteTodo(context, item),
                onTap: (item) => TodoEditorDialog.show(context, item: item),
              ),
            ],
            if (deferredTodos.isNotEmpty) ...[
              const SizedBox(height: 16),
              TodoExpansionGroup(
                icon: Symbols.schedule_send,
                title: 'Deferred Focus Blocks',
                items: deferredTodos,
                opacity: 0.7,
                onToggle: (item) {
                  ref
                      .read(todoProvider.notifier)
                      .updateTodo(
                        item.copyWith(
                          status: TodoStatus.todo,
                          deferredUntil: null,
                          createdAt: DateTime.now(),
                          timeBlock: TodoTimeBlock.current,
                          priority: TodoPriority.critical,
                        ),
                      );
                },
                onDelete: (item) => _deleteTodo(context, item),
                onTap: (item) => TodoEditorDialog.show(context, item: item),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _toggleTodo(TodoItem item) {
    final newStatus = item.status == TodoStatus.done
        ? TodoStatus.todo
        : TodoStatus.done;
    ref
        .read(todoProvider.notifier)
        .updateTodo(
          item.copyWith(
            status: newStatus,
            completedAt: newStatus == TodoStatus.done ? DateTime.now() : null,
          ),
        );
  }

  Future<void> _deleteTodo(BuildContext context, TodoItem item) async {
    final confirmed = await SqaModal.showDanger(
      context,
      title: 'Delete Focus',
      message:
          'Are you sure you want to delete "${item.title}"? This action cannot be undone.',
    );
    if (confirmed == true) {
      ref.read(todoProvider.notifier).deleteTodo(item.id);
      if (context.mounted) {
        SqaToast.show(context, 'Focus deleted.');
      }
    }
  }

  Widget _buildHistoryList(BuildContext context, TodoState state) {
    final query = state.searchQuery.toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // History view: Completed tasks before today
    var historyTodos = state.todos.where((t) {
      if (t.status != TodoStatus.done || t.completedAt == null) return false;

      final completedDate = DateTime(
        t.completedAt!.year,
        t.completedAt!.month,
        t.completedAt!.day,
      );

      // Apply History Filter
      switch (state.historyFilter) {
        case HistoryFilter.last7Days:
          final cutoff = today.subtract(const Duration(days: 7));
          if (!completedDate.isAfter(cutoff) &&
              !completedDate.isAtSameMomentAs(cutoff)) {
            return false;
          }
          break;
        case HistoryFilter.thisMonth:
          if (completedDate.year != today.year ||
              completedDate.month != today.month) {
            return false;
          }
          break;
        case HistoryFilter.lastMonth:
          final lastMonth = today.month == 1 ? 12 : today.month - 1;
          final lastMonthYear = today.month == 1 ? today.year - 1 : today.year;
          if (completedDate.year != lastMonthYear ||
              completedDate.month != lastMonth) {
            return false;
          }
          break;
        case HistoryFilter.custom:
          if (state.customDateRange == null) {
            break;
          }
          if (!((completedDate.isAfter(state.customDateRange!.start) ||
                  completedDate.isAtSameMomentAs(
                    state.customDateRange!.start,
                  )) &&
              (completedDate.isBefore(state.customDateRange!.end) ||
                  completedDate.isAtSameMomentAs(
                    state.customDateRange!.end,
                  )))) {
            return false;
          }
          break;
      }

      return true;
    }).toList();

    if (query.isNotEmpty) {
      historyTodos = historyTodos
          .where(
            (t) =>
                t.title.toLowerCase().contains(query) ||
                t.notes.toLowerCase().contains(query) ||
                t.category.toLowerCase().contains(query),
          )
          .toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TodoHistoryView(historyTodos: historyTodos),
    );
  }

  Widget _buildHistoryFilters(TodoState state) {
    return Row(
      children: [
        Expanded(
          child: SqaSegmentedButton<HistoryFilter>(
            stretches: true,
            storageKey: 'todo_history_filter',
            segments: const [
              ButtonSegment(
                value: HistoryFilter.last7Days,
                label: Text('Last 7 Days'),
              ),
              ButtonSegment(
                value: HistoryFilter.thisMonth,
                label: Text('This Month'),
              ),
              ButtonSegment(
                value: HistoryFilter.lastMonth,
                label: Text('Last Month'),
              ),
              ButtonSegment(value: HistoryFilter.custom, label: Text('Custom')),
            ],
            selected: {state.historyFilter},
            onSelectionChanged: (set) async {
              final filter = set.first;
              if (filter == HistoryFilter.custom) {
                final range = await SqaDatePicker.showRange(
                  context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: state.customDateRange,
                );
                if (range != null) {
                  ref.read(todoProvider.notifier).setHistoryFilter(filter);
                  ref.read(todoProvider.notifier).setCustomDateRange(range);
                }
              } else {
                ref.read(todoProvider.notifier).setHistoryFilter(filter);
              }
            },
          ),
        ),
        if (state.historyFilter == HistoryFilter.custom &&
            state.customDateRange != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: const Icon(Symbols.calendar_today, size: 20),
              color: Theme.of(context).colorScheme.primary,
              tooltip:
                  '${DateFormat('MMM d, y').format(state.customDateRange!.start)} - ${DateFormat('MMM d, y').format(state.customDateRange!.end)}',
              onPressed: () async {
                final range = await SqaDatePicker.showRange(
                  context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: state.customDateRange,
                );
                if (range != null) {
                  ref.read(todoProvider.notifier).setCustomDateRange(range);
                }
              },
            ),
          ),
      ],
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    if (_tabController.index == 1) {
      RecurringTodoEditorDialog.show(context);
    } else {
      TodoEditorDialog.show(context);
    }
  }

  Widget _buildRecurringList(BuildContext context, TodoState state) {
    var recurring = state.recurringTodos;
    final query = state.searchQuery.toLowerCase();

    if (query.isNotEmpty) {
      recurring = recurring
          .where(
            (t) =>
                t.title.toLowerCase().contains(query) ||
                t.notes.toLowerCase().contains(query) ||
                t.category.toLowerCase().contains(query),
          )
          .toList();
    }

    if (recurring.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.sync,
              size: 48,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            const Text('No recurring focus blocks yet.'),
            const SizedBox(height: 8),
            const Text(
              'Add one to auto-generate focus blocks daily.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SqaPluginScrollableContent(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TodoListSectionHeader(
              icon: Symbols.sync,
              title: 'Recurring Agendas',
              count: recurring.length,
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recurring.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return RecurringTodoItem(item: recurring[index]);
              },
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/todo_item.dart';
import '../../models/todo_state.dart';
import '../../../../ui/widgets/sqa_search_filter_bar.dart';
import '../../../../ui/widgets/sqa_segmented_button.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../../ui/widgets/sqa_date_picker.dart';
import 'todo_list_item.dart';

class TodoHistoryView extends ConsumerStatefulWidget {
  final List<TodoItem> historyTodos;

  const TodoHistoryView({super.key, required this.historyTodos});

  @override
  ConsumerState<TodoHistoryView> createState() => _TodoHistoryViewState();
}

class _TodoHistoryViewState extends ConsumerState<TodoHistoryView> {
  String _searchQuery = '';
  HistoryFilter _selectedFilter = HistoryFilter.last7Days;
  DateTimeRange? _customDateRange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 1. Filter Data
    var filtered = widget.historyTodos;

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((t) => t.title.toLowerCase().contains(q) || t.category.toLowerCase().contains(q) || t.notes.toLowerCase().contains(q)).toList();
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    filtered = filtered.where((t) {
      if (t.completedAt == null) return false;
      final completedDate = DateTime(t.completedAt!.year, t.completedAt!.month, t.completedAt!.day);

      switch (_selectedFilter) {
        case HistoryFilter.last7Days:
          final cutoff = today.subtract(const Duration(days: 7));
          return completedDate.isAfter(cutoff) || completedDate.isAtSameMomentAs(cutoff);
        case HistoryFilter.thisMonth:
          return completedDate.year == today.year && completedDate.month == today.month;
        case HistoryFilter.lastMonth:
          final lastMonth = today.month == 1 ? 12 : today.month - 1;
          final lastMonthYear = today.month == 1 ? today.year - 1 : today.year;
          return completedDate.year == lastMonthYear && completedDate.month == lastMonth;
        case HistoryFilter.custom:
          if (_customDateRange == null) return true;
          return (completedDate.isAfter(_customDateRange!.start) || completedDate.isAtSameMomentAs(_customDateRange!.start)) &&
                 (completedDate.isBefore(_customDateRange!.end) || completedDate.isAtSameMomentAs(_customDateRange!.end));
      }
    }).toList();

    // Group by Date
    final Map<DateTime, List<TodoItem>> grouped = {};
    for (final t in filtered) {
      final date = DateTime(t.completedAt!.year, t.completedAt!.month, t.completedAt!.day);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(t);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        // Top Bar
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SqaSearchFilterBar(
            hintText: 'Search history...',
            onChanged: (val) => setState(() => _searchQuery = val),
            isFilterActive: _selectedFilter != HistoryFilter.last7Days,
            filterOptions: Row(
              children: [
                Expanded(
                  child: SqaSegmentedButton<HistoryFilter>(
                    stretches: true,
                    segments: const [
                      ButtonSegment(value: HistoryFilter.last7Days, label: Text('Last 7 Days')),
                      ButtonSegment(value: HistoryFilter.thisMonth, label: Text('This Month')),
                      ButtonSegment(value: HistoryFilter.lastMonth, label: Text('Last Month')),
                      ButtonSegment(value: HistoryFilter.custom, label: Text('Custom')),
                    ],
                    selected: {_selectedFilter},
                  onSelectionChanged: (set) async {
                    final filter = set.first;
                    if (filter == HistoryFilter.custom) {
                      final range = await SqaDatePicker.showRange(
                        context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: _customDateRange,
                      );
                      if (range != null) {
                        setState(() {
                          _selectedFilter = filter;
                          _customDateRange = range;
                        });
                      }
                    } else {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    }
                  },
                ),
              ),
              if (_selectedFilter == HistoryFilter.custom && _customDateRange != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: IconButton(
                      icon: const Icon(Symbols.calendar_today, size: 20),
                      color: colorScheme.primary,
                      tooltip: '${DateFormat('MMM d, y').format(_customDateRange!.start)} - ${DateFormat('MMM d, y').format(_customDateRange!.end)}',
                      onPressed: () async {
                        final range = await SqaDatePicker.showRange(
                          context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: _customDateRange,
                        );
                        if (range != null) {
                          setState(() {
                            _customDateRange = range;
                          });
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        
        // Timeline
        Expanded(
          child: SqaPluginScrollableContent(
            child: sortedDates.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Symbols.history, size: 48, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No history found for this period.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final items = grouped[date]!;
                      
                      // Auto-expand the most recent 3 dates, collapse older ones
                      final initiallyExpanded = index < 3;

                      return SqaCard(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: EdgeInsets.zero,
                        child: Theme(
                          data: theme.copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            initiallyExpanded: initiallyExpanded,
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            title: Row(
                              children: [
                                Icon(Symbols.calendar_today, size: 18, color: colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  date.isAtSameMomentAs(today) 
                                      ? 'Today' 
                                      : date.isAtSameMomentAs(today.subtract(const Duration(days: 1)))
                                          ? 'Yesterday'
                                          : DateFormat('EEEE, MMM d, y').format(date),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${items.length} ${items.length == 1 ? 'task' : 'tasks'}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onPrimaryContainer,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            children: items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TodoListItem(
                                  item: item,
                                  // Read only view for history
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

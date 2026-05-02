import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/todo_item.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import 'todo_list_item.dart';

class TodoHistoryView extends ConsumerStatefulWidget {
  final List<TodoItem> historyTodos;

  const TodoHistoryView({super.key, required this.historyTodos});

  @override
  ConsumerState<TodoHistoryView> createState() => _TodoHistoryViewState();
}

class _TodoHistoryViewState extends ConsumerState<TodoHistoryView> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Group by Date
    final Map<DateTime, List<TodoItem>> grouped = {};
    for (final t in widget.historyTodos) {
      if (t.completedAt == null) continue;
      final date = DateTime(
        t.completedAt!.year,
        t.completedAt!.month,
        t.completedAt!.day,
      );
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(t);
    }

    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return SqaPluginScrollableContent(
      child: sortedDates.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.history,
                      size: 48,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No history found for this period.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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

                      int lateCount = 0;
                      for (final item in items) {
                        if (item.completedAt != null) {
                          final duration = item.durationPreset.minutes;
                          final endTime = item.createdAt.add(
                            Duration(minutes: duration),
                          );
                          if (!item.completedAt!
                              .difference(endTime)
                              .isNegative) {
                            lateCount++;
                          }
                        }
                      }

                      // Collapse all by default
                      final initiallyExpanded = false;

                      return SqaCard(
                        margin: const EdgeInsets.only(bottom: 12.0),
                        padding: EdgeInsets.zero,
                        child: Theme(
                          data: theme.copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: initiallyExpanded,
                            tilePadding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            childrenPadding: const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: SqaStyles.radiusLarge,
                              side: BorderSide.none,
                            ),
                            collapsedShape: RoundedRectangleBorder(
                              borderRadius: SqaStyles.radiusLarge,
                              side: BorderSide.none,
                            ),
                            title: Row(
                              children: [
                                Icon(
                                  Symbols.calendar_today,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    date.isAtSameMomentAs(today)
                                        ? 'Today'
                                        : date.isAtSameMomentAs(
                                            today.subtract(
                                              const Duration(days: 1),
                                            ),
                                          )
                                        ? 'Yesterday'
                                        : DateFormat(
                                            'EEEE, MMM d, y',
                                          ).format(date),
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      lateCount > 0
                                          ? '${items.length} ${items.length == 1 ? 'task' : 'tasks'} · $lateCount late'
                                          : '${items.length} ${items.length == 1 ? 'task' : 'tasks'}',
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color:
                                                colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      overflow: TextOverflow.ellipsis,
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
                                  isReadOnly: true,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
    );
  }
}

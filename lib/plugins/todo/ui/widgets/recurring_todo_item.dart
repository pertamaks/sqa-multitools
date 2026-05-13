import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/recurring_todo.dart';
import '../../providers/todo_provider.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_toast.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import 'recurring_todo_editor_dialog.dart';

class RecurringTodoItem extends ConsumerWidget {
  final RecurringTodo item;

  const RecurringTodoItem({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final use24h =
        ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true;

    return Opacity(
      opacity: item.isActive ? 1.0 : 0.6,
      child: SqaCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: () => RecurringTodoEditorDialog.show(context, item: item),
        child: Row(
          children: [
            // Status Icon / Toggle
            SqaHoverIconButton(
              icon: item.isActive ? Symbols.check_circle : Symbols.circle,
              color: item.isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              iconSize: 20,
              onPressed: () {
                ref
                    .read(todoProvider.notifier)
                    .updateRecurringTodo(
                      item.copyWith(isActive: !item.isActive),
                    );
                SqaToast.show(
                  context,
                  item.isActive ? 'Focus paused' : 'Focus resumed',
                );
              },
              tooltip: item.isActive ? 'Pause Focus' : 'Resume Focus',
              padding: 8,
            ),
            const SizedBox(width: 8),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: item.isActive
                          ? null
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Symbols.schedule,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatTime(item.hour, item.minute, use24h)} • ${_getRecurrenceText(item)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            SqaPopupMenu(
              icon: Symbols.more_vert,
              children: [
                SqaPopupMenuItem(
                  label: 'Edit',
                  icon: const Icon(Symbols.edit),
                  onPressed: () =>
                      RecurringTodoEditorDialog.show(context, item: item),
                ),
                SqaPopupMenuItem(
                  label: 'Delete',
                  icon: const Icon(Symbols.delete),
                  isDestructive: true,
                  onPressed: () async {
                    final confirmed = await SqaModal.showDanger(
                      context,
                      title: 'Delete Recurring Focus',
                      message:
                          'Are you sure you want to delete "${item.title}"? This will stop future focus blocks from being created.',
                    );
                    if (confirmed == true) {
                      ref
                          .read(todoProvider.notifier)
                          .deleteRecurringTodo(item.id);
                      if (context.mounted) {
                        SqaToast.show(context, 'Recurring focus deleted.');
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int hour, int minute, bool use24h) {
    final h = use24h
        ? hour.toString().padLeft(2, '0')
        : ((hour % 12 == 0 ? 12 : hour % 12).toString());
    final m = minute.toString().padLeft(2, '0');
    final period = use24h ? '' : (hour >= 12 ? ' PM' : ' AM');
    return '$h:$m$period';
  }

  String _getRecurrenceText(RecurringTodo item) {
    switch (item.recurrenceType) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekdays:
        return 'Weekdays';
      case RecurrenceType.weekly:
        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        final selected = item.weeklyDays.map((d) => days[d - 1]).join(', ');
        return 'Weekly ($selected)';
      case RecurrenceType.everyNDays:
        return 'Every ${item.everyNDays} days';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/todo_item.dart';
import '../../providers/todo_provider.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_toast.dart';
import '../../../../ui/widgets/sqa_date_picker.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';

class TodoItemDialogs {
  static void showHistorySummary(
    BuildContext context,
    WidgetRef ref,
    TodoItem item,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (context) => SqaModal<void>.custom(
        title: 'Focus Summary',
        icon: Symbols.history,
        customActions: [
          SqaButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
            type: SqaButtonType.primary,
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              Symbols.info,
              'Status',
              item.status.displayName.toUpperCase(),
            ),
            _buildSummaryRow(
              context,
              Symbols.calendar_today,
              'Created',
              DateFormat('MMM d, y • h:mm a').format(item.createdAt),
            ),
            if (item.timeBlock != TodoTimeBlock.current)
              _buildSummaryRow(
                context,
                Symbols.hourglass_empty,
                'Time Block',
                item.timeBlock.getDisplayName(
                  ref.read(todoSettingsProvider).value?.use24HourFormat ?? true,
                ),
              ),
            if (item.completedAt case final completedAt?)
              _buildSummaryRow(
                context,
                Symbols.check_circle,
                'Completed',
                DateFormat('MMM d, y • h:mm a').format(completedAt),
              ),
            if (item.deferredUntil case final deferredUntil?)
              _buildSummaryRow(
                context,
                Symbols.schedule,
                'Deferred Until',
                DateFormat('MMM d, y').format(deferredUntil),
              ),
            if (item.delegatedTo.isNotEmpty)
              _buildSummaryRow(
                context,
                Symbols.person,
                'Delegated To',
                item.delegatedTo,
              ),

            if (item.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 16),
              Text(
                'Notes',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: SqaStyles.radiusMedium,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(item.notes, style: theme.textTheme.bodyMedium),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static void showNotes(
    BuildContext context,
    WidgetRef ref,
    TodoItem item,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: item.notes,
    );

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => SqaModal<bool>.custom(
        title: 'Focus Notes',
        icon: Symbols.list_alt_check,
        customActions: [
          SqaButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            type: SqaButtonType.tonal,
          ),
          const SizedBox(width: SqaTokens.spacingXXSmall),
          SqaButton(
            label: 'Complete with Notes',
            onPressed: () => Navigator.pop(context, true),
            type: SqaButtonType.primary,
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SqaField(
              label: 'Focus Notes',
              controller: controller,
              hintText: 'What did you achieve?',
              isMultiline: true,
              minLines: 3,
              maxLines: null,
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final newStatus = TodoStatus.done;
      final notes = SqaField.toSentenceCase(controller.text.trim());
      ref
          .read(todoProvider.notifier)
          .updateTodo(
            item.copyWith(
              status: newStatus,
              notes: notes,
              completedAt: DateTime.now(),
            ),
          );
      if (context.mounted) {
        SqaToast.show(
          context,
          'Focus completed with notes!',
          type: SqaToastType.success,
        );
      }
    }
  }

  static void showDelegate(
    BuildContext context,
    WidgetRef ref,
    TodoItem item,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: item.delegatedTo,
    );

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => SqaModal<bool>.custom(
        title: 'Delegate Focus',
        icon: Symbols.person_add,
        customActions: [
          SqaButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            type: SqaButtonType.tonal,
          ),
          const SizedBox(width: SqaTokens.spacingXXSmall),
          SqaButton(
            label: 'Confirm Delegate',
            onPressed: () => Navigator.pop(context, true),
            type: SqaButtonType.primary,
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SqaField(
              label: 'Delegate To',
              controller: controller,
              hintText: 'Who are you delegating this to?',
              autofocus: true,
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final delegatedTo = controller.text.trim();
      if (delegatedTo.isNotEmpty) {
        ref
            .read(todoProvider.notifier)
            .updateTodo(
              item.copyWith(
                status: TodoStatus.delegated,
                delegatedTo: delegatedTo,
                completedAt: DateTime.now(),
              ),
            );
        if (context.mounted) {
          SqaToast.show(context, 'Focus delegated to $delegatedTo');
        }
      }
    }
  }

  static void showException(
    BuildContext context,
    WidgetRef ref,
    TodoItem item,
  ) async {
    final TextEditingController controller = TextEditingController(
      text: item.notes,
    );

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => SqaModal<bool>.custom(
        title: 'Mark as Exception',
        icon: Symbols.report_problem,
        customActions: [
          SqaButton(
            label: 'Back',
            onPressed: () => Navigator.pop(context, false),
            type: SqaButtonType.tonal,
          ),
          const SizedBox(width: SqaTokens.spacingXXSmall),
          SqaButton(
            label: 'Confirm Exception',
            onPressed: () => Navigator.pop(context, true),
            type: SqaButtonType.primary,
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SqaField(
              label: 'Exception Reason',
              controller: controller,
              hintText: 'What happened? Why was this focus an exception?',
              isMultiline: true,
              minLines: 3,
              maxLines: null,
              autofocus: true,
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final notes = SqaField.toSentenceCase(controller.text.trim());
      ref
          .read(todoProvider.notifier)
          .updateTodo(
            item.copyWith(
              status: TodoStatus.exception,
              notes: notes,
              completedAt: DateTime.now(),
            ),
          );
      if (context.mounted) {
        SqaToast.show(context, 'Focus marked as exception.');
      }
    }
  }

  static void showCancel(
    BuildContext context,
    WidgetRef ref,
    TodoItem item,
  ) async {
    final confirmed = await SqaModal.showDanger(
      context,
      title: 'Cancel Focus',
      message:
          'Are you sure you want to cancel "${item.title}"? It will be moved to the completed list as cancelled.',
      confirmLabel: 'Cancel Focus',
    );

    if (confirmed == true) {
      ref
          .read(todoProvider.notifier)
          .updateTodo(
            item.copyWith(
              status: TodoStatus.cancelled,
              completedAt: DateTime.now(),
            ),
          );
      if (context.mounted) {
        SqaToast.show(context, 'Focus cancelled.');
      }
    }
  }

  static void showDefer(BuildContext context, WidgetRef ref, TodoItem item) {
    final now = DateTime.now();
    final is24h =
        ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true;

    final blockHour = _getHourForTimeBlock(item.timeBlock, item.createdAt.hour);
    final blockMinute = item.timeBlock == TodoTimeBlock.current
        ? item.createdAt.minute
        : 0;
    final blockDate = DateTime(
      now.year,
      now.month,
      now.day,
      blockHour,
      blockMinute,
    );

    showDialog<void>(
      context: context,
      builder: (context) => SqaModal<void>.custom(
        title: 'Defer Focus',
        icon: Symbols.schedule,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeferOption(
              context,
              icon: Symbols.update,
              title: item.timeBlock == TodoTimeBlock.current
                  ? 'Same Time Tomorrow'
                  : 'Same Time Block Tomorrow',
              subtitle: item.timeBlock == TodoTimeBlock.current
                  ? 'Tomorrow at ${DateFormat(is24h ? 'HH:mm' : 'h:mm a').format(blockDate)}'
                  : 'Tomorrow, ${item.timeBlock.getDisplayName(is24h)}',
              onTap: () {
                final date = DateTime(
                  now.year,
                  now.month,
                  now.day + 1,
                  blockHour,
                  blockMinute,
                );
                ref.read(todoProvider.notifier).deferTodo(item.id, date);
                Navigator.pop(context);
                SqaToast.show(context, 'Focus deferred to tomorrow');
              },
            ),
            const SizedBox(height: 8),
            _buildDeferOption(
              context,
              icon: Symbols.wb_sunny,
              title: 'Tomorrow Morning',
              subtitle:
                  'Tomorrow at ${ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true ? '09:00' : '9:00 AM'}',
              onTap: () {
                final date = DateTime(now.year, now.month, now.day + 1, 9, 0);
                ref.read(todoProvider.notifier).deferTodo(item.id, date);
                Navigator.pop(context);
                SqaToast.show(context, 'Focus deferred to tomorrow morning');
              },
            ),
            const SizedBox(height: 8),
            _buildDeferOption(
              context,
              icon: Symbols.next_week,
              title: 'Next Week',
              subtitle: DateFormat(
                'EEEE, MMM d',
              ).format(now.add(const Duration(days: 7))),
              onTap: () {
                final date = now.add(const Duration(days: 7));
                ref.read(todoProvider.notifier).deferTodo(item.id, date);
                Navigator.pop(context);
                SqaToast.show(context, 'Focus deferred to next week');
              },
            ),
            const SizedBox(height: 8),
            _buildDeferOption(
              context,
              icon: Symbols.calendar_today,
              title: 'Pick a Day',
              subtitle: 'Select a custom date',
              onTap: () async {
                final picked = await SqaDatePicker.show(
                  context,
                  initialDate: now.add(const Duration(days: 1)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (picked != null) {
                  ref.read(todoProvider.notifier).deferTodo(item.id, picked);
                  if (context.mounted) {
                    Navigator.pop(context);
                    SqaToast.show(
                      context,
                      'Focus deferred to ${DateFormat('MMM d').format(picked)}',
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildSummaryRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDeferOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return SqaCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Symbols.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  static int _getHourForTimeBlock(TodoTimeBlock block, int defaultHour) {
    switch (block) {
      case TodoTimeBlock.morning:
        return 6;
      case TodoTimeBlock.midMorning:
        return 9;
      case TodoTimeBlock.noon:
        return 11;
      case TodoTimeBlock.afternoon:
        return 13;
      case TodoTimeBlock.lateAfternoon:
        return 15;
      case TodoTimeBlock.evening:
        return 17;
      case TodoTimeBlock.night:
        return 20;
      case TodoTimeBlock.current:
        return defaultHour;
    }
  }

  static void incrementHelpCount(WidgetRef ref) {
    final settings = ref.read(todoSettingsProvider).value;
    if (settings != null && settings.longPressHelpCount < 5) {
      ref
          .read(todoSettingsProvider.notifier)
          .updateSettings(
            settings.copyWith(
              longPressHelpCount: settings.longPressHelpCount + 1,
            ),
          );
    }
  }
}

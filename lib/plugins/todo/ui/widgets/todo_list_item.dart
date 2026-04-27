import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_item.dart';
import '../../providers/todo_provider.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import '../../../../ui/widgets/sqa_smart_text.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_field.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

class TodoListItem extends ConsumerWidget {
  final TodoItem item;
  final int? displayIndex;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TodoListItem({
    super.key,
    required this.item,
    this.displayIndex,
    this.onToggle,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDone = item.status == TodoStatus.done;
    final isDeferred = item.status == TodoStatus.deferred;
    final isDelegated = item.status == TodoStatus.delegated;
    final isTerminal = isDone || isDelegated;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdAtDate = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
    final isToday = createdAtDate.isAtSameMomentAs(today);
    final isOverdueByDay = !isTerminal && !isDeferred && createdAtDate.isBefore(today);
    final isOverdueByTime = !isTerminal && !isDeferred && isToday && item.timeBlock.isPast(now);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SqaCard(
          padding: EdgeInsets.zero, // Padding will be handled by internal InkWell
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildActionIcons(context, ref),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: isOverdueByDay ? null : onTap,
              borderRadius: BorderRadius.zero, // Keep it within the column
              overlayColor: SqaStyles.buttonOverlay(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SqaSmartText(
                      text: displayIndex != null ? 'Focus ${displayIndex! + 1}: ${item.title}' : item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        decoration: isTerminal ? TextDecoration.lineThrough : null,
                        color: isTerminal ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                        fontWeight: displayIndex != null ? FontWeight.bold : null,
                      ),
                    ),
                    if (item.category.isNotEmpty || 
                        (item.timeBlock != TodoTimeBlock.current && !isOverdueByDay && !isDeferred && !isDelegated) ||
                        isOverdueByDay ||
                        isDeferred ||
                        isDelegated)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            if (isOverdueByDay)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildBadge(
                                  context,
                                  'Overdue',
                                  colorScheme.error.withValues(alpha: 0.1),
                                  colorScheme.error,
                                ),
                              ),
                            if (isDeferred && item.deferredUntil != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildBadge(
                                  context,
                                  'Deferred: ${DateFormat('MMM d').format(item.deferredUntil!)}',
                                  colorScheme.surfaceContainerHighest,
                                  colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (isDelegated)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: _buildBadge(
                                  context,
                                  'Delegated to: ${item.delegatedTo}',
                                  colorScheme.primaryContainer.withValues(alpha: 0.2),
                                  colorScheme.primary,
                                ),
                              ),
                            if (item.category.isNotEmpty)
                              _buildBadge(
                                context,
                                item.category,
                                colorScheme.primaryContainer,
                                colorScheme.onPrimaryContainer,
                              ),
                            if (item.category.isNotEmpty && item.timeBlock != TodoTimeBlock.current && !isOverdueByDay && !isDeferred && !isDelegated)
                              const SizedBox(width: 8),
                            if (item.timeBlock != TodoTimeBlock.current && !isOverdueByDay && !isDeferred && !isDelegated)
                              _buildBadge(
                                context,
                                item.timeBlock.getDisplayName(ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true),
                                colorScheme.secondaryContainer,
                                colorScheme.onSecondaryContainer,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (onDelete != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: MenuAnchor(
                alignmentOffset: const Offset(-100, 4),
                style: MenuStyle(
                  backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
                  surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                  padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
                  elevation: WidgetStateProperty.all(8.0),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: SqaStyles.radiusLarge,
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
                menuChildren: [
                  if (!isOverdueByDay)
                    _buildMenuItem(
                      context,
                      icon: Symbols.edit,
                      label: 'Edit Focus',
                      onPressed: onTap,
                    ),
                  _buildMenuItem(
                    context,
                    icon: isOverdueByDay ? Symbols.bolt : Symbols.schedule,
                    label: isOverdueByDay ? 'Do Now' : 'Defer',
                    onPressed: isOverdueByDay 
                      ? () {
                          ref.read(todoProvider.notifier).updateTodo(
                            item.copyWith(
                              createdAt: DateTime.now(),
                              timeBlock: TodoTimeBlock.current,
                              priority: TodoPriority.critical,
                            ),
                          );
                        }
                      : () => _showDeferDialog(context, ref),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Symbols.person_add,
                    label: 'Delegate',
                    onPressed: () => _showDelegateDialog(context, ref),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Symbols.report_problem,
                    label: 'Mark as Exception',
                    onPressed: () {}, // To be implemented
                  ),
                  _buildMenuItem(
                    context,
                    icon: Symbols.cancel,
                    label: 'Cancel Focus',
                    onPressed: () {}, // To be implemented
                  ),
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  _buildMenuItem(
                    context,
                    icon: Symbols.delete,
                    label: 'Delete',
                    isDestructive: true,
                    onPressed: onDelete,
                  ),
                ],
                builder: (context, controller, child) {
                  return IconButton(
                    icon: Icon(
                      Symbols.more_vert,
                      size: 20,
                      color: controller.isOpen ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    ),
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
                    ).copyWith(
                      overlayColor: SqaStyles.buttonOverlay(context),
                    ),
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
        if (isOverdueByTime)
          Positioned(
            top: -10,
            left: 16,
            child: _buildQuestionLabel(context),
          ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface;

    return MenuItemButton(
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(160, 36),
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcons(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDone = item.status == TodoStatus.done;
    final isDelegated = item.status == TodoStatus.delegated;
    final isTerminal = isDone || isDelegated;

    final isDeferred = item.status == TodoStatus.deferred;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDelegated)
          IconButton(
            icon: Icon(
              Symbols.person_add,
              size: 22,
              color: colorScheme.primary,
            ),
            onPressed: () => _showDelegateDialog(context, ref),
            tooltip: 'Update Delegation',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        if (!isDeferred && !isDelegated) ...[
          IconButton(
            icon: Icon(
              isTerminal ? Symbols.check_box : Symbols.check_box_outline_blank,
              size: 22,
              color: isTerminal ? colorScheme.primary : colorScheme.onSurfaceVariant,
              fill: isTerminal ? 1 : 0,
            ),
            onPressed: onToggle,
            tooltip: isTerminal ? 'Mark as Todo' : 'Mark as Done',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          if (!isTerminal) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Symbols.list_alt_check,
                size: 22,
                color: item.notes.isNotEmpty ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              onPressed: () => _showNotesDialog(context, ref),
              tooltip: 'Add Notes & Done',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildQuestionLabel(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        "Time's up — how did it go?",
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  void _showNotesDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController(text: item.notes);

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => SqaModal<void>.custom(
        title: 'Focus Notes',
        icon: Symbols.list_alt_check,
        customActions: [
          SqaButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            type: SqaButtonType.tonal,
          ),
          const SizedBox(width: 8),
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
      ref.read(todoProvider.notifier).updateTodo(
        item.copyWith(
          status: newStatus,
          notes: notes,
          completedAt: DateTime.now(),
        ),
      );
    }
  }

  void _showDelegateDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController(text: item.delegatedTo);

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => SqaModal<void>.custom(
        title: 'Delegate Focus',
        icon: Symbols.person_add,
        customActions: [
          SqaButton(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            type: SqaButtonType.tonal,
          ),
          const SizedBox(width: 8),
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
        ref.read(todoProvider.notifier).updateTodo(
          item.copyWith(
            status: TodoStatus.delegated,
            delegatedTo: delegatedTo,
            completedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  void _showDeferDialog(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

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
              title: 'Same Time Tomorrow',
              subtitle: 'Tomorrow at ${DateFormat(ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true ? 'HH:mm' : 'h:mm a').format(item.createdAt)}',
              onTap: () {
                final date = DateTime(now.year, now.month, now.day + 1, item.createdAt.hour, item.createdAt.minute);
                ref.read(todoProvider.notifier).deferTodo(item.id, date);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildDeferOption(
              context,
              icon: Symbols.wb_sunny,
              title: 'Tomorrow Morning',
              subtitle: 'Tomorrow at ${ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true ? '09:00' : '9:00 AM'}',
              onTap: () {
                final date = DateTime(now.year, now.month, now.day + 1, 9, 0);
                ref.read(todoProvider.notifier).deferTodo(item.id, date);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildDeferOption(
              context,
              icon: Symbols.next_week,
              title: 'Next Week',
              subtitle: DateFormat('EEEE, MMM d').format(now.add(const Duration(days: 7))),
              onTap: () {
                final date = now.add(const Duration(days: 7));
                ref.read(todoProvider.notifier).deferTodo(item.id, date);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            _buildDeferOption(
              context,
              icon: Symbols.calendar_today,
              title: 'Pick a Day',
              subtitle: 'Select a custom date',
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: now.add(const Duration(days: 1)),
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (picked != null) {
                  ref.read(todoProvider.notifier).deferTodo(item.id, picked);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeferOption(
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
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
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
            Icon(Symbols.chevron_right, size: 20, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}

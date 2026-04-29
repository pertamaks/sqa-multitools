import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/todo_item.dart';


class TodoItemBadges extends StatelessWidget {
  final TodoItem item;
  final bool isReadOnly;
  final String? completionBadgeText;
  final bool use24HourFormat;

  const TodoItemBadges({
    super.key,
    required this.item,
    this.isReadOnly = false,
    this.completionBadgeText,
    this.use24HourFormat = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdAtDate = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
    
    final isDone = item.status == TodoStatus.done;
    final isDeferred = item.status == TodoStatus.deferred;
    final isDelegated = item.status == TodoStatus.delegated;
    final isTerminal = isDone || isDelegated;
    final isOverdueByDay = !isTerminal && !isDeferred && createdAtDate.isBefore(today);

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: [
        if (isOverdueByDay && !isReadOnly)
          _buildBadge(
            context,
            'Overdue',
            colorScheme.error.withValues(alpha: 0.1),
            colorScheme.error,
          ),
        if (isDeferred && item.deferredUntil != null)
          _buildBadge(
            context,
            'Deferred: ${DateFormat('MMM d').format(item.deferredUntil!)}',
            colorScheme.surfaceContainerHighest,
            colorScheme.onSurfaceVariant,
          ),
        if (isDelegated)
          _buildBadge(
            context,
            'Delegated to: ${item.delegatedTo}',
            colorScheme.primaryContainer.withValues(alpha: 0.2),
            colorScheme.primary,
          ),
        if (item.category.isNotEmpty)
          _buildBadge(
            context,
            item.category,
            colorScheme.primaryContainer,
            colorScheme.onPrimaryContainer,
          ),
        if (!isReadOnly && item.timeBlock != TodoTimeBlock.current && !isOverdueByDay && !isDeferred && !isDelegated)
          _buildBadge(
            context,
            item.timeBlock.getDisplayName(use24HourFormat),
            colorScheme.secondaryContainer,
            colorScheme.onSecondaryContainer,
          ),
        if (completionBadgeText != null)
          _buildBadge(
            context,
            completionBadgeText!,
            colorScheme.surfaceContainerHighest,
            colorScheme.onSurfaceVariant,
          ),
      ],
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

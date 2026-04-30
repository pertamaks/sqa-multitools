import 'package:flutter/material.dart';
import '../../models/todo_item.dart';
import 'todo_list_item.dart';
import '../../../../ui/widgets/sqa_styles.dart';

class TodoListSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final bool isPrimary;

  const TodoListSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isPrimary
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: isPrimary
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TodoExpansionGroup extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<TodoItem> items;
  final Color? color;
  final void Function(TodoItem) onToggle;
  final void Function(TodoItem) onDelete;
  final void Function(TodoItem) onTap;
  final bool initiallyExpanded;
  final double opacity;

  const TodoExpansionGroup({
    super.key,
    required this.icon,
    required this.title,
    required this.items,
    this.color,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
    this.initiallyExpanded = false,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtleColor = color ?? theme.colorScheme.onSurfaceVariant;

    return ListTileTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(
            children: [
              Icon(icon, size: 20, color: subtleColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: subtleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: subtleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: subtleColor,
                  ),
                ),
              ),
            ],
          ),
          childrenPadding: const EdgeInsets.only(top: 12),
          initiallyExpanded: initiallyExpanded,
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          children: items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Opacity(
                    opacity: opacity,
                    child: TodoListItem(
                      item: item,
                      onToggle: () => onToggle(item),
                      onDelete: () => onDelete(item),
                      onTap: () => onTap(item),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

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

class TodoListItem extends ConsumerWidget {
  final TodoItem item;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const TodoListItem({
    super.key,
    required this.item,
    this.onToggle,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDone = item.status == TodoStatus.done;

    return SqaCard(
      onTap: onTap,
      child: Row(
        children: [
          _buildActionIcons(context, ref),
          const SizedBox(width: 16),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SqaSmartText(
                    text: item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                    ),
                  ),
                  if (item.category.isNotEmpty || item.timeBlock != TodoTimeBlock.current)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          if (item.category.isNotEmpty)
                            _buildBadge(
                              context,
                              item.category,
                              colorScheme.primaryContainer,
                              colorScheme.onPrimaryContainer,
                            ),
                          if (item.category.isNotEmpty && item.timeBlock != TodoTimeBlock.current)
                            const SizedBox(width: 8),
                          if (item.timeBlock != TodoTimeBlock.current)
                            _buildBadge(
                              context,
                              item.timeBlock.displayName,
                              colorScheme.secondaryContainer,
                              colorScheme.onSecondaryContainer,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onDelete,
                color: colorScheme.error,
              ),
          ],
      ),
    );
  }

  Widget _buildActionIcons(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDone = item.status == TodoStatus.done;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isDone ? Symbols.check_box : Symbols.check_box_outline_blank,
            size: 22,
            color: isDone ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fill: isDone ? 1 : 0,
          ),
          onPressed: onToggle,
          tooltip: isDone ? 'Mark as Todo' : 'Mark as Done',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
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
    );
  }

  void _showNotesDialog(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final TextEditingController controller = TextEditingController(text: item.notes);

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => SqaModal.custom(
        title: 'Task Notes',
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
              label: 'Notes',
              controller: controller,
              hintText: 'Add notes about this task...',
              maxLines: 5,
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final newStatus = TodoStatus.done;
      ref.read(todoProvider.notifier).updateTodo(
        item.copyWith(
          status: newStatus,
          notes: controller.text,
          completedAt: DateTime.now(),
        ),
      );
    }
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

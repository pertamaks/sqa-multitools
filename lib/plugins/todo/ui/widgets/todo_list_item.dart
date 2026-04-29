import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_item.dart';
import '../../providers/todo_provider.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import '../../../../ui/widgets/sqa_smart_text.dart';
import '../../../../ui/widgets/sqa_toast.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'todo_item_badges.dart';
import 'todo_item_dialogs.dart';

class TodoListItem extends ConsumerStatefulWidget {
  final TodoItem item;
  final int? displayIndex;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final bool isReadOnly;

  const TodoListItem({
    super.key,
    required this.item,
    this.displayIndex,
    this.onToggle,
    this.onDelete,
    this.onTap,
    this.isReadOnly = false,
  });

  @override
  ConsumerState<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends ConsumerState<TodoListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0.2,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _checkAnimation();
  }

  void _checkAnimation() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdAtDate = DateTime(
      widget.item.createdAt.year,
      widget.item.createdAt.month,
      widget.item.createdAt.day,
    );
    final isToday = createdAtDate.isAtSameMomentAs(today);

    final isDone = widget.item.status == TodoStatus.done;
    final isDelegated = widget.item.status == TodoStatus.delegated;
    final isTerminal = isDone || isDelegated;
    final isDeferred = widget.item.status == TodoStatus.deferred;

    final isCurrent =
        !isTerminal &&
        !isDeferred &&
        isToday &&
        widget.item.timeBlock.isCurrent(now);

    if (isCurrent) {
      if (!_controller.isAnimating) {
        _controller.repeat(reverse: true);
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void didUpdateWidget(TodoListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isDone = widget.item.status == TodoStatus.done;
    final isDeferred = widget.item.status == TodoStatus.deferred;
    final isDelegated = widget.item.status == TodoStatus.delegated;
    final isTerminal = isDone || isDelegated;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdAtDate = DateTime(
      widget.item.createdAt.year,
      widget.item.createdAt.month,
      widget.item.createdAt.day,
    );
    final isToday = createdAtDate.isAtSameMomentAs(today);
    final isOverdueByDay =
        !isTerminal && !isDeferred && createdAtDate.isBefore(today);
    final duration = widget.item.durationPreset.minutes;
    final endTime = widget.item.createdAt.add(Duration(minutes: duration));
    final isOverdueByTime =
        !isTerminal && !isDeferred && isToday && now.isAfter(endTime);
    final isCurrent =
        !isTerminal &&
        !isDeferred &&
        isToday &&
        !isOverdueByTime &&
        widget.item.timeBlock.isCurrent(now);

    String? completionBadgeText;

    if (widget.isReadOnly && widget.item.completedAt != null) {
      final timeStr = DateFormat('h:mm a').format(widget.item.completedAt!);
      final lateDiff = widget.item.completedAt!.difference(endTime);

      if (lateDiff.isNegative) {
        completionBadgeText = 'On Time · $timeStr';
      } else {
        String diffStr;
        if (lateDiff.inDays > 0) {
          diffStr = '+${lateDiff.inDays}d';
        } else if (lateDiff.inHours > 0) {
          diffStr = '+${lateDiff.inHours}hr';
        } else {
          diffStr = '+${lateDiff.inMinutes}m';
        }
        completionBadgeText = 'Completed Late ($diffStr) · $timeStr';
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return SqaCard(
              padding: EdgeInsets.zero,
              borderSide: isCurrent
                  ? BorderSide(
                      color: colorScheme.primary.withValues(
                        alpha: _animation.value,
                      ),
                      width: 1.5,
                    )
                  : null,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: _buildActionIcons(context, ref),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: widget.isReadOnly
                          ? () => TodoItemDialogs.showHistorySummary(
                              context,
                              ref,
                              widget.item,
                            )
                          : (isOverdueByDay ||
                                    widget.item.recurringTodoId != null
                                ? null
                                : widget.onTap),
                      borderRadius: BorderRadius.zero,
                      overlayColor: SqaStyles.buttonOverlay(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.item.recurringTodoId != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      right: 6.0,
                                      top: 2.0,
                                    ),
                                    child: Icon(
                                      Symbols.sync,
                                      size: 16,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                Expanded(
                                  child: SqaSmartText(
                                    text: widget.displayIndex != null
                                        ? 'Focus ${widget.displayIndex! + 1}: ${widget.item.title}'
                                        : widget.item.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      decoration:
                                          isTerminal && !widget.isReadOnly
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: isTerminal
                                          ? colorScheme.onSurfaceVariant
                                          : colorScheme.onSurface,
                                      fontWeight: widget.displayIndex != null
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.item.category.isNotEmpty ||
                                (widget.item.timeBlock !=
                                        TodoTimeBlock.current &&
                                    !isOverdueByDay &&
                                    !isDeferred &&
                                    !isDelegated) ||
                                isOverdueByDay ||
                                isDeferred ||
                                isDelegated ||
                                completionBadgeText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: TodoItemBadges(
                                  item: widget.item,
                                  isReadOnly: widget.isReadOnly,
                                  completionBadgeText: completionBadgeText,
                                  use24HourFormat:
                                      ref
                                          .watch(todoSettingsProvider)
                                          .value
                                          ?.use24HourFormat ??
                                      true,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (widget.onDelete != null && !widget.isReadOnly)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SqaPopupMenu(
                        alignmentOffset: const Offset(-100, 4),
                        icon: Icon(
                          Symbols.more_vert,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        children: [
                          if (widget.item.recurringTodoId == null) ...[
                            if (!isOverdueByDay)
                              SqaPopupMenuItem(
                                icon: const Icon(Symbols.edit),
                                label: 'Edit Focus',
                                onPressed: widget.onTap,
                              ),
                            SqaPopupMenuItem(
                              icon: Icon(
                                isOverdueByDay
                                    ? Symbols.bolt
                                    : Symbols.schedule,
                              ),
                              label: isOverdueByDay ? 'Do Now' : 'Defer',
                              onPressed: isOverdueByDay
                                  ? () {
                                      ref
                                          .read(todoProvider.notifier)
                                          .updateTodo(
                                            widget.item.copyWith(
                                              createdAt: DateTime.now(),
                                              timeBlock: TodoTimeBlock.current,
                                              priority: TodoPriority.critical,
                                            ),
                                          );
                                    }
                                  : () => TodoItemDialogs.showDefer(
                                      context,
                                      ref,
                                      widget.item,
                                    ),
                            ),
                            SqaPopupMenuItem(
                              icon: const Icon(Symbols.person_add),
                              label: 'Delegate',
                              onPressed: () => TodoItemDialogs.showDelegate(
                                context,
                                ref,
                                widget.item,
                              ),
                            ),
                          ],
                          SqaPopupMenuItem(
                            icon: const Icon(Symbols.report_problem),
                            label: 'Mark as Exception',
                            onPressed: () {},
                          ),
                          SqaPopupMenuItem(
                            icon: const Icon(Symbols.cancel),
                            label: 'Cancel Focus',
                            onPressed: () {},
                          ),
                          Divider(
                            height: 1,
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          SqaPopupMenuItem(
                            icon: const Icon(Symbols.delete),
                            label: 'Delete',
                            isDestructive: true,
                            onPressed: widget.onDelete,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionIcons(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDone = widget.item.status == TodoStatus.done;
    final isDelegated = widget.item.status == TodoStatus.delegated;
    final isTerminal = isDone || isDelegated;
    final isDeferred = widget.item.status == TodoStatus.deferred;

    final settings = ref.watch(todoSettingsProvider).value;
    final helpCount = settings?.longPressHelpCount ?? 0;
    final showHelp = helpCount < 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDelegated)
          widget.isReadOnly
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Symbols.person_add,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Symbols.person_add,
                    size: 22,
                    color: colorScheme.primary,
                  ),
                  onPressed: () =>
                      TodoItemDialogs.showDelegate(context, ref, widget.item),
                  tooltip: 'Update Delegation',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
        if (!isDeferred && !isDelegated) ...[
          widget.isReadOnly
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isTerminal
                        ? Symbols.check_box
                        : Symbols.check_box_outline_blank,
                    size: 22,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    fill: isTerminal ? 1 : 0,
                  ),
                )
              : GestureDetector(
                  onLongPress: isTerminal
                      ? null
                      : () {
                          TodoItemDialogs.incrementHelpCount(ref);
                          TodoItemDialogs.showNotes(context, ref, widget.item);
                        },
                  child: IconButton(
                    icon: Icon(
                      isTerminal
                          ? Symbols.check_box
                          : Symbols.check_box_outline_blank,
                      size: 22,
                      color: isTerminal
                          ? colorScheme.primary
                          : (widget.item.notes.isNotEmpty
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant),
                      fill: isTerminal ? 1 : 0,
                    ),
                    onPressed: () {
                      TodoItemDialogs.incrementHelpCount(ref);
                      final isDoneNow = !isTerminal;
                      widget.onToggle?.call();
                      if (isDoneNow) {
                        SqaToast.show(
                          context,
                          'Focus completed!',
                          type: SqaToastType.success,
                        );
                      } else {
                        SqaToast.show(context, 'Focus restored to Todo list');
                      }
                    },
                    tooltip: isTerminal
                        ? 'Mark as Todo'
                        : (showHelp
                              ? 'Mark as Done (Long press to add notes)'
                              : 'Mark as Done'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
        ],
      ],
    );
  }
}

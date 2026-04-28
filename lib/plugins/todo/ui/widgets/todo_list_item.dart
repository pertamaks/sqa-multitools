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
import '../../../../ui/widgets/sqa_toast.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';
import '../../../../ui/widgets/sqa_date_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';

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

class _TodoListItemState extends ConsumerState<TodoListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _checkAnimation();
  }

  void _checkAnimation() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdAtDate = DateTime(widget.item.createdAt.year, widget.item.createdAt.month, widget.item.createdAt.day);
    final isToday = createdAtDate.isAtSameMomentAs(today);
    
    final isDone = widget.item.status == TodoStatus.done;
    final isDelegated = widget.item.status == TodoStatus.delegated;
    final isTerminal = isDone || isDelegated;
    final isDeferred = widget.item.status == TodoStatus.deferred;

    final isCurrent = !isTerminal && !isDeferred && isToday && widget.item.timeBlock.isCurrent(now);
    
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
    final createdAtDate = DateTime(widget.item.createdAt.year, widget.item.createdAt.month, widget.item.createdAt.day);
    final isToday = createdAtDate.isAtSameMomentAs(today);
    final isOverdueByDay = !isTerminal && !isDeferred && createdAtDate.isBefore(today);
    final duration = widget.item.durationPreset.minutes;
    final endTime = widget.item.createdAt.add(Duration(minutes: duration));
    final isOverdueByTime = !isTerminal && !isDeferred && isToday && now.isAfter(endTime);
    final isCurrent = !isTerminal && !isDeferred && isToday && !isOverdueByTime && widget.item.timeBlock.isCurrent(now);
    
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
                    color: colorScheme.primary.withValues(alpha: _animation.value),
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
                          ? () => _showHistorySummaryModal(context)
                          : (isOverdueByDay || widget.item.recurringTodoId != null ? null : widget.onTap),
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
                                    padding: const EdgeInsets.only(right: 6.0, top: 2.0),
                                    child: Icon(Symbols.sync, size: 16, color: colorScheme.onSurfaceVariant),
                                  ),
                                Expanded(
                                  child: SqaSmartText(
                                    text: widget.displayIndex != null ? 'Focus ${widget.displayIndex! + 1}: ${widget.item.title}' : widget.item.title,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      decoration: isTerminal && !widget.isReadOnly ? TextDecoration.lineThrough : null,
                                      color: isTerminal ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                                      fontWeight: widget.displayIndex != null ? FontWeight.bold : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.item.category.isNotEmpty || 
                                (widget.item.timeBlock != TodoTimeBlock.current && !isOverdueByDay && !isDeferred && !isDelegated) ||
                                isOverdueByDay ||
                                isDeferred ||
                                isDelegated ||
                                completionBadgeText != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Wrap(
                                  spacing: 8.0,
                                  runSpacing: 4.0,
                                  children: [
                                    if (isOverdueByDay && !widget.isReadOnly)
                                      _buildBadge(
                                        context,
                                        'Overdue',
                                        colorScheme.error.withValues(alpha: 0.1),
                                        colorScheme.error,
                                      ),
                                    if (isDeferred && widget.item.deferredUntil != null)
                                      _buildBadge(
                                        context,
                                        'Deferred: ${DateFormat('MMM d').format(widget.item.deferredUntil!)}',
                                        colorScheme.surfaceContainerHighest,
                                        colorScheme.onSurfaceVariant,
                                      ),
                                    if (isDelegated)
                                      _buildBadge(
                                        context,
                                        'Delegated to: ${widget.item.delegatedTo}',
                                        colorScheme.primaryContainer.withValues(alpha: 0.2),
                                        colorScheme.primary,
                                      ),
                                    if (widget.item.category.isNotEmpty)
                                      _buildBadge(
                                        context,
                                        widget.item.category,
                                        colorScheme.primaryContainer,
                                        colorScheme.onPrimaryContainer,
                                      ),
                                    if (!widget.isReadOnly && widget.item.timeBlock != TodoTimeBlock.current && !isOverdueByDay && !isDeferred && !isDelegated)
                                      _buildBadge(
                                        context,
                                        widget.item.timeBlock.getDisplayName(ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true),
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
                              icon: Icon(isOverdueByDay ? Symbols.bolt : Symbols.schedule),
                              label: isOverdueByDay ? 'Do Now' : 'Defer',
                              onPressed: isOverdueByDay 
                                ? () {
                                    ref.read(todoProvider.notifier).updateTodo(
                                      widget.item.copyWith(
                                        createdAt: DateTime.now(),
                                        timeBlock: TodoTimeBlock.current,
                                        priority: TodoPriority.critical,
                                      ),
                                    );
                                  }
                                : () => _showDeferDialog(context, ref),
                            ),
                            SqaPopupMenuItem(
                              icon: const Icon(Symbols.person_add),
                              label: 'Delegate',
                              onPressed: () => _showDelegateDialog(context, ref),
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
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
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
                child: Icon(Symbols.person_add, size: 22, color: colorScheme.primary),
              )
            : IconButton(
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
          widget.isReadOnly
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  isTerminal ? Symbols.check_box : Symbols.check_box_outline_blank,
                  size: 22,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fill: isTerminal ? 1 : 0,
                ),
              )
            : GestureDetector(
            onLongPress: isTerminal ? null : () {
              _incrementHelpCount(ref);
              _showNotesDialog(context, ref);
            },
            child: IconButton(
              icon: Icon(
                isTerminal ? Symbols.check_box : Symbols.check_box_outline_blank,
                size: 22,
                color: isTerminal ? colorScheme.primary : (widget.item.notes.isNotEmpty ? colorScheme.primary : colorScheme.onSurfaceVariant),
                fill: isTerminal ? 1 : 0,
              ),
              onPressed: () {
                _incrementHelpCount(ref);
                final isDoneNow = !isTerminal;
                widget.onToggle?.call();
                if (isDoneNow) {
                  SqaToast.show(context, 'Focus completed!', type: SqaToastType.success);
                } else {
                  SqaToast.show(context, 'Focus restored to Todo list');
                }
              },
              tooltip: isTerminal 
                ? 'Mark as Todo' 
                : (showHelp ? 'Mark as Done (Long press to add notes)' : 'Mark as Done'),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ],
    );
  }

  void _showHistorySummaryModal(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;

    showDialog(
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
            _buildSummaryRow(context, Symbols.info, 'Status', item.status.name.toUpperCase()),
            _buildSummaryRow(
              context, 
              Symbols.calendar_today, 
              'Created', 
              DateFormat('MMM d, y • h:mm a').format(item.createdAt)
            ),
            if (item.timeBlock != TodoTimeBlock.current)
              _buildSummaryRow(
                context, 
                Symbols.hourglass_empty, 
                'Time Block', 
                item.timeBlock.getDisplayName(ref.read(todoSettingsProvider).value?.use24HourFormat ?? true)
              ),
            if (item.completedAt != null)
              _buildSummaryRow(
                context, 
                Symbols.check_circle, 
                'Completed', 
                DateFormat('MMM d, y • h:mm a').format(item.completedAt!)
              ),
            if (item.deferredUntil != null)
              _buildSummaryRow(
                context, 
                Symbols.schedule, 
                'Deferred Until', 
                DateFormat('MMM d, y').format(item.deferredUntil!)
              ),
            if (item.delegatedTo != null && item.delegatedTo!.isNotEmpty)
              _buildSummaryRow(context, Symbols.person, 'Delegated To', item.delegatedTo!),
            
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
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: SqaStyles.radiusMedium,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  item.notes,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, IconData icon, String label, String value) {
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

  void _incrementHelpCount(WidgetRef ref) {
    final settings = ref.read(todoSettingsProvider).value;
    if (settings != null && settings.longPressHelpCount < 5) {
      ref.read(todoSettingsProvider.notifier).updateSettings(
        settings.copyWith(longPressHelpCount: settings.longPressHelpCount + 1),
      );
    }
  }

  void _showNotesDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController(text: widget.item.notes);

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
        widget.item.copyWith(
          status: newStatus,
          notes: notes,
          completedAt: DateTime.now(),
        ),
      );
      if (context.mounted) {
        SqaToast.show(context, 'Focus completed with notes!', type: SqaToastType.success);
      }
    }
  }

  void _showDelegateDialog(BuildContext context, WidgetRef ref) async {
    final TextEditingController controller = TextEditingController(text: widget.item.delegatedTo);

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
          widget.item.copyWith(
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

  int _getHourForTimeBlock(TodoTimeBlock block, int defaultHour) {
    switch (block) {
      case TodoTimeBlock.morning: return 6;
      case TodoTimeBlock.midMorning: return 9;
      case TodoTimeBlock.noon: return 11;
      case TodoTimeBlock.afternoon: return 13;
      case TodoTimeBlock.lateAfternoon: return 15;
      case TodoTimeBlock.evening: return 17;
      case TodoTimeBlock.night: return 20;
      case TodoTimeBlock.current: return defaultHour;
    }
  }

  void _showDeferDialog(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final is24h = ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true;
    
    final blockHour = _getHourForTimeBlock(widget.item.timeBlock, widget.item.createdAt.hour);
    final blockMinute = widget.item.timeBlock == TodoTimeBlock.current ? widget.item.createdAt.minute : 0;
    final blockDate = DateTime(now.year, now.month, now.day, blockHour, blockMinute);

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
              title: widget.item.timeBlock == TodoTimeBlock.current ? 'Same Time Tomorrow' : 'Same Time Block Tomorrow',
              subtitle: widget.item.timeBlock == TodoTimeBlock.current 
                  ? 'Tomorrow at ${DateFormat(is24h ? 'HH:mm' : 'h:mm a').format(blockDate)}'
                  : 'Tomorrow, ${widget.item.timeBlock.getDisplayName(is24h)}',
              onTap: () {
                final date = DateTime(now.year, now.month, now.day + 1, blockHour, blockMinute);
                ref.read(todoProvider.notifier).deferTodo(widget.item.id, date);
                Navigator.pop(context);
                SqaToast.show(context, 'Focus deferred to tomorrow');
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
                ref.read(todoProvider.notifier).deferTodo(widget.item.id, date);
                Navigator.pop(context);
                SqaToast.show(context, 'Focus deferred to tomorrow morning');
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
                ref.read(todoProvider.notifier).deferTodo(widget.item.id, date);
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
                  ref.read(todoProvider.notifier).deferTodo(widget.item.id, picked);
                  if (context.mounted) {
                    Navigator.pop(context);
                    SqaToast.show(context, 'Focus deferred to ${DateFormat('MMM d').format(picked)}');
                  }
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

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/todo_item.dart';
import '../../models/recurring_todo.dart';
import '../../providers/todo_provider.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_dropdown.dart';
import '../../../../ui/widgets/sqa_toast.dart';
import '../../../../ui/widgets/sqa_time_picker.dart';

class RecurringTodoEditorDialog extends ConsumerStatefulWidget {
  final RecurringTodo? initialItem;

  const RecurringTodoEditorDialog({super.key, this.initialItem});

  static Future<void> show(BuildContext context, {RecurringTodo? item}) {
    return showDialog(
      context: context,
      builder: (_) => RecurringTodoEditorDialog(initialItem: item),
    );
  }

  @override
  ConsumerState<RecurringTodoEditorDialog> createState() => _RecurringTodoEditorDialogState();
}

class _RecurringTodoEditorDialogState extends ConsumerState<RecurringTodoEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _categoryController;
  late TextEditingController _everyNDaysController;
  
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  TodoDurationPreset _durationPreset = TodoDurationPreset.min25;
  TodoPriority _priority = TodoPriority.normal;
  RecurrenceType _recurrenceType = RecurrenceType.daily;
  List<int> _weeklyDays = [1, 2, 3, 4, 5]; // Mon-Fri default for weekly if selected

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _categoryController = TextEditingController(text: item?.category ?? '');
    _everyNDaysController = TextEditingController(text: item?.everyNDays.toString() ?? '1');
    
    if (item != null) {
      _time = TimeOfDay(hour: item.hour, minute: item.minute);
      _durationPreset = item.durationPreset;
      _priority = item.priority;
      _recurrenceType = item.recurrenceType;
      _weeklyDays = List.from(item.weeklyDays);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _categoryController.dispose();
    _everyNDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final use24h = ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true;

    return SqaModal<void>.custom(
      title: widget.initialItem == null ? 'New Recurring Focus' : 'Edit Recurring Focus',
      customActions: [
        SqaButton(
          label: 'Cancel',
          onPressed: () => Navigator.of(context).pop(),
          type: SqaButtonType.tonal,
        ),
        const SizedBox(width: 8),
        SqaButton(
          label: widget.initialItem == null ? 'Create' : 'Save',
          onPressed: _save,
          type: SqaButtonType.primary,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SqaField(
            label: 'Focus Title',
            controller: _titleController,
            hintText: 'e.g. Daily Standup, Workout',
            showCopyButton: false,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, 'Trigger Time'),
                    const SizedBox(height: 8),
                    SqaButton(
                      label: _formatTime(_time, use24h),
                      onPressed: () async {
                        final picked = await SqaTimePicker.show(
                          context,
                          initialHour: _time.hour,
                          initialMinute: _time.minute,
                          use24Hour: use24h,
                        );
                        if (picked != null) setState(() => _time = picked);
                      },
                      type: SqaButtonType.tonal,
                      icon: Symbols.schedule,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, 'Duration'),
                    const SizedBox(height: 8),
                    SqaDropdown<TodoDurationPreset>(
                      value: _durationPreset,
                      items: TodoDurationPreset.values.map((v) => DropdownMenuItem(value: v, child: Text('${_getDurationMinutes(v)} min'))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _durationPreset = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, 'Recurrence'),
                    const SizedBox(height: 8),
                    SqaDropdown<RecurrenceType>(
                      value: _recurrenceType,
                      items: RecurrenceType.values.map((v) => DropdownMenuItem(value: v, child: Text(_getRecurrenceName(v)))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _recurrenceType = v);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, 'Priority'),
                    const SizedBox(height: 8),
                    SqaDropdown<TodoPriority>(
                      value: _priority,
                      items: TodoPriority.values.map((v) => DropdownMenuItem(value: v, child: Text(v.displayName))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _priority = v);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_recurrenceType == RecurrenceType.everyNDays) ...[
            const SizedBox(height: 16),
            SqaField(
              label: 'Every N Days',
              controller: _everyNDaysController,
              hintText: 'e.g. 2',
              showCopyButton: false,
            ),
          ],
          if (_recurrenceType == RecurrenceType.weekly) ...[
            const SizedBox(height: 16),
            _buildLabel(context, 'Weekly Days'),
            const SizedBox(height: 8),
            _buildWeeklyPicker(),
          ],
          const SizedBox(height: 16),
          SqaField(
            label: 'Category',
            controller: _categoryController,
            hintText: 'e.g. Work, Routine',
            showCopyButton: false,
          ),
          const SizedBox(height: 16),
          SqaField(
            label: 'Notes',
            controller: _notesController,
            hintText: 'Add details here...',
            isMultiline: true,
            minLines: 2,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPicker() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final dayNum = i + 1;
        final isSelected = _weeklyDays.contains(dayNum);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _weeklyDays.remove(dayNum);
              } else {
                _weeklyDays.add(dayNum);
              }
            });
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                days[i],
                style: TextStyle(
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  String _formatTime(TimeOfDay time, bool use24h) {
    final hour = use24h ? time.hour.toString().padLeft(2, '0') : ((time.hour % 12 == 0 ? 12 : time.hour % 12).toString());
    final minute = time.minute.toString().padLeft(2, '0');
    final period = use24h ? '' : (time.hour >= 12 ? ' PM' : ' AM');
    return '$hour:$minute$period';
  }

  String _getRecurrenceName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily: return 'Daily';
      case RecurrenceType.weekdays: return 'Weekdays (M-F)';
      case RecurrenceType.weekly: return 'Weekly';
      case RecurrenceType.everyNDays: return 'Every N Days';
    }
  }

  int _getDurationMinutes(TodoDurationPreset p) => p.minutes;

  void _save() {
    if (_titleController.text.trim().isEmpty) return;
    if (_recurrenceType == RecurrenceType.weekly && _weeklyDays.isEmpty) return;

    final notifier = ref.read(todoProvider.notifier);
    final title = SqaField.toSentenceCase(_titleController.text.trim());
    final notes = SqaField.toSentenceCase(_notesController.text.trim());

    if (widget.initialItem == null) {
      final newItem = RecurringTodo(
        id: const Uuid().v4(),
        title: title,
        hour: _time.hour,
        minute: _time.minute,
        durationPreset: _durationPreset,
        priority: _priority,
        recurrenceType: _recurrenceType,
        everyNDays: int.tryParse(_everyNDaysController.text) ?? 1,
        weeklyDays: _weeklyDays,
        category: _categoryController.text.trim(),
        notes: notes,
      );
      notifier.addRecurringTodo(newItem);
      if (context.mounted) {
        SqaToast.show(context, 'Recurring focus created!', type: SqaToastType.success);
      }
    } else {
      notifier.updateRecurringTodo(
        widget.initialItem!.copyWith(
          title: title,
          hour: _time.hour,
          minute: _time.minute,
          durationPreset: _durationPreset,
          priority: _priority,
          recurrenceType: _recurrenceType,
          everyNDays: int.tryParse(_everyNDaysController.text) ?? 1,
          weeklyDays: _weeklyDays,
          category: _categoryController.text.trim(),
          notes: notes,
        ),
      );
      if (context.mounted) {
        SqaToast.show(context, 'Recurring focus updated!', type: SqaToastType.success);
      }
    }
    Navigator.of(context).pop();
  }
}

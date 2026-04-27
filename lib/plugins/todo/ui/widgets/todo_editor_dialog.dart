import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_item.dart';
import '../../providers/todo_provider.dart';
import '../../providers/todo_notification_provider.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_dropdown.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_styles.dart';

class TodoEditorDialog extends ConsumerStatefulWidget {
  final TodoItem? initialItem;

  const TodoEditorDialog({super.key, this.initialItem});

  static Future<void> show(BuildContext context, {TodoItem? item}) {
    return showDialog(
      context: context,
      builder: (_) => TodoEditorDialog(initialItem: item),
    );
  }

  @override
  ConsumerState<TodoEditorDialog> createState() => _TodoEditorDialogState();
}

class _TodoEditorDialogState extends ConsumerState<TodoEditorDialog> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _categoryController;
  
  TodoTimeBlock _timeBlock = TodoTimeBlock.current;
  TodoDurationPreset _durationPreset = TodoDurationPreset.min25;
  TodoPriority _priority = TodoPriority.normal;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _categoryController = TextEditingController(text: item?.category ?? '');
    
    if (item != null) {
      _timeBlock = item.timeBlock;
      _durationPreset = item.durationPreset;
      _priority = item.priority;
    } else {
      _suggestInitialState();
    }
  }

  void _suggestInitialState() async {
    final settingsAsync = ref.read(todoSettingsProvider);
    final settings = settingsAsync.value;
    if (settings?.wakeHour != null) {
      final suggestion = ref.read(todoNotificationProvider.notifier).suggestTimeBlock(
        settings!.wakeHour!,
        settings.wakeMinute!,
        DateTime.now(),
      );
      setState(() {
        _timeBlock = suggestion;
        _durationPreset = _getValidDurationForBlock(suggestion);
      });
    }
  }

  TodoDurationPreset _getValidDurationForBlock(TodoTimeBlock block) {
    switch (block) {
      case TodoTimeBlock.current:
      case TodoTimeBlock.noon:
      case TodoTimeBlock.evening:
        return TodoDurationPreset.min25;
      case TodoTimeBlock.morning:
      case TodoTimeBlock.afternoon:
        return TodoDurationPreset.min45;
      case TodoTimeBlock.tonight:
        return TodoDurationPreset.min15;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SqaModal.custom(
      title: widget.initialItem == null ? 'Add Task' : 'Edit Task',
      confirmLabel: widget.initialItem == null ? 'Create' : 'Save',
      // I should handle the return value in show() or use customActions.
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
            label: 'Task Name',
            controller: _titleController,
            hintText: 'What needs to be done?',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel(context, 'Time Block'),
                    const SizedBox(height: 8),
                    SqaDropdown<TodoTimeBlock>(
                      value: _timeBlock,
                      items: TodoTimeBlock.values.map((v) => DropdownMenuItem(value: v, child: Text(v.displayName))).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _timeBlock = v;
                            _durationPreset = _getValidDurationForBlock(v);
                          });
                        }
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
                    _buildLabel(context, 'Duration'),
                    const SizedBox(height: 8),
                    SqaDropdown<TodoDurationPreset>(
                      value: _durationPreset,
                      items: _getAvailableDurations(_timeBlock).map((v) => DropdownMenuItem(value: v, child: Text('${_getDurationMinutes(v)} min'))).toList(),
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
              const SizedBox(width: 16),
              Expanded(
                child: SqaField(
                  label: 'Category / Tag',
                  controller: _categoryController,
                  hintText: 'e.g. Work, Personal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SqaField(
            label: 'Notes',
            controller: _notesController,
            hintText: 'Add details here...',
            isMultiline: true,
            minLines: 3,
            maxLines: null, // Grow with content
          ),
        ],
      ),
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

  List<TodoDurationPreset> _getAvailableDurations(TodoTimeBlock block) {
    switch (block) {
      case TodoTimeBlock.current:
      case TodoTimeBlock.noon:
      case TodoTimeBlock.evening:
        return [TodoDurationPreset.min5, TodoDurationPreset.min15, TodoDurationPreset.min25];
      case TodoTimeBlock.morning:
        return [TodoDurationPreset.min25, TodoDurationPreset.min45, TodoDurationPreset.min90];
      case TodoTimeBlock.afternoon:
        return [TodoDurationPreset.min25, TodoDurationPreset.min45];
      case TodoTimeBlock.tonight:
        return [TodoDurationPreset.min5, TodoDurationPreset.min15];
    }
  }

  int _getDurationMinutes(TodoDurationPreset p) {
    switch (p) {
      case TodoDurationPreset.min5: return 5;
      case TodoDurationPreset.min15: return 15;
      case TodoDurationPreset.min25: return 25;
      case TodoDurationPreset.min45: return 45;
      case TodoDurationPreset.min90: return 90;
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final notifier = ref.read(todoProvider.notifier);
    if (widget.initialItem == null) {
      notifier.addTodo(
        _titleController.text.trim(),
        timeBlock: _timeBlock,
        durationPreset: _durationPreset,
        priority: _priority,
        category: _categoryController.text.trim(),
        notes: _notesController.text.trim(),
      );
    } else {
      notifier.updateTodo(
        widget.initialItem!.copyWith(
          title: _titleController.text.trim(),
          timeBlock: _timeBlock,
          durationPreset: _durationPreset,
          priority: _priority,
          category: _categoryController.text.trim(),
          notes: _notesController.text.trim(),
        ),
      );
    }
    Navigator.of(context).pop();
  }
}

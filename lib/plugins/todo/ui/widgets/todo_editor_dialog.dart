import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/todo_item.dart';
import '../../providers/todo_provider.dart';
import '../../providers/todo_notification_provider.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_dropdown.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_toast.dart';

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
  TodoStatus _status = TodoStatus.todo;
  DateTime? _deferredUntil;

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
      _status = item.status;
      _deferredUntil = item.deferredUntil;
    } else {
      _suggestInitialState();
    }
  }

  void _suggestInitialState() async {
    final settingsAsync = ref.read(todoSettingsProvider);
    final settings = settingsAsync.value;
    if (settings?.wakeHour != null) {
      final suggestion = ref
          .read(todoNotificationProvider.notifier)
          .suggestTimeBlock(
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
      case TodoTimeBlock.midMorning:
      case TodoTimeBlock.afternoon:
      case TodoTimeBlock.lateAfternoon:
        return TodoDurationPreset.min45;
      case TodoTimeBlock.night:
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
    return SqaModal<void>.custom(
      title: widget.initialItem == null ? 'Add Focus' : 'Edit Focus',
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
            label: 'Focus Title',
            controller: _titleController,
            hintText: 'What needs to be done?',
            showCopyButton: false,
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
                      enabled: _status == TodoStatus.todo,
                      items: _getAvailableTimeBlocks().map((v) {
                        final use24h =
                            ref
                                .watch(todoSettingsProvider)
                                .value
                                ?.use24HourFormat ??
                            true;
                        return DropdownMenuItem(
                          value: v,
                          child: Text(v.getDisplayName(use24h)),
                        );
                      }).toList(),
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
                    _buildLabel(
                      context,
                      _status == TodoStatus.deferred
                          ? 'Reschedule'
                          : 'Duration',
                    ),
                    const SizedBox(height: 8),
                    if (_status == TodoStatus.deferred)
                      SqaButton(
                        label: _deferredUntil != null
                            ? DateFormat('MMM d, yyyy').format(_deferredUntil!)
                            : 'Pick Date',
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate:
                                _deferredUntil ??
                                DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() => _deferredUntil = picked);
                          }
                        },
                        type: SqaButtonType.tonal,
                        icon: Symbols.calendar_today,
                      )
                    else
                      SqaDropdown<TodoDurationPreset>(
                        value: _durationPreset,
                        items: _getAvailableDurations(_timeBlock)
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text('${_getDurationMinutes(v)} min'),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _durationPreset = v);
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_status == TodoStatus.deferred) ...[
            const SizedBox(height: 16),
            SqaButton(
              label: 'Do Now',
              onPressed: () => setState(() {
                _status = TodoStatus.todo;
                _deferredUntil = null;
                _timeBlock = TodoTimeBlock.current;
                _priority = TodoPriority.critical;
              }),
              type: SqaButtonType.primary,
              icon: Symbols.bolt,
            ),
          ],
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
                      items: TodoPriority.values
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(v.displayName),
                            ),
                          )
                          .toList(),
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
                  showCopyButton: false,
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
    List<TodoDurationPreset> presets;
    switch (block) {
      case TodoTimeBlock.current:
        presets = [
          TodoDurationPreset.min5,
          TodoDurationPreset.min15,
          TodoDurationPreset.min25,
        ];
        break;
      case TodoTimeBlock.morning:
      case TodoTimeBlock.midMorning:
        // Peak cognitive performance
        presets = [
          TodoDurationPreset.min25,
          TodoDurationPreset.min45,
          TodoDurationPreset.min90,
        ];
        break;
      case TodoTimeBlock.noon:
        // Anchor point
        presets = [
          TodoDurationPreset.min5,
          TodoDurationPreset.min15,
          TodoDurationPreset.min25,
        ];
        break;
      case TodoTimeBlock.afternoon:
      case TodoTimeBlock.lateAfternoon:
        // Lighter tasks / Second wind
        presets = [TodoDurationPreset.min25, TodoDurationPreset.min45];
        break;
      case TodoTimeBlock.evening:
        // Wind-down
        presets = [
          TodoDurationPreset.min5,
          TodoDurationPreset.min15,
          TodoDurationPreset.min25,
        ];
        break;
      case TodoTimeBlock.night:
        // Simple tasks only
        presets = [TodoDurationPreset.min5, TodoDurationPreset.min15];
        break;
    }

    // Always include the current selection to avoid dropdown element errors
    if (!presets.contains(_durationPreset)) {
      presets = [...presets, _durationPreset];
      presets.sort(
        (a, b) => _getDurationMinutes(a).compareTo(_getDurationMinutes(b)),
      );
    }
    return presets;
  }

  int _getDurationMinutes(TodoDurationPreset p) {
    switch (p) {
      case TodoDurationPreset.min5:
        return 5;
      case TodoDurationPreset.min15:
        return 15;
      case TodoDurationPreset.min25:
        return 25;
      case TodoDurationPreset.min45:
        return 45;
      case TodoDurationPreset.min90:
        return 90;
    }
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) return;

    final notifier = ref.read(todoProvider.notifier);
    final title = SqaField.toSentenceCase(_titleController.text.trim());
    final notes = SqaField.toSentenceCase(_notesController.text.trim());

    if (widget.initialItem == null) {
      notifier.addTodo(
        title,
        timeBlock: _timeBlock,
        durationPreset: _durationPreset,
        priority: _priority,
        category: _categoryController.text.trim(),
        notes: notes,
      );
      if (context.mounted) {
        SqaToast.show(
          context,
          'Focus block added!',
          type: SqaToastType.success,
        );
      }
    } else {
      final wasDeferred = widget.initialItem?.status == TodoStatus.deferred;
      final isNowTodo = _status == TodoStatus.todo;

      notifier.updateTodo(
        widget.initialItem!.copyWith(
          title: title,
          timeBlock: _timeBlock,
          durationPreset: _durationPreset,
          priority: _priority,
          category: _categoryController.text.trim(),
          notes: notes,
          status: _status,
          deferredUntil: _deferredUntil,
          createdAt: (wasDeferred && isNowTodo)
              ? DateTime.now()
              : widget.initialItem!.createdAt,
        ),
      );
      if (context.mounted) {
        SqaToast.show(context, 'Focus updated!', type: SqaToastType.success);
      }
    }
    Navigator.of(context).pop();
  }

  List<TodoTimeBlock> _getAvailableTimeBlocks() {
    final now = DateTime.now();
    final hour = now.hour;

    // If it's a deferred task, we only show 'Current' (as it's a placeholder)
    // but actually the dropdown is disabled anyway for non-today tasks.
    // This logic is primarily for Today tasks.

    return TodoTimeBlock.values.where((block) {
      // Always include the current selection to avoid dropdown errors
      if (block == _timeBlock) return true;

      switch (block) {
        case TodoTimeBlock.current:
          return true;
        case TodoTimeBlock.morning:
          return hour < 9;
        case TodoTimeBlock.midMorning:
          return hour < 11;
        case TodoTimeBlock.noon:
          return hour < 13;
        case TodoTimeBlock.afternoon:
          return hour < 15;
        case TodoTimeBlock.lateAfternoon:
          return hour < 17;
        case TodoTimeBlock.evening:
          return hour < 20;
        case TodoTimeBlock.night:
          return true;
      }
    }).toList();
  }
}

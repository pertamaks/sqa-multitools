import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/todo_provider.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_switch.dart';
import '../../../../ui/widgets/sqa_styles.dart';

class WakeTimePrompt extends ConsumerStatefulWidget {
  const WakeTimePrompt({super.key});

  static Future<void> showIfNeeded(BuildContext context, WidgetRef ref) async {
    final settingsAsync = await ref.read(todoSettingsProvider.future);
    
    if (!settingsAsync.askWakeTimeDaily) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (settingsAsync.lastWakeTimePromptDate != null) {
      final lastPrompt = DateTime(
        settingsAsync.lastWakeTimePromptDate!.year,
        settingsAsync.lastWakeTimePromptDate!.month,
        settingsAsync.lastWakeTimePromptDate!.day,
      );
      if (lastPrompt.isAtSameMomentAs(today)) return;
    }

    if (context.mounted) {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const WakeTimePrompt(),
      );
    }
  }

  @override
  ConsumerState<WakeTimePrompt> createState() => _WakeTimePromptState();
}

class _WakeTimePromptState extends ConsumerState<WakeTimePrompt> {
  late int _hour;
  late int _minute;
  bool _askDaily = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _hour = now.hour;
    _minute = now.minute;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SqaModal.custom(
      title: 'Good Morning!',
      icon: Symbols.wb_sunny,
      customActions: [
        SqaButton(
          label: 'Start My Day',
          onPressed: _submit,
          isFullWidth: true,
          type: SqaButtonType.primary,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'What time did you wake up today? We use this to align your 90-minute focus cycles.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeSelector(),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(child: Text('Ask me every day')),
              SqaSwitch(
                value: _askDaily,
                onChanged: (v) => setState(() => _askDaily = v),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Row(
      children: [
        _buildSpinner(0, 23, _hour, (v) => setState(() => _hour = v)),
        const Text(' : ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        _buildSpinner(0, 59, _minute, (v) => setState(() => _minute = v)),
      ],
    );
  }

  Widget _buildSpinner(int min, int max, int value, ValueChanged<int> onChanged) {
    return Container(
      width: 60,
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 40,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (i) => onChanged(min + i),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final val = min + index;
            final isSelected = val == value;
            return Center(
              child: Text(
                val.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                ),
              ),
            );
          },
          childCount: max - min + 1,
        ),
      ),
    );
  }

  void _submit() async {
    final settings = await ref.read(todoSettingsProvider.future);
    ref.read(todoSettingsProvider.notifier).updateSettings(
      settings.copyWith(
        wakeHour: _hour,
        wakeMinute: _minute,
        askWakeTimeDaily: _askDaily,
        lastWakeTimePromptDate: DateTime.now(),
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/todo_provider.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_switch.dart';
import '../../../../ui/widgets/sqa_time_segment.dart';
import '../../../../ui/widgets/sqa_segmented_button.dart';

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
  bool _use24Hour = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    final now = DateTime.now();
    _hour = now.hour;
    _minute = now.minute;
  }

  void _loadSettings() async {
    final settings = await ref.read(todoSettingsProvider.future);
    if (mounted) {
      setState(() {
        _askDaily = settings.askWakeTimeDaily;
        _use24Hour = settings.use24HourFormat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String greeting = 'Good Morning!';
    final nowHour = DateTime.now().hour;
    if (nowHour >= 12 && nowHour < 17) {
      greeting = 'Good Afternoon!';
    } else if (nowHour >= 17 && nowHour < 21) {
      greeting = 'Good Evening!';
    } else if (nowHour >= 21 || nowHour < 5) {
      greeting = 'Good Night!';
    }

    return SqaModal<void>.custom(
      title: greeting,
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
          Center(
            child: SqaSegmentedButton<bool>(
              stretches: false,
              fontSize: 10,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              segments: const [
                ButtonSegment(value: false, label: Text('12h')),
                ButtonSegment(value: true, label: Text('24h')),
              ],
              selected: {_use24Hour},
              onSelectionChanged: (v) => setState(() => _use24Hour = v.first),
            ),
          ),
          const SizedBox(height: 16),
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
    int displayHour = _hour;
    if (!_use24Hour) {
      displayHour = _hour % 12;
      if (displayHour == 0) displayHour = 12;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SqaTimeSegment(
          value: displayHour,
          minValue: _use24Hour ? 0 : 1,
          maxValue: _use24Hour ? 23 : 12,
          onChanged: (v) {
            setState(() {
              if (_use24Hour) {
                _hour = v;
              } else {
                bool isPM = _hour >= 12;
                int h = v % 12;
                _hour = isPM ? h + 12 : h;
              }
            });
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
          child: Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ),
        SqaTimeSegment(
          value: _minute,
          maxValue: 59,
          onChanged: (v) => setState(() => _minute = v),
        ),
        if (!_use24Hour) ...[
          const SizedBox(width: 16),
          SqaSegmentedButton<bool>(
            stretches: false,
            fontSize: 10,
            visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            segments: const [
              ButtonSegment(value: false, label: Text('AM')),
              ButtonSegment(value: true, label: Text('PM')),
            ],
            selected: {_hour >= 12},
            onSelectionChanged: (v) {
              setState(() {
                bool isPM = v.first;
                int h = _hour % 12;
                _hour = isPM ? h + 12 : h;
              });
            },
          ),
        ],
      ],
    );
  }

  void _submit() async {
    final settings = await ref.read(todoSettingsProvider.future);
    ref.read(todoSettingsProvider.notifier).updateSettings(
      settings.copyWith(
        wakeHour: _hour,
        wakeMinute: _minute,
        askWakeTimeDaily: _askDaily,
        use24HourFormat: _use24Hour,
        lastWakeTimePromptDate: DateTime.now(),
      ),
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

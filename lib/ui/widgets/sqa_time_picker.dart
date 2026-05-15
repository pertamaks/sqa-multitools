import 'package:flutter/material.dart';
import 'sqa_time_segment.dart';
import 'sqa_segmented_button.dart';
import 'sqa_modal.dart';
import 'sqa_design_tokens.dart';
import 'package:material_symbols_icons/symbols.dart';

/// A centralized, premium time picker widget for SQA-Multitools.
///
/// Reuses the aesthetic and interaction model from the Wake Time Prompt,
/// supporting both 12h and 24h formats with scrollable time segments.
class SqaTimePicker extends StatelessWidget {
  final int hour;
  final int minute;
  final bool use24Hour;
  final void Function(int hour, int minute) onTimeChanged;
  final bool showFormatToggle;
  final ValueChanged<bool>? onFormatChanged;

  const SqaTimePicker({
    super.key,
    required this.hour,
    required this.minute,
    required this.use24Hour,
    required this.onTimeChanged,
    this.showFormatToggle = true,
    this.onFormatChanged,
  });

  /// Static helper to show the time picker in a modal dialog.
  static Future<TimeOfDay?> show(
    BuildContext context, {
    required int initialHour,
    required int initialMinute,
    required bool use24Hour,
  }) async {
    int currentHour = initialHour;
    int currentMinute = initialMinute;
    bool currentUse24Hour = use24Hour;

    return showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => SqaModal<void>.custom(
          title: 'Select Trigger Time',
          icon: Symbols.schedule,
          confirmLabel: 'Set Time',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: SqaTokens.spacingMedium),
              SqaTimePicker(
                hour: currentHour,
                minute: currentMinute,
                use24Hour: currentUse24Hour,
                onFormatChanged: (v) => setState(() => currentUse24Hour = v),
                onTimeChanged: (h, m) => setState(() {
                  currentHour = h;
                  currentMinute = m;
                }),
              ),
              const SizedBox(height: SqaTokens.spacingMedium),
            ],
          ),
        ),
      ),
    ).then((value) {
      if (value == true) {
        return TimeOfDay(hour: currentHour, minute: currentMinute);
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    int displayHour = hour;
    if (!use24Hour) {
      displayHour = hour % 12;
      if (displayHour == 0) displayHour = 12;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFormatToggle) ...[
          Center(
            child: SqaSegmentedButton<bool>(
              stretches: false,
              fontSize: 10,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
              segments: const [
                ButtonSegment(value: false, label: Text('12h')),
                ButtonSegment(value: true, label: Text('24h')),
              ],
              selected: {use24Hour},
              onSelectionChanged: (v) => onFormatChanged?.call(v.first),
            ),
          ),
          const SizedBox(height: SqaTokens.spacingMedium),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SqaTimeSegment(
              value: displayHour,
              minValue: use24Hour ? 0 : 1,
              maxValue: use24Hour ? 23 : 12,
              onChanged: (v) {
                if (use24Hour) {
                  onTimeChanged(v, minute);
                } else {
                  bool isPM = hour >= 12;
                  int h = v % 12;
                  onTimeChanged(isPM ? h + 12 : h, minute);
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
              child: Text(
                ':',
                style: TextStyle(fontSize: SqaTokens.fontSizeXXXLarge, fontWeight: FontWeight.bold),
              ),
            ),
            SqaTimeSegment(
              value: minute,
              maxValue: 59,
              onChanged: (v) => onTimeChanged(hour, v),
            ),
            if (!use24Hour) ...[
              const SizedBox(width: SqaTokens.spacingMedium),
              SqaSegmentedButton<bool>(
                stretches: false,
                fontSize: 10,
                visualDensity: const VisualDensity(
                  horizontal: -4,
                  vertical: -4,
                ),
                segments: const [
                  ButtonSegment(value: false, label: Text('AM')),
                  ButtonSegment(value: true, label: Text('PM')),
                ],
                selected: {hour >= 12},
                onSelectionChanged: (v) {
                  bool isPM = v.first;
                  int h = hour % 12;
                  onTimeChanged(isPM ? h + 12 : h, minute);
                },
              ),
            ],
          ],
        ),
      ],
    );
  }
}

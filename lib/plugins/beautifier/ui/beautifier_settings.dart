import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/beautifier_provider.dart';
import '../../../ui/widgets/sqa_settings_tile.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_dropdown.dart';

class BeautifierSettings extends ConsumerWidget {
  const BeautifierSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final autoFormat = ref.watch(
      beautifierProvider.select((s) => s.autoFormat),
    );
    final inputWrap = ref.watch(
      beautifierProvider.select((s) => s.inputWrapText),
    );
    final indentWidth = ref.watch(
      beautifierProvider.select((s) => s.indentWidth),
    );
    final outputWrap = ref.watch(
      beautifierProvider.select((s) => s.outputWrapText),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BEAUTIFIER SETTINGS',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SqaSettingsTile(
          title: 'AUTO-FORMAT ON CHANGE',
          subtitle: 'Format code automatically as you type.',
          trailing: SqaSwitch(
            value: autoFormat,
            onChanged: (val) =>
                ref.read(beautifierProvider.notifier).setAutoFormat(val),
          ),
        ),
        SqaSettingsTile(
          title: 'INDENTATION WIDTH',
          subtitle: 'Number of spaces per indentation level.',
          trailing: SizedBox(
            width: 80,
            child: SqaDropdown<int>(
              value: indentWidth,
              items: [2, 4, 8].map((w) {
                return DropdownMenuItem(value: w, child: Text('$w'));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(beautifierProvider.notifier).setIndentWidth(val);
                }
              },
            ),
          ),
        ),
        SqaSettingsTile(
          title: 'WRAP INPUT TEXT',
          subtitle: 'Allow long lines to wrap in the raw input field.',
          trailing: SqaSwitch(
            value: inputWrap,
            onChanged: (val) =>
                ref.read(beautifierProvider.notifier).setInputWrapText(val),
          ),
        ),
        SqaSettingsTile(
          title: 'WRAP OUTPUT TEXT',
          subtitle: 'Allow long lines to wrap in the beautified field.',
          trailing: SqaSwitch(
            value: outputWrap,
            onChanged: (val) =>
                ref.read(beautifierProvider.notifier).setOutputWrapText(val),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/identity_provider.dart';
import '../providers/dev_provider.dart';
import 'widgets/count_dropdown.dart';
import '../../../ui/widgets/sqa_settings_tile.dart';
import '../../../ui/widgets/sqa_faker_locale_picker.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';

class DataGeneratorSettingsPanel extends ConsumerWidget {
  const DataGeneratorSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(identityProvider);
    final notifier = ref.read(identityProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENERATOR SETTINGS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
        const SqaFakerLocalePicker(),
        const SizedBox(height: SqaTokens.spacingMedium),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: SqaTokens.spacingXSmall),
                  CountDropdown(
                    value: state.quantity,
                    onChanged: (val) {
                      if (val != null) notifier.setQuantity(val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: SqaTokens.spacingLarge),
        SqaSettingsTile(
          title: 'IDENTITY BULLETS',
          subtitle: 'Prefix identity results with a bullet point (•)',
          trailing: SqaSwitch(
            value: state.includeFormatting,
            onChanged: (val) => notifier.setIncludeFormatting(val),
          ),
        ),
        const SizedBox(height: SqaTokens.spacingSmall),
        SqaSettingsTile(
          title: 'DEV BULLETS',
          subtitle: 'Prefix UUID results with a bullet point (•)',
          trailing: SqaSwitch(
            value: ref.watch(devGeneratorProvider).includeFormatting,
            onChanged: (val) => ref.read(devGeneratorProvider.notifier).setIncludeFormatting(val),
          ),
        ),
        SqaSettingsTile(
          title: 'INCLUDE EXTENSION',
          subtitle: 'Include phone extensions (e.g. x123)',
          trailing: SqaSwitch(
            value: state.includeExtension,
            onChanged: (val) => notifier.setIncludeExtension(val),
          ),
        ),
      ],
    );
  }
}

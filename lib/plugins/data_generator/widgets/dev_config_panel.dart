import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/utils/locale_names.dart';
import '../../../ui/widgets/sqa_settings_button.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../providers/dev_provider.dart';
import '../providers/identity_provider.dart';
import '../models/dev_state.dart';

class DevConfigPanel extends ConsumerWidget {
  const DevConfigPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(devGeneratorProvider);
    final notifier = ref.read(devGeneratorProvider.notifier);
    final identityState = ref.watch(identityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.selectedType == DevType.json ||
            state.selectedType == DevType.date) ...[
          if (state.selectedType == DevType.json)
            SqaSegmentedButton<JsonCategory>(
              isChild: true,
              segments: [
                const ButtonSegment(
                  value: JsonCategory.simple,
                  label: Text('Simple'),
                  icon: Icon(Symbols.token),
                ),
                const ButtonSegment(
                  value: JsonCategory.medium,
                  label: Text('Medium'),
                  icon: Icon(Symbols.data_object),
                ),
                const ButtonSegment(
                  value: JsonCategory.complex,
                  label: Text('Complex'),
                  icon: Icon(Symbols.account_tree),
                ),
              ],
              selected: {state.selectedJsonCategory},
              onSelectionChanged: (set) => notifier.setJsonCategory(set.first),
            )
          else
            SqaSegmentedButton<DateCategory>(
              isChild: true,
              segments: [
                const ButtonSegment(
                  value: DateCategory.past,
                  label: Text('Past'),
                  icon: Icon(Symbols.history),
                ),
                const ButtonSegment(
                  value: DateCategory.future,
                  label: Text('Future'),
                  icon: Icon(Symbols.update),
                ),
              ],
              selected: {state.selectedDateCategory},
              onSelectionChanged: (set) => notifier.setDateCategory(set.first),
            ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Clear Button
            IconButton(
              icon: const Icon(Symbols.delete, size: 20),
              onPressed: () => notifier.clear(),
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.outline,
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: SqaStyles.radiusLarge,
                ),
              ),
              tooltip: 'Clear Results',
            ),
            const SizedBox(width: 8),
            SqaButton.tonal(
              label: 'Generate',
              icon: Symbols.wand_stars,
              onPressed: () => notifier.generate(),
              width: 120,
            ),
            const SizedBox(width: 8),
            SqaSettingsButton(
              sourcePluginId: 'com.sqa.data_generator',
              tooltip:
                  '${LocaleNames.getDisplayName(identityState.locale.name)}, ${identityState.quantity} items',
            ),
          ],
        ),
      ],
    );
  }
}

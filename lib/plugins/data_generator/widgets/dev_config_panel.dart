import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/utils/locale_names.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_action_button_group.dart';
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
        SqaActionButtonGroup(
          onClear: () => notifier.clear(),
          actionLabel: 'Generate',
          actionIcon: Symbols.wand_stars,
          onAction: () => notifier.generate(),
          sourcePluginId: 'com.sqa.data_generator',
          settingsTooltip:
              '${LocaleNames.getDisplayName(identityState.locale.name)}, ${identityState.quantity} items',
        ),
      ],
    );
  }
}

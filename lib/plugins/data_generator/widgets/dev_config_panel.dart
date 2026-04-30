import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/utils/locale_names.dart';
import '../../../ui/widgets/sqa_action_button_group.dart';
import '../../../ui/widgets/sqa_modal.dart';
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
        SqaActionButtonGroup(
          onClear: () async {
            if (state.selectedType == DevType.uuid &&
                state.uuidHistory.isNotEmpty) {
              final confirmed = await SqaModal.showDanger(
                context,
                title: 'Clear History',
                message:
                    'Are you sure you want to clear the UUID history? This action cannot be undone.',
                confirmLabel: 'Clear',
              );
              if (confirmed != true) return;
            } else if ((state.resultsMap[state.selectedType] ?? [])
                .isNotEmpty) {
              // Confirmation for other dev results if they exist
              final confirmed = await SqaModal.showDanger(
                context,
                title: 'Clear Results',
                message: 'Discard currently generated results?',
                confirmLabel: 'Discard',
              );
              if (confirmed != true) return;
            }
            notifier.clear();
          },
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/utils/locale_names.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_action_button_group.dart';
import '../providers/identity_provider.dart';
import '../models/identity_state.dart';

class IdentityConfigPanel extends ConsumerStatefulWidget {
  const IdentityConfigPanel({super.key});

  @override
  ConsumerState<IdentityConfigPanel> createState() =>
      _IdentityConfigPanelState();
}

class _IdentityConfigPanelState extends ConsumerState<IdentityConfigPanel> {
  late TextEditingController _domainController;

  @override
  void initState() {
    super.initState();
    _domainController = TextEditingController(
      text: ref.read(identityProvider).customDomain,
    );
  }

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(identityProvider);
    final notifier = ref.read(identityProvider.notifier);

    // Sync controller if state changed from elsewhere (though unlikely here)
    if (_domainController.text != state.customDomain) {
      _domainController.text = state.customDomain;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SqaActionButtonGroup(
          onClear: () => notifier.clear(),
          actionLabel: 'Generate',
          actionIcon: Symbols.wand_stars,
          onAction: () => notifier.generate(),
          sourcePluginId: 'com.sqa.data_generator',
          settingsTooltip:
              '${LocaleNames.getDisplayName(state.locale.name)}, ${state.quantity} items',
        ),
        if (state.selectedType == IdentityType.email) ...[
          const SizedBox(height: 16),
          SqaField(
            label: 'Custom Domain (optional)',
            hintText: 'e.g. google.com',
            controller: _domainController,
            onChanged: notifier.setCustomDomain,
          ),
        ],
      ],
    );
  }
}

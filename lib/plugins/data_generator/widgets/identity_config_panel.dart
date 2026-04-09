import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/utils/locale_names.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_settings_button.dart';
import '../../../ui/widgets/sqa_button.dart';
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              tooltip: 'Clear Results',
            ),
            const SizedBox(width: 8),
            // Generate Button
            SqaButton.tonal(
              label: 'Generate',
              icon: Symbols.wand_stars,
              onPressed: () => notifier.generate(),
              width: 120, // Optional: fixed width for consistency
            ),
            const SizedBox(width: 8),
            // Settings Gear
            SqaSettingsButton(
              sourcePluginId: 'com.sqa.data_generator',
              tooltip:
                  '${LocaleNames.getDisplayName(state.locale.name)}, ${state.quantity} items',
            ),
          ],
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../providers/identity_provider.dart';
import '../models/identity_state.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';

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
        if (state.selectedType == IdentityType.email) ...[
          const SizedBox(height: SqaTokens.spacingLarge),
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

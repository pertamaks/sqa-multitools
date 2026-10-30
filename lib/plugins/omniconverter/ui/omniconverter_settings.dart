import 'package:flutter/material.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';

class OmniConverterSettings extends StatelessWidget {
  const OmniConverterSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: Text(
            'OMNICONVERTER PREFERENCES',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SqaTokens.fontSizeSmall,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SqaCard(
          padding: const EdgeInsets.all(SqaTokens.spacingMedium),
          child: Text(
            'Real-time transformation is active by default. Encodings and formats run entirely locally and securely in-memory without uploading any data.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

class SqaMetadataItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const SqaMetadataItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: SqaTokens.spacingLarge - SqaTokens.spacingXXSmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: SqaTokens.spacingTiny),
        Text(
          text,
          style: TextStyle(
            fontSize: SqaTokens.fontSizeTiny,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

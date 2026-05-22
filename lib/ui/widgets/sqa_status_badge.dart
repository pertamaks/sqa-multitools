import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

class SqaStatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const SqaStatusBadge({super.key, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingSmall + 4, vertical: SqaTokens.spacingXSmall),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: SqaTokens.borderRadiusSmall,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: SqaTokens.fontSizeTiny,
        ),
      ),
    );
  }
}

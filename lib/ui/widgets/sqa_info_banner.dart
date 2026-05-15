import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';
import '../../ui/widgets/sqa_card.dart';

class SqaInfoBanner extends StatelessWidget {
  final String? title;
  final String text;
  final IconData? icon;
  final Color? color;

  const SqaInfoBanner({
    super.key,
    this.title,
    required this.text,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return SqaCard(
      padding: const EdgeInsets.all(SqaTokens.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || icon != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: SqaTokens.spacingLarge, color: effectiveColor),
                  const SizedBox(width: SqaTokens.spacingSmall),
                ],
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: SqaTokens.fontSizeSmall,
                      color: effectiveColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SqaTokens.spacingSmall),
          ],
          Text(text, style: const TextStyle(fontSize: SqaTokens.fontSizeSmall, height: 1.4)),
        ],
      ),
    );
  }
}

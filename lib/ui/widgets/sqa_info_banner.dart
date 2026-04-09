import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null || icon != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: effectiveColor),
                  const SizedBox(width: 8),
                ],
                if (title != null)
                  Text(
                    title!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: effectiveColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

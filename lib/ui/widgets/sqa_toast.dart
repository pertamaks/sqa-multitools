import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'sqa_styles.dart';

enum SqaToastType { success, error, info, warning }

class SqaToast {
  static void show(
    BuildContext context,
    String message, {
    SqaToastType type = SqaToastType.info,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color iconColor;
    IconData icon;

    switch (type) {
      case SqaToastType.success:
        icon = Symbols.check_circle;
        iconColor = Colors.green.shade600;
        break;
      case SqaToastType.error:
        icon = Symbols.error;
        iconColor = colorScheme.error;
        break;
      case SqaToastType.warning:
        icon = Symbols.warning;
        iconColor = Colors.orange.shade800;
        break;
      case SqaToastType.info:
        icon = Symbols.info;
        iconColor = colorScheme.primary;
        break;
    }

    // Use hideCurrentSnackBar instead of clearSnackBars for a smoother transition
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    // Adhere to GEMINI.md: Labels should be 11px labelSmall bold
    final textStyle =
        theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ) ??
        const TextStyle(fontSize: 11, fontWeight: FontWeight.bold);

    final textPainter = TextPainter(
      text: TextSpan(text: message, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // Icon (16) + Gap (8) + Horizontal Padding (16*2) + TextWidth + small buffer
    final calculatedWidth = textPainter.width + 16 + 8 + 32 + 8;
    final maxWidth = MediaQuery.of(context).size.width - 48;
    final finalWidth = calculatedWidth.clamp(120.0, maxWidth);

    messenger.showSnackBar(
      SnackBar(
        width: finalWidth,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        // Translucent "Glassmorphism" background for less intrusion
        backgroundColor: colorScheme.surfaceContainerHigh.withValues(
          alpha: 0.9,
        ),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: SqaStyles.radiusLarge,
          // Sophisticated border that matches the surface background in a darker state
          side: BorderSide(color: colorScheme.surfaceContainerHighest),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

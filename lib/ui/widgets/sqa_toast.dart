import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'sqa_styles.dart';

enum SqaToastType { success, error, info, warning }

class SqaToast {
  static void show(
    BuildContext context,
    String message, {
    SqaToastType type = SqaToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case SqaToastType.success:
        backgroundColor = Colors.green.shade50;
        icon = Symbols.check_circle;
        iconColor = Colors.green.shade700;
        break;
      case SqaToastType.error:
        backgroundColor = colorScheme.errorContainer;
        icon = Symbols.error;
        iconColor = colorScheme.onErrorContainer;
        break;
      case SqaToastType.warning:
        backgroundColor = Colors.orange.shade50;
        icon = Symbols.warning;
        iconColor = Colors.orange.shade900;
        break;
      case SqaToastType.info:
        backgroundColor = colorScheme.primaryContainer;
        icon = Symbols.info;
        iconColor = colorScheme.onPrimaryContainer;
        break;
    }

    // Use hideCurrentSnackBar instead of clearSnackBars for a smoother transition
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    // Calculate width for "fit content" behavior
    final textStyle = TextStyle(
      color: iconColor,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
    );

    final textPainter = TextPainter(
      text: TextSpan(text: message, style: textStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // Icon (18) + Gap (10) + Horizontal Padding (16*2) + TextWidth + small buffer
    final calculatedWidth = textPainter.width + 18 + 10 + 32 + 8;
    // Cap width to screen width with margin
    final maxWidth = MediaQuery.of(context).size.width - 48;
    final finalWidth = calculatedWidth.clamp(120.0, maxWidth);

    messenger.showSnackBar(
      SnackBar(
        width: finalWidth,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: backgroundColor,
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: SqaStyles.radiusLarge,
          side: BorderSide(color: iconColor.withValues(alpha: 0.2)),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 10),
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

import 'package:flutter/material.dart';

/// A widget that intelligently handles text truncation.
///
/// It uses [TextPainter] to detect if the text is overflowing its current
/// constraints. If truncation is detected, it wraps the text in a [Tooltip]
/// that displays the full content on hover or long-press.
class SqaSmartText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final VoidCallback? onTap;

  const SqaSmartText({
    super.key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final effectiveStyle = style ?? defaultTextStyle.style;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: effectiveStyle),
          maxLines: maxLines,
          textAlign: textAlign,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.of(context).textScaler,
        )..layout(maxWidth: constraints.maxWidth);

        final isTruncated = textPainter.didExceedMaxLines;

        final textWidget = Text(
          text,
          style: effectiveStyle,
          maxLines: maxLines,
          textAlign: textAlign,
          overflow: overflow,
        );

        final Widget result = isTruncated
            ? Tooltip(
                message: text,
                waitDuration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
                child: textWidget,
              )
            : textWidget;

        if (onTap != null) {
          return GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: result,
          );
        }

        return result;
      },
    );
  }
}

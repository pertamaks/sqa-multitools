import 'package:flutter/material.dart';
import 'sqa_styles.dart';

class SqaCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final BorderSide? borderSide;
  final List<BoxShadow>? boxShadow;

  const SqaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
    this.borderSide,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveRadius = borderRadius ?? SqaStyles.radiusLarge;
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHigh,
        borderRadius: effectiveRadius,
        boxShadow: boxShadow,
        border: Border.fromBorderSide(
          borderSide ??
              BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
        ),
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}

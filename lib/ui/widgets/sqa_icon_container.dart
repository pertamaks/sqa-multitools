import 'package:flutter/material.dart';
import 'sqa_styles.dart';

class SqaIconContainer extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final BorderRadius? borderRadius;
  final bool isCircular;
  final VoidCallback? onTap;

  const SqaIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.backgroundColor,
    this.size = 32,
    this.iconSize = 18,
    this.borderRadius,
    this.isCircular = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    Widget content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? effectiveColor.withValues(alpha: 0.1),
        borderRadius:
            isCircular ? null : (borderRadius ?? SqaStyles.radiusMedium),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Center(
        child: Icon(icon, color: effectiveColor, size: iconSize),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        customBorder: isCircular ? const CircleBorder() : null,
        borderRadius: isCircular ? null : (borderRadius ?? SqaStyles.radiusMedium),
        child: content,
      );
    }

    return content;
  }
}

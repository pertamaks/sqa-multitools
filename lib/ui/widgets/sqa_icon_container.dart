import 'package:flutter/material.dart';
import 'sqa_styles.dart';

class SqaIconContainer extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final double iconSize;
  final BorderRadius? borderRadius;
  final bool isCircular;

  const SqaIconContainer({
    super.key,
    required this.icon,
    this.color,
    this.size = 32,
    this.iconSize = 18,
    this.borderRadius,
    this.isCircular = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.1),
        borderRadius: isCircular
            ? null
            : (borderRadius ?? SqaStyles.radiusMedium),
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: Center(
        child: Icon(icon, color: effectiveColor, size: iconSize),
      ),
    );
  }
}

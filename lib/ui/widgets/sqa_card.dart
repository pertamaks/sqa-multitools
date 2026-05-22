import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

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
    final effectiveRadius = borderRadius ?? SqaTokens.borderRadiusLarge;
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: effectiveRadius,
        boxShadow: boxShadow,
        border: Border.fromBorderSide(
          borderSide ?? BorderSide(color: Colors.transparent),
        ),
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveRadius,
          mouseCursor: onTap != null ? SystemMouseCursors.click : null,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(SqaTokens.spacingLarge),
            child: child,
          ),
        ),
      ),
    );

    return card;
  }
}

import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

/// A premium, minimal icon button that features a luminescent glow effect on hover.
///
/// Instead of a solid background shape, this button applies a [Shadow] directly to the
/// icon glyph, creating a 'neon' or 'glow' effect.
class SqaHoverIconButton extends StatefulWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final VoidCallback onPressed;
  final String? tooltip;
  final double iconSize;
  final double padding;
  final Color? color;
  final Color? hoverColor;
  final Color? backgroundColor;
  final double? weight;
  final bool isSelected;
  final BorderRadius? borderRadius;

  const SqaHoverIconButton({
    super.key,
    this.icon,
    this.iconWidget,
    required this.onPressed,
    this.tooltip,
    this.iconSize = SqaTokens.spacingLarge,
    this.padding = SqaTokens.spacingSmall,
    this.color,
    this.hoverColor,
    this.backgroundColor,
    this.weight,
    this.isSelected = false,
    this.borderRadius,
  }) : assert(icon != null || iconWidget != null, 'Either icon or iconWidget must be provided');

  @override
  State<SqaHoverIconButton> createState() => _SqaHoverIconButtonState();
}

class _SqaHoverIconButtonState extends State<SqaHoverIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Resolve colors
    final baseColor = widget.color ?? colorScheme.onSurface;
    final activeColor = widget.hoverColor ?? colorScheme.primary;

    // Combine selection and hover state for the final look
    final isEffectActive = _isHovered || widget.isSelected;
    final currentColor = isEffectActive ? activeColor : baseColor;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.15 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: IconButton(
          icon: widget.iconWidget ?? Icon(
            widget.icon!,
            size: widget.iconSize,
            weight: widget.weight,
          ),
          onPressed: widget.onPressed,
          tooltip: widget.tooltip,
          color: currentColor,
          style: IconButton.styleFrom(
            padding: EdgeInsets.all(widget.padding),
            backgroundColor: widget.backgroundColor ?? Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            shape: widget.borderRadius != null 
                ? RoundedRectangleBorder(borderRadius: widget.borderRadius!) 
                : null,
          ),
        ),
      ),
    );
  }
}

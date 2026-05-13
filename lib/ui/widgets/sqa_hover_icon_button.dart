import 'package:flutter/material.dart';

/// A premium, minimal icon button that features a luminescent glow effect on hover.
///
/// Instead of a solid background shape, this button applies a [Shadow] directly to the
/// icon glyph, creating a 'neon' or 'glow' effect.
class SqaHoverIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final double iconSize;
  final double padding;
  final Color? color;
  final Color? hoverColor;
  final double? weight;
  final bool isSelected;

  const SqaHoverIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.iconSize = 16,
    this.padding = 8,
    this.color,
    this.hoverColor,
    this.weight,
    this.isSelected = false,
  });

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
          icon: Icon(
            widget.icon,
            size: widget.iconSize,
            weight: widget.weight,
          ),
          onPressed: widget.onPressed,
          tooltip: widget.tooltip,
          color: currentColor,
          style: IconButton.styleFrom(
            padding: EdgeInsets.all(widget.padding),
            backgroundColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
        ),
      ),
    );
  }
}

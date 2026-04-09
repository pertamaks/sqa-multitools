import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'sqa_card.dart';
import 'sqa_styles.dart';

/// A centralized floating action bar for overlays (Screenshot, Screen Recorder).
///
/// Features smart boundary detection and dynamic width based on children.
class SqaFloatingBar extends StatelessWidget {
  /// The selection rectangle to position the bar relative to.
  /// If null, the bar will be centered at the bottom.
  final Rect? selectionRect;

  /// The action buttons and widgets to display in the bar.
  final List<Widget> children;

  /// Estimated height of the bar to prevent layout jitter during positioning.
  final double estimatedHeight;

  /// Estimated width per action button (used for initial boundary detection).
  final double estimatedWidthPerChild;

  /// Map of specific indices of children that are wider than a standard button.
  /// (e.g. the Timer Row in screen recorder)
  final Map<int, double>? customWidths;

  /// Padding from the edge of the screen.
  final double screenPadding;

  /// Padding from the selection rectangle.
  final double selectionPadding;

  const SqaFloatingBar({
    super.key,
    this.selectionRect,
    required this.children,
    this.estimatedHeight = 52.0,
    this.estimatedWidthPerChild = 44.0,
    this.customWidths,
    this.screenPadding = 12.0,
    this.selectionPadding = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    // We use MediaQuery instead of LayoutBuilder to avoid Positioned/ParentData errors.
    final size = MediaQuery.of(context).size;
    final double maxHeight = size.height;
    final double maxWidth = size.width;

    // Calculate dynamic base width based on children
    double totalEstimatedWidth = 32.0; // card padding/borders
    for (int i = 0; i < children.length; i++) {
      totalEstimatedWidth += customWidths?[i] ?? estimatedWidthPerChild;
    }

    double top;
    double left;

    if (selectionRect != null) {
      // Default: Top-Right of selection
      top = selectionRect!.top - estimatedHeight - selectionPadding;
      left = selectionRect!.right - totalEstimatedWidth;

      // Smart Boundary Detection - Vertical
      if (top < screenPadding) {
        // No space above, try below
        top = selectionRect!.bottom + selectionPadding;

        // If still no space below, put it inside at the top
        if (top + estimatedHeight > maxHeight - screenPadding) {
          top = selectionRect!.top + selectionPadding;
        }
      }

      // Smart Boundary Detection - Horizontal
      if (left + totalEstimatedWidth > maxWidth - screenPadding) {
        left = maxWidth - totalEstimatedWidth - screenPadding;
      }
      if (left < screenPadding) {
        left = screenPadding;
      }
    } else {
      // Fallback: Center-Bottom (e.g. Full Screen Recording)
      top = maxHeight - estimatedHeight - 60;
      left = (maxWidth - totalEstimatedWidth) / 2;
    }

    // Final Clamping to screen bounds
    top = top.clamp(
      screenPadding,
      math.max(screenPadding, maxHeight - estimatedHeight - screenPadding),
    );
    left = left.clamp(
      screenPadding,
      math.max(screenPadding, maxWidth - totalEstimatedWidth - screenPadding),
    );

    return Positioned(
      left: left,
      top: top,
      child: SqaCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: IntrinsicHeight(
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// A standardized action button for the SqaFloatingBar.
class SqaFloatingBarButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;
  final bool isSelected;
  final bool isPrimary;
  final Color? color;
  final double iconSize;

  const SqaFloatingBarButton({
    super.key,
    required this.icon,
    this.tooltip,
    required this.onPressed,
    this.isSelected = false,
    this.isPrimary = false,
    this.color,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget button = IconButton(
      icon: Icon(icon, size: iconSize),
      onPressed: onPressed,
      style:
          IconButton.styleFrom(
            backgroundColor: isPrimary
                ? colorScheme.primary
                : (isSelected ? colorScheme.primaryContainer : null),
            foregroundColor: isPrimary
                ? colorScheme.onPrimary
                : (isSelected
                      ? colorScheme.onPrimaryContainer
                      : color ?? colorScheme.onSurface),
            shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
            minimumSize: const Size(36, 36),
            padding: EdgeInsets.zero,
          ).copyWith(
            overlayColor: SqaStyles.buttonOverlay(context, baseColor: color),
          ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: button,
    );
  }
}

/// A standardized vertical divider for grouping actions in SqaFloatingBar.
class SqaFloatingBarDivider extends StatelessWidget {
  const SqaFloatingBarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(width: 16, indent: 8, endIndent: 8);
  }
}

/// A standardized color picker dot for SqaFloatingBar.
class SqaFloatingBarColorPicker extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;

  const SqaFloatingBarColorPicker({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2 + 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

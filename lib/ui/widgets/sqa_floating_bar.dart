import 'package:flutter/material.dart';
import 'sqa_card.dart';
import 'sqa_styles.dart';

/// A centralized floating action bar for overlays (Screenshot, Screen Recorder).
///
/// Features smart boundary detection and dynamic width based on children.
class SqaFloatingBar extends StatelessWidget {
  /// The action buttons and widgets to display in the bar.
  final List<Widget> children;

  /// Optional callback when the drag handle is dragged.
  final Offset? position;

  const SqaFloatingBar({super.key, required this.children, this.position});

  @override
  Widget build(BuildContext context) {
    return SqaCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: IntrinsicHeight(
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

/// A standardized action button for the SqaFloatingBar.
class SqaFloatingBarButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isPrimary;
  final bool isLoading;
  final Color? color;
  final double iconSize;

  const SqaFloatingBarButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
    this.isSelected = false,
    this.isPrimary = false,
    this.isLoading = false,
    this.color,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = Icon(icon, size: iconSize);
    if (isLoading) {
      content = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      );
    }

    Widget button = IconButton(
      icon: content,
      onPressed: isLoading ? null : onPressed,
      style: IconButton.styleFrom(
        backgroundColor: isSelected ? colorScheme.primaryContainer : null,
        foregroundColor: isSelected
            ? colorScheme.onPrimaryContainer
            : color ?? colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
      ).copyWith(
        overlayColor: SqaStyles.buttonOverlay(context, baseColor: color, silent: true),
      ),
    );

    if (tooltip != null && !isLoading) {
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

/// A standardized drag handle for the SqaFloatingBar.
class SqaFloatingBarDragHandle extends StatelessWidget {
  final void Function(DragUpdateDetails details)? onDragUpdate;
  final void Function(DragStartDetails details)? onDragStart;
  final VoidCallback? onDragEnd;

  const SqaFloatingBarDragHandle({
    super.key,
    this.onDragUpdate,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: onDragStart,
      onPanUpdate: onDragUpdate,
      onPanEnd: onDragEnd != null ? (_) => onDragEnd!() : null,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(
            Icons.drag_indicator,
            size: 20,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

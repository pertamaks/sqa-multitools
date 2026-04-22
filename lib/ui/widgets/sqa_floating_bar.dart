import 'package:flutter/material.dart';
import 'sqa_card.dart';
import 'sqa_styles.dart';
import 'sqa_fade_wrapper.dart';
import 'sqa_scroll_behavior.dart';

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
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        constraints: const BoxConstraints(maxWidth: 600), // Limit total width
        child: SqaFadeWrapper(
          axis: Axis.horizontal,
          child: ScrollConfiguration(
            behavior: const SqaMouseDragScrollBehavior(),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A standardized action button for the SqaFloatingBar.
class SqaFloatingBarButton extends StatefulWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final bool isSelected;
  final bool isPrimary;
  final bool isLoading;
  final Color? color;
  final double iconSize;

  /// Optional vertical expansion action
  final IconData? secondaryIcon;
  final VoidCallback? secondaryOnPressed;
  final String? secondaryTooltip;

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
    this.secondaryIcon,
    this.secondaryOnPressed,
    this.secondaryTooltip,
  });

  @override
  State<SqaFloatingBarButton> createState() => _SqaFloatingBarButtonState();
}

class _SqaFloatingBarButtonState extends State<SqaFloatingBarButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget content = Icon(widget.icon, size: widget.iconSize);
    if (widget.isLoading) {
      content = SizedBox(
        width: widget.iconSize,
        height: widget.iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      );
    }

    Widget button = IconButton(
      icon: content,
      onPressed: widget.isLoading ? null : widget.onPressed,
      style: IconButton.styleFrom(
        backgroundColor: widget.isSelected ? colorScheme.primaryContainer : null,
        foregroundColor: widget.isSelected
            ? colorScheme.onPrimaryContainer
            : widget.color ?? colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
      ).copyWith(
        overlayColor: SqaStyles.buttonOverlay(context, baseColor: widget.color, silent: true),
      ),
    );

    // Wrap in Horizontal Expansion logic
    final bool hasSecondary = widget.secondaryIcon != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              color: widget.isSelected 
                ? colorScheme.primaryContainer 
                : (_isHovered && hasSecondary) 
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                  : null,
              borderRadius: SqaStyles.radiusMedium,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Primary Button
                Tooltip(
                  message: widget.tooltip ?? '',
                  child: button,
                ),
                // Horizontal Extension
                if (hasSecondary && _isHovered)
                  Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: IconButton(
                      icon: Icon(widget.secondaryIcon, size: widget.iconSize),
                      tooltip: widget.secondaryTooltip,
                      onPressed: widget.secondaryOnPressed,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      color: widget.color ?? colorScheme.onSurface,
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: SqaStyles.radiusMedium,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
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
        cursor: SystemMouseCursors.basic,
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

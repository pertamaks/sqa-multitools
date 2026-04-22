import 'package:flutter/material.dart';
import 'sqa_card.dart';
import 'sqa_styles.dart';
import 'sqa_fade_wrapper.dart';
import 'sqa_scroll_behavior.dart';
import 'sqa_inline_tooltip.dart';
import 'sqa_scroll_visibility.dart';

/// A centralized floating action bar for overlays (Screenshot, Screen Recorder).
///
/// Features smart boundary detection and dynamic width based on children.
class SqaFloatingBar extends StatefulWidget {
  /// The action buttons and widgets to display in the bar.
  final List<Widget> children;

  /// Fixed widgets anchored to the left.
  final List<Widget>? leading;

  /// Fixed widgets anchored to the right.
  final List<Widget>? trailing;
  final Offset? position;

  const SqaFloatingBar({
    super.key,
    required this.children,
    this.leading,
    this.trailing,
    this.position,
  });

  @override
  State<SqaFloatingBar> createState() => _SqaFloatingBarState();
}

/// An internal scope to mark the toolbar context.
class SqaFloatingBarScope extends InheritedWidget {
  const SqaFloatingBarScope({
    super.key,
    required super.child,
  });

  static SqaFloatingBarScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SqaFloatingBarScope>();
  }

  @override
  bool updateShouldNotify(SqaFloatingBarScope oldWidget) => false;
}

class _SqaFloatingBarState extends State<SqaFloatingBar> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SqaCard(
      padding: EdgeInsets.zero,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        constraints: const BoxConstraints(maxWidth: 800), // Slightly wider for Text Editor
        child: SqaFloatingBarScope(
          child: SqaInlineTooltip(
            scrollController: _scrollController,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Fixed Leading Anchor
                if (widget.leading != null) ...[
                  ...widget.leading!,
                  const SizedBox(width: 4),
                ],

                // Flexible Scrollable Center
                Flexible(
                  child: SqaFadeWrapper(
                    axis: Axis.horizontal,
                    child: ScrollConfiguration(
                      behavior: const SqaMouseDragScrollBehavior(),
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: widget.children,
                        ),
                      ),
                    ),
                  ),
                ),

                // Fixed Trailing Anchor
                if (widget.trailing != null) ...[
                  const SizedBox(width: 4),
                  ...widget.trailing!,
                ],
              ],
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

class _SqaFloatingBarButtonState extends State<SqaFloatingBarButton> with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _expandToLeft = false;
  double _lastWidth = 0.0;
  late AnimationController _expansionController;
  late Animation<double> _expansionAnimation;

  @override
  void initState() {
    super.initState();
    _expansionController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expansionAnimation = CurvedAnimation(
      parent: _expansionController,
      curve: Curves.easeOutCubic,
    );

    // Sync-Scroll Listener: Move scroll logic OUT of build phase to prevent crashes.
    _expansionController.addListener(_onAnimationUpdate);
  }

  void _onAnimationUpdate() {
    final bool hasSecondary = widget.secondaryIcon != null;
    if (!mounted || !hasSecondary || !_expandToLeft || !_isHovered) return;
    
    final currentWidth = _expansionAnimation.value * 40.0;
    final scrollable = Scrollable.maybeOf(context);
    
    if (scrollable != null) {
      final position = scrollable.position;
      final delta = currentWidth - _lastWidth;
      if (delta != 0 && position.hasPixels) {
        position.jumpTo(position.pixels + delta);
      }
    }
    _lastWidth = currentWidth;
  }

  @override
  void dispose() {
    _expansionController.removeListener(_onAnimationUpdate);
    _expansionController.dispose();
    super.dispose();
  }

  void _updateExpansionDirection() {
    if (!mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Smart Boundary Detection (Toolbar-Aware ONLY)
    bool hitsToolbarEdge = false;
    
    // Find the toolbar ancestor state to get its render box safely
    final barState = context.findAncestorStateOfType<_SqaFloatingBarState>();
    final barBox = barState?.context.findRenderObject() as RenderBox?;

    if (barBox != null) {
      // Calculate button position RELATIVE to the toolbar
      final localPos = renderBox.localToGlobal(Offset.zero, ancestor: barBox);
      final buttonRightLocal = localPos.dx + renderBox.size.width;
      
      // Pivot if within 20px of the toolbar's internal right edge
      // This perfectly captures the end buttons (considering the 16px bar padding).
      hitsToolbarEdge = (barBox.size.width - buttonRightLocal) < 20.0;
    }

    setState(() {
      _expandToLeft = hitsToolbarEdge;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasSecondary = widget.secondaryIcon != null;

    // Primary Icon Content
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

    // Standardized Primary Button
    Widget primaryButton = IconButton(
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

    // Optional Secondary Menu Button (appears during expansion)
    final Widget secondaryWidget = hasSecondary
        ? Padding(
            padding: EdgeInsets.only(
              left: _expandToLeft ? 4.0 : 0.0,
              right: _expandToLeft ? 0.0 : 4.0,
            ),
            child: SqaInlineTooltipTrigger(
              tooltip: widget.secondaryTooltip,
              child: IconButton(
                icon: Icon(widget.secondaryIcon, size: widget.iconSize),
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
          )
        : const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          _updateExpansionDirection();
          setState(() {
            _isHovered = true;
            if (hasSecondary) _expansionController.forward();
          });
        },
        onExit: (_) => setState(() {
          _isHovered = false;
          if (hasSecondary) _expansionController.reverse();
          _lastWidth = 0.0;
        }),
        child: Align(
          alignment: _expandToLeft ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: _expansionAnimation,
            builder: (context, child) {
              // The growth occurs toward the center, while the scroll offset is 
              // simultaneously adjusted in _onAnimationUpdate to keep the primary
              // icon visually static on the screen.
              final animatedWidth = hasSecondary ? (_expansionAnimation.value * 40.0) : 0.0;
              
              return Container(
                width: 40.0 + animatedWidth,
                height: 40.0,
                decoration: BoxDecoration(
                  color: widget.isSelected 
                    ? colorScheme.primaryContainer 
                    : (_isHovered && hasSecondary) 
                      ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                      : null,
                  borderRadius: SqaStyles.radiusMedium,
                ),
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: 80.0,
                    minWidth: 40.0,
                    alignment: _expandToLeft ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasSecondary && _isHovered && _expandToLeft) 
                          SqaScrollVisibilityTrigger(child: secondaryWidget),
                        SqaInlineTooltipTrigger(
                          tooltip: widget.tooltip,
                          child: primaryButton,
                        ),
                        if (hasSecondary && _isHovered && !_expandToLeft) 
                          SqaScrollVisibilityTrigger(child: secondaryWidget),
                      ],
                    ),
                  ),
                ),
              );
            },
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Center(
        child: Container(
          width: 1,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2 + 4),
        hoverColor: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        splashFactory: NoSplash.splashFactory,
        child: SqaInlineTooltipTrigger(
          tooltip: 'Select Color',
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.grey.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A standardized drag handle for the SqaFloatingBar.
class SqaFloatingBarDragHandle extends StatefulWidget {
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
  State<SqaFloatingBarDragHandle> createState() => _SqaFloatingBarDragHandleState();
}

class _SqaFloatingBarDragHandleState extends State<SqaFloatingBarDragHandle> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SqaInlineTooltipTrigger(
      tooltip: 'Drag to Move',
      child: GestureDetector(
        onPanStart: widget.onDragStart,
        onPanUpdate: widget.onDragUpdate,
        onPanEnd: widget.onDragEnd != null ? (_) => widget.onDragEnd!() : null,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 2.0),
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: _isHovered
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.04)
                  : Colors.transparent,
              borderRadius: SqaStyles.radiusMedium,
            ),
            child: Icon(
              Icons.drag_indicator,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

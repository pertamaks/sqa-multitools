import 'dart:async';
import 'package:flutter/material.dart';
import 'sqa_card.dart';
import 'sqa_styles.dart';
import 'sqa_fade_wrapper.dart';
import 'sqa_scroll_behavior.dart';
import 'sqa_inline_tooltip.dart';
import 'sqa_scroll_visibility.dart';
import 'sqa_hover_icon_button.dart';

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
  const SqaFloatingBarScope({super.key, required super.child});

  static SqaFloatingBarScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SqaFloatingBarScope>();
  }

  @override
  bool updateShouldNotify(SqaFloatingBarScope oldWidget) => false;
}

class _SqaFloatingBarState extends State<SqaFloatingBar>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  bool _isScrolling = false;
  bool _isHovered = false;
  bool _isExpanded = false;
  Timer? _scrollEndTimer;
  Timer? _hoverTimer;
  Timer? _expandTimer;

  bool get isScrolling => _isScrolling;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    _scrollEndTimer?.cancel();
    if (!_isScrolling) {
      setState(() {
        _isScrolling = true;
      });
    }

    _scrollEndTimer = Timer(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isScrolling = false;
        });
      }
    });
  }

  void _setHover(bool hovered) {
    _hoverTimer?.cancel();
    if (hovered) {
      setState(() => _isHovered = true);
    } else {
      _hoverTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() => _isHovered = false);
        }
      });
    }
  }

  void _setExpanded(bool expanded) {
    _expandTimer?.cancel();
    if (expanded) {
      setState(() => _isExpanded = true);
    } else {
      // Small delay before collapsing to prevent accidental closure
      _expandTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _isExpanded = false);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollEndTimer?.cancel();
    _hoverTimer?.cancel();
    _expandTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
 
    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) {
        _setHover(false);
        _setExpanded(false);
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: _isHovered ? 1.0 : 0.8,
        curve: Curves.easeInOut,
        child: SqaCard(
          padding: EdgeInsets.zero,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          borderSide: BorderSide.none,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            if (_isHovered)
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            constraints: BoxConstraints(
              maxWidth: 800,
              minWidth: _isExpanded ? 100 : 40,
            ),
            child: SqaFloatingBarScope(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Fixed Leading Anchor (Always visible)
                  if (widget.leading != null) ...[...widget.leading!],
 
                  // Flexible Scrollable Center (Collapses)
                  Flexible(
                    child: MouseRegion(
                      onEnter: (_) => _setExpanded(true),
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.centerLeft,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _isExpanded
                              ? Padding(
                                  key: const ValueKey('tools'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: SqaFadeWrapper(
                                    axis: Axis.horizontal,
                                    child: ScrollConfiguration(
                                      behavior:
                                          const SqaMouseDragScrollBehavior(),
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
                                )
                              : Padding(
                                  key: const ValueKey('more'),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Icon(
                                    Icons.more_horiz,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
 
                  // Fixed Trailing Anchor (Always visible)
                  if (widget.trailing != null) ...[...widget.trailing!],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A data model for secondary actions in a [SqaFloatingBarButton].
class SqaFloatingSubAction {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;

  const SqaFloatingSubAction({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });
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

  /// Optional list of secondary expansion actions (max 5 recommended)
  final List<SqaFloatingSubAction>? secondaryActions;

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
    this.secondaryActions,
  });

  @override
  State<SqaFloatingBarButton> createState() => _SqaFloatingBarButtonState();
}

class _SqaFloatingBarButtonState extends State<SqaFloatingBarButton>
    with TickerProviderStateMixin {
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
    final bool hasSecondary = widget.secondaryActions?.isNotEmpty ?? false;
    // Remove !_isHovered check so we can handle retraction deltas
    if (!mounted || !hasSecondary || !_expandToLeft) return;

    final totalSecondaryWidth = widget.secondaryActions!.length * 40.0;
    final currentWidth = _expansionAnimation.value * totalSecondaryWidth;
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
      final totalSecondaryWidth = (widget.secondaryActions?.length ?? 0) * 40.0;

      // Calculate button position RELATIVE to the toolbar
      final localPos = renderBox.localToGlobal(Offset.zero, ancestor: barBox);
      final buttonRightLocal = localPos.dx + renderBox.size.width;

      // Pivot if expanding to the right would exceed the bar width
      hitsToolbarEdge =
          (buttonRightLocal + totalSecondaryWidth) > barBox.size.width;
    }

    setState(() {
      _expandToLeft = hitsToolbarEdge;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasSecondary = widget.secondaryActions?.isNotEmpty ?? false;
    final secondaryActions = widget.secondaryActions ?? [];

    // Primary Icon Content
    if (widget.isLoading) {
      // Logic for loading state could be handled here or inside SqaHoverIconButton
    }

    // Standardized Primary Button
    Widget primaryButton = SqaHoverIconButton(
      icon: widget.icon,
      onPressed: widget.isLoading ? () {} : widget.onPressed ?? () {},
      tooltip: widget.tooltip ?? '',
      isSelected: widget.isSelected,
      iconSize: widget.iconSize,
      color: widget.color,
    );

    // List of Secondary Menu Buttons
    final List<Widget> secondaryWidgets = secondaryActions.map((action) {
      return SqaInlineTooltipTrigger(
        tooltip: action.tooltip,
        child: SqaHoverIconButton(
          icon: action.icon,
          onPressed: action.onPressed,
          tooltip: action.tooltip ?? '',
          iconSize: widget.iconSize,
          color: action.color ?? widget.color,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: MouseRegion(
        hitTestBehavior: HitTestBehavior.opaque,
        onEnter: (_) {
          _updateExpansionDirection();

          // Find the bar state to check if we are currently scrolling/locked
          final barState = context
              .findAncestorStateOfType<_SqaFloatingBarState>();
          if (barState != null && barState.isScrolling) {
            return; // Wait for scrolling to settle
          }

          // Halt any active scroll momentum before starting expansion
          // This prevents the 'Sync-Scroll' logic from fighting with active scroll physics.
          final scrollable = Scrollable.maybeOf(context);
          if (scrollable != null && scrollable.position.hasPixels) {
            final position = scrollable.position;
            position.jumpTo(position.pixels); // Immediately stop momentum
          }

          setState(() {
            _isHovered = true;
            if (hasSecondary) _expansionController.forward();
          });
        },
        onExit: (_) => setState(() {
          _isHovered = false;
          if (hasSecondary) _expansionController.reverse();
        }),
        child: Align(
          alignment: _expandToLeft
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: _expansionAnimation,
            builder: (context, child) {
              final totalSecondaryWidth = secondaryActions.length * 40.0;
              final animatedWidth = hasSecondary
                  ? (_expansionAnimation.value * totalSecondaryWidth)
                  : 0.0;

              return Container(
                width: 40.0 + animatedWidth,
                height: 40.0,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? colorScheme.primaryContainer
                      : (_isHovered && hasSecondary)
                      ? theme.colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        )
                      : null,
                  borderRadius: SqaStyles.radiusMedium,
                ),
                child: ClipRect(
                  child: OverflowBox(
                    maxWidth: 40.0 + totalSecondaryWidth,
                    minWidth: 40.0,
                    alignment: _expandToLeft
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasSecondary && _isHovered && _expandToLeft)
                          ...secondaryWidgets.reversed.map(
                            (w) => SqaScrollVisibilityTrigger(child: w),
                          ),
                        SqaInlineTooltipTrigger(
                          tooltip: widget.tooltip,
                          child: primaryButton,
                        ),
                        if (hasSecondary && _isHovered && !_expandToLeft)
                          ...secondaryWidgets.map(
                            (w) => SqaScrollVisibilityTrigger(child: w),
                          ),
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
  State<SqaFloatingBarDragHandle> createState() =>
      _SqaFloatingBarDragHandleState();
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

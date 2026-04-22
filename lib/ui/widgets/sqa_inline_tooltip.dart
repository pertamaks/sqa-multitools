import 'dart:async';
import 'package:flutter/material.dart';

/// A centralized state for the inline tooltip overlay.
class _SqaInlineTooltipState extends InheritedWidget {
  final void Function(String? text, Offset? globalPos) onHover;

  const _SqaInlineTooltipState({
    required this.onHover,
    required super.child,
  });

  @override
  bool updateShouldNotify(_SqaInlineTooltipState oldWidget) => false;
}

/// A premium, non-obtrusive tooltip that appears as an inline gradient overlay.
///
/// It flips its alignment based on the hovered item's position relative to the
/// viewport center, ensuring context is shown without obscuring the active tool.
class SqaInlineTooltip extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final double flipThreshold; // 0.0 to 1.0, default 0.5 (center)
  final Color? backgroundColor;

  const SqaInlineTooltip({
    super.key,
    required this.child,
    this.scrollController,
    this.flipThreshold = 0.5,
    this.backgroundColor,
  });

  static void show(BuildContext context, String? text, [Offset? globalPos]) {
    final state = context.dependOnInheritedWidgetOfExactType<_SqaInlineTooltipState>();
    state?.onHover(text, globalPos);
  }

  @override
  State<SqaInlineTooltip> createState() => _SqaInlineTooltipOverlayState();
}

class _SqaInlineTooltipOverlayState extends State<SqaInlineTooltip> {
  String? _hoveredTooltip;
  bool _alignLeft = false;
  bool _isScrolling = false;
  Timer? _scrollEndTimer;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(SqaInlineTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _scrollEndTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    _scrollEndTimer?.cancel();
    if (!_isScrolling) {
      setState(() {
        _isScrolling = true;
        _hoveredTooltip = null;
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

  void _handleHover(String? text, Offset? globalPos) {
    if (_isScrolling) return;

    setState(() {
      if (text == null || globalPos == null) {
        _hoveredTooltip = null;
      } else {
        _hoveredTooltip = text;
        
        // Calculate alignment based on global position relative to our viewport
        final RenderBox? box = context.findRenderObject() as RenderBox?;
        if (box != null) {
          final Offset localPos = box.globalToLocal(globalPos);
          _alignLeft = localPos.dx > (box.size.width * widget.flipThreshold);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _SqaInlineTooltipState(
      onHover: _handleHover,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // Content
          widget.child,

          // Inline Tooltip Overlay
          if (_hoveredTooltip != null)
            Positioned(
              left: _alignLeft ? 0 : null,
              right: !_alignLeft ? 0 : null,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_alignLeft)
                      Transform.translate(
                        offset: const Offset(1.0, 0),
                        child: _buildTail(colorScheme, isLeading: true),
                      ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      padding: EdgeInsets.only(
                        left: _alignLeft ? 16.0 : 8.0,
                        right: _alignLeft ? 8.0 : 16.0,
                      ),
                      color: (widget.backgroundColor ?? colorScheme.surfaceContainerLow),
                      child: Center(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: Text(
                          _hoveredTooltip!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_alignLeft)
                      Transform.translate(
                        offset: const Offset(-1.0, 0),
                        child: _buildTail(colorScheme, isLeading: false),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTail(ColorScheme colorScheme, {required bool isLeading}) {
    final baseColor = (widget.backgroundColor ?? colorScheme.surfaceContainerLow);
    return Container(
      width: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeading ? Alignment.centerRight : Alignment.centerLeft,
          end: isLeading ? Alignment.centerLeft : Alignment.centerRight,
          colors: [
            baseColor,
            baseColor.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

/// A wrapper to be used by individual items to trigger the inline tooltip.
class SqaInlineTooltipTrigger extends StatelessWidget {
  final Widget child;
  final String? tooltip;

  const SqaInlineTooltipTrigger({
    super.key,
    required this.child,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    if (tooltip == null || tooltip!.isEmpty) return child;

    return MouseRegion(
      onEnter: (event) {
        // Report specific global position of the event or the widget center
        final RenderBox box = context.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset(box.size.width / 2, 0));
        SqaInlineTooltip.show(context, tooltip, position);
      },
      onExit: (_) => SqaInlineTooltip.show(context, null),
      child: child,
    );
  }
}

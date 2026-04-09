import 'package:flutter/material.dart';

/// A wrapper that applies a top and bottom fade effect based on scroll position.
///
/// This widget is used to provide a premium feel where content subtly fades
/// as it reaches the boundaries of a scrollable area.
class SqaFadeWrapper extends StatefulWidget {
  final Widget child;
  final Color? color;
  final Axis axis;
  final double threshold;
  final EdgeInsets overlayPadding;
  final bool showStart;
  final bool showEnd;

  const SqaFadeWrapper({
    super.key,
    required this.child,
    this.color,
    this.axis = Axis.vertical,
    this.threshold = 30.0,
    this.overlayPadding = EdgeInsets.zero,
    this.showStart = true,
    this.showEnd = true,
  });

  @override
  State<SqaFadeWrapper> createState() => _SqaFadeWrapperState();
}

class _SqaFadeWrapperState extends State<SqaFadeWrapper>
    with SingleTickerProviderStateMixin {
  double _startIntensity = 0.0;
  double _endIntensity = 0.0;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _updateIntensity(ScrollMetrics metrics) {
    if (metrics.axis != widget.axis) return;

    final start = (metrics.pixels / widget.threshold).clamp(0.0, 1.0);
    final distToEnd = metrics.maxScrollExtent - metrics.pixels;
    final end = metrics.maxScrollExtent > 1.0
        ? (distToEnd / widget.threshold).clamp(0.0, 1.0)
        : 0.0;

    if (start != _startIntensity || end != _endIntensity) {
      setState(() {
        _startIntensity = start;
        _endIntensity = end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fadeColor = widget.color ?? colorScheme.surfaceContainerLow;
    final isVertical = widget.axis == Axis.vertical;

    return NotificationListener<Notification>(
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          _updateIntensity(notification.metrics);
        } else if (notification is ScrollMetricsNotification) {
          _updateIntensity(notification.metrics);
        }
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          // Start Fade (Top or Left)
          if (widget.showStart)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                // Using Curves for a natural "Pulse" feel
                final easedValue = Curves.easeInOut.transform(
                  _pulseController.value,
                );
                final breath = widget.threshold + (10.0 * easedValue);

                return Positioned(
                  left: widget.overlayPadding.left,
                  top: widget.overlayPadding.top,
                  right: isVertical ? widget.overlayPadding.right : null,
                  bottom: isVertical ? null : widget.overlayPadding.bottom,
                  width: isVertical ? null : breath,
                  height: isVertical ? breath : null,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: _startIntensity,
                      child: _GlowDecoration(
                        color: fadeColor,
                        axis: widget.axis,
                        isStart: true,
                        bloomIntensity: 0.0, // Neutral top fade
                      ),
                    ),
                  ),
                );
              },
            ),
          // End Fade (Bottom or Right)
          if (widget.showEnd)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                // Using Curves and Tweens for a premium feel
                final easedValue = Curves.easeInOut.transform(
                  _pulseController.value,
                );

                // Breath and Glow now pulse in sync but with different curves
                final breath = widget.threshold + (10.0 * easedValue);
                final bloom = 0.0; // Pulses from 0.10 to 0.25

                return Positioned(
                  right: widget.overlayPadding.right,
                  bottom: widget.overlayPadding.bottom,
                  left: isVertical ? widget.overlayPadding.left : null,
                  top: isVertical ? null : widget.overlayPadding.top,
                  width: isVertical ? null : breath,
                  height: isVertical ? breath : null,
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: _endIntensity,
                      child: _GlowDecoration(
                        color: fadeColor,
                        axis: widget.axis,
                        isStart: false,
                        bloomIntensity: bloom,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _GlowDecoration extends StatelessWidget {
  final Color color;
  final Axis axis;
  final bool isStart;
  final double bloomIntensity;

  const _GlowDecoration({
    required this.color,
    required this.axis,
    required this.isStart,
    required this.bloomIntensity,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isVertical = axis == Axis.vertical;

    // A slightly colored "Bloom" using the primary color
    final bloomColor = Color.lerp(color, colorScheme.primary, bloomIntensity)!;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isVertical
              ? (isStart ? Alignment.topCenter : Alignment.bottomCenter)
              : (isStart ? Alignment.centerLeft : Alignment.centerRight),
          end: isVertical
              ? (isStart ? Alignment.bottomCenter : Alignment.topCenter)
              : (isStart ? Alignment.centerRight : Alignment.centerLeft),
          colors: [
            bloomColor,
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.4),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}

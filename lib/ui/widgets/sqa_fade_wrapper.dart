import 'package:flutter/material.dart';

/// A wrapper that applies a sophisticated fade effect (top/bottom or left/right)
/// based on scroll position using high-performance ShaderMasking.
///
/// This widget provides a premium feel where content subtly fades
/// as it reaches the boundaries of a scrollable area.
class SqaFadeWrapper extends StatefulWidget {
  final Widget child;
  final Axis axis;
  final double threshold;
  final double depth;
  final double pulseDepth;
  final bool showStart;
  final bool showEnd;

  const SqaFadeWrapper({
    super.key,
    required this.child,
    this.axis = Axis.vertical,
    this.threshold = 30.0,
    this.depth = 0.04,
    this.pulseDepth = 0.01,
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

    final double start;
    final double end;

    // We use a small buffer (5px) like in SegmentedButton to avoid jitter.
    if (metrics.maxScrollExtent <= 5.0) {
      start = 0.0;
      end = 0.0;
    } else {
      // extentBefore and extentAfter naturally handle overscroll (becoming <= 0)
      start = (metrics.extentBefore / widget.threshold).clamp(0.0, 1.0);
      end = (metrics.extentAfter / widget.threshold).clamp(0.0, 1.0);
    }

    if (start != _startIntensity || end != _endIntensity) {
      // Defer state update to avoid 'dirty during layout' or 'mouse tracker' assertion errors.
      // This is especially critical for ScrollMetricsNotification which fires during build/layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _startIntensity = start;
            _endIntensity = end;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<Notification>(
      onNotification: (notification) {
        if (notification is ScrollNotification) {
          if (notification.depth == 0) {
            _updateIntensity(notification.metrics);
          }
        } else if (notification is ScrollMetricsNotification) {
          if (notification.depth == 0) {
            _updateIntensity(notification.metrics);
          }
        }
        return false;
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          // Pulse oscillation for the "breathing" effect
          final pulse = Curves.easeInOut.transform(_pulseController.value);

          return ShaderMask(
            shaderCallback: (Rect rect) {
              final isVertical = widget.axis == Axis.vertical;

              // We adjust the stops based on pulse to give it that "alive" look
              // Standard edge is subtle (default 4%), pulsing adds minimal depth.
              final startStop = widget.depth + (widget.pulseDepth * pulse);
              final endStop = (1.0 - widget.depth) - (widget.pulseDepth * pulse);

              return LinearGradient(
                begin: isVertical ? Alignment.topCenter : Alignment.centerLeft,
                end: isVertical
                    ? Alignment.bottomCenter
                    : Alignment.centerRight,
                colors: [
                  Colors.black.withValues(
                    alpha: 1.0 - (widget.showStart ? _startIntensity : 0),
                  ),
                  Colors.black,
                  Colors.black,
                  Colors.black.withValues(
                    alpha: 1.0 - (widget.showEnd ? _endIntensity : 0),
                  ),
                ],
                stops: [0.0, startStop, endStop, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: widget.child,
          );
        },
      ),
    );
  }
}

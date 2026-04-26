import 'package:flutter/material.dart';

/// A centralized widget to trigger a scroll-into-view only if the child is clipped.
///
/// This is the standard pattern for adaptive toolbars that expand dynamically.
/// It prevents "Auto-Snapping" by performing a geometric visibility check before scrolling.
class SqaScrollVisibilityTrigger extends StatefulWidget {
  final Widget child;

  const SqaScrollVisibilityTrigger({super.key, required this.child});

  @override
  State<SqaScrollVisibilityTrigger> createState() =>
      _SqaScrollVisibilityTriggerState();
}

class _SqaScrollVisibilityTriggerState
    extends State<SqaScrollVisibilityTrigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final scrollable = Scrollable.maybeOf(context);
      if (scrollable == null) return;

      final viewport = scrollable.context.findRenderObject() as RenderBox?;
      if (viewport == null) return;

      // Calculate relative position to detect clipping
      final localPos = renderBox.localToGlobal(Offset.zero, ancestor: viewport);
      final widgetRect = localPos & renderBox.size;
      final viewportRect = Offset.zero & viewport.size;

      // Only fire ensureVisible if the widget is actually clipped by the viewport boundaries
      final bool isClippedLeft = widgetRect.left < 0;
      final bool isClippedRight = widgetRect.right > viewportRect.width;

      if (isClippedLeft || isClippedRight) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          // Minimal move: align to the edge that was clipped
          alignment: isClippedLeft ? 0.0 : 1.0,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

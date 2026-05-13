import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';

class InteractiveTimeSegment extends StatefulWidget {
  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final bool isEnabled;

  const InteractiveTimeSegment({
    super.key,
    required this.value,
    required this.maxValue,
    required this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<InteractiveTimeSegment> createState() => _InteractiveTimeSegmentState();
}

class _InteractiveTimeSegmentState extends State<InteractiveTimeSegment> {
  bool _isHovered = false;

  void _handleScroll(PointerScrollEvent event) {
    if (!widget.isEnabled) return;
    if (event.scrollDelta.dy > 0) {
      // Scrolled down (decrease)
      _decrement();
    } else if (event.scrollDelta.dy < 0) {
      // Scrolled up (increase)
      _increment();
    }
  }

  void _increment() {
    int newValue = widget.value + 1;
    if (newValue > widget.maxValue) newValue = 0;
    widget.onChanged(newValue);
  }

  void _decrement() {
    int newValue = widget.value - 1;
    if (newValue < 0) newValue = widget.maxValue;
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displaySmall?.copyWith(
      fontFamily: 'monospace',
      color: widget.isEnabled
          ? theme.colorScheme.onSurface
          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
      fontWeight: FontWeight.w600,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            _handleScroll(event);
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Up Arrow
            AnimatedOpacity(
              opacity: _isHovered && widget.isEnabled ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SqaHoverIconButton(
                onPressed: widget.isEnabled ? _increment : () {},
                icon: Icons.keyboard_arrow_up,
                iconSize: 24,
                padding: 0,
                tooltip: 'Increment',
              ),
            ),

            // Value Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _isHovered && widget.isEnabled
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      )
                    : Colors.transparent,
              ),
              child: Text(
                widget.value.toString().padLeft(2, '0'),
                style: textStyle,
              ),
            ),

            // Down Arrow
            AnimatedOpacity(
              opacity: _isHovered && widget.isEnabled ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: SqaHoverIconButton(
                onPressed: widget.isEnabled ? _decrement : () {},
                icon: Icons.keyboard_arrow_down,
                iconSize: 24,
                padding: 0,
                tooltip: 'Decrement',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

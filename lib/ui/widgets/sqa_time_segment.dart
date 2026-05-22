import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'sqa_hover_icon_button.dart';
import 'sqa_design_tokens.dart';

class SqaTimeSegment extends StatefulWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final bool isEnabled;
  final TextStyle? style;

  const SqaTimeSegment({
    super.key,
    required this.value,
    required this.maxValue,
    this.minValue = 0,
    required this.onChanged,
    this.isEnabled = true,
    this.style,
  });

  @override
  State<SqaTimeSegment> createState() => _SqaTimeSegmentState();
}

class _SqaTimeSegmentState extends State<SqaTimeSegment> {
  bool _isHovered = false;

  void _handleScroll(PointerScrollEvent event) {
    if (!widget.isEnabled) return;
    if (event.scrollDelta.dy > 0) {
      _decrement();
    } else if (event.scrollDelta.dy < 0) {
      _increment();
    }
  }

  void _increment() {
    int newValue = widget.value + 1;
    if (newValue > widget.maxValue) newValue = widget.minValue;
    widget.onChanged(newValue);
  }

  void _decrement() {
    int newValue = widget.value - 1;
    if (newValue < widget.minValue) newValue = widget.maxValue;
    widget.onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle =
        widget.style ??
        theme.textTheme.displaySmall?.copyWith(
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
              duration: SqaTokens.durationFast,
              child: SqaHoverIconButton(
                onPressed: widget.isEnabled ? _increment : () {},
                icon: Icons.keyboard_arrow_up,
                iconSize: SqaTokens.spacingXXLarge,
                padding: 0,
                tooltip: 'Increment',
              ),
            ),

            // Value Display
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                borderRadius: SqaTokens.borderRadiusMedium,
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
              duration: SqaTokens.durationFast,
              child: SqaHoverIconButton(
                onPressed: widget.isEnabled ? _decrement : () {},
                icon: Icons.keyboard_arrow_down,
                iconSize: SqaTokens.spacingXXLarge,
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

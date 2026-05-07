import 'package:flutter/material.dart';

class InteractiveDateSegment extends StatefulWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final int digits;
  final String label;
  final ValueChanged<int> onChanged;
  final bool isEnabled;

  const InteractiveDateSegment({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    required this.label,
    this.digits = 2,
    this.isEnabled = true,
  });

  @override
  State<InteractiveDateSegment> createState() => _InteractiveDateSegmentState();
}

class _InteractiveDateSegmentState extends State<InteractiveDateSegment> {
  bool _isHovered = false;
  bool _isEditing = false;
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toString().padLeft(widget.digits, '0'),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _isEditing) {
        _commit();
      }
    });
  }

  @override
  void didUpdateWidget(InteractiveDateSegment oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isEditing) {
      _controller.text = widget.value.toString().padLeft(widget.digits, '0');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit() {
    final newValue = int.tryParse(_controller.text);
    if (newValue != null) {
      // Basic clamping
      final clamped = newValue.clamp(widget.minValue, widget.maxValue);
      widget.onChanged(clamped);
      _controller.text = clamped.toString().padLeft(widget.digits, '0');
    } else {
      _controller.text = widget.value.toString().padLeft(widget.digits, '0');
    }
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 8,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          GestureDetector(
            onTap: widget.isEnabled
                ? () {
                    setState(() => _isEditing = true);
                    _focusNode.requestFocus();
                    _controller.selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: _controller.text.length,
                    );
                  }
                : null,
            child: Container(
              width: widget.digits == 4 ? 54 : 36, // Fixed widths for alignment
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: _isEditing
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                    : (_isHovered && widget.isEnabled
                          ? theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5)
                          : Colors.transparent),
                border: Border.all(
                  color: _isEditing
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: _isEditing
                  ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: (_) => _commit(),
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      cursorWidth: 1,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                      ),
                    )
                  : Text(
                      widget.value.toString().padLeft(widget.digits, '0'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: widget.isEnabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

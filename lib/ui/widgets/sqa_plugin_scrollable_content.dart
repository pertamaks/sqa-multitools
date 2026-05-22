import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';
import 'sqa_fade_wrapper.dart';

/// A wrapper widget for plugin content that handles centering and scrolling.
///
/// If [center] is true (default), it centers content vertically when it's
/// smaller than the available height. This is useful for simple tools.
/// Set [center] to false if content should stay at the top (e.g. IDE-like editors).
class SqaPluginScrollableContent extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;
  final bool center;

  const SqaPluginScrollableContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(SqaTokens.spacingXLarge),
    this.controller,
    this.center = true,
  });

  @override
  State<SqaPluginScrollableContent> createState() =>
      _SqaPluginScrollableContentState();
}

class _SqaPluginScrollableContentState
    extends State<SqaPluginScrollableContent> {
  ScrollController? _internalController;

  ScrollController get _effectiveController =>
      widget.controller ?? (_internalController ??= ScrollController());

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content = widget.child;

        if (widget.center) {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - widget.padding.vertical)
                  .clamp(0.0, double.infinity),
            ),
            child: Center(child: widget.child),
          );
        }

        return Scrollbar(
          controller: _effectiveController,
          child: SqaFadeWrapper(
            axis: Axis.vertical,
            child: SingleChildScrollView(
              controller: _effectiveController,
              padding: widget.padding,
              child: content,
            ),
          ),
        );
      },
    );
  }
}

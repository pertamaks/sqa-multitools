import 'package:flutter/material.dart';

/// A wrapper widget for plugin content that handles centering and scrolling.
///
/// If [center] is true (default), it centers content vertically when it's
/// smaller than the available height. This is useful for simple tools.
/// Set [center] to false if content should stay at the top (e.g. IDE-like editors).
class SqaPluginScrollableContent extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;
  final bool center;

  const SqaPluginScrollableContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.controller,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Widget content = child;

        if (center) {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - padding.vertical).clamp(
                0.0,
                double.infinity,
              ),
            ),
            child: Center(child: child),
          );
        }

        return SingleChildScrollView(
          controller: controller,
          padding: padding,
          child: content,
        );
      },
    );
  }
}

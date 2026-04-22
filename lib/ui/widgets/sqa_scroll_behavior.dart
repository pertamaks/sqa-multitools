import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A custom scroll behavior that enables mouse dragging for specific widgets.
class SqaMouseDragScrollBehavior extends MaterialScrollBehavior {
  const SqaMouseDragScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) => const BouncingScrollPhysics();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

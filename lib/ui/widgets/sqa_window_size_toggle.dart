import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/providers/window_provider.dart';
import 'sqa_hover_icon_button.dart';

/// A button that toggles the window between default and square mode.
///
/// Uses the [windowSizeModeProvider] to manage global window state.
class SqaWindowSizeToggle extends ConsumerWidget {
  const SqaWindowSizeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(windowSizeModeProvider);

    final isSquare = mode == WindowSizeMode.squareMode;

    // Requested icons: arrows_more_down and arrows_more_up
    final iconData = isSquare
        ? Symbols.arrows_more_up
        : Symbols.arrows_more_down;

    return Transform.rotate(
      // -90 degrees (counter-clockwise) makes Down -> Right and Up -> Left
      angle: -math.pi / 2,
      child: SqaHoverIconButton(
        icon: iconData,
        onPressed: () => ref.read(windowSizeModeProvider.notifier).toggle(),
        tooltip: isSquare ? 'Exit Square Mode' : 'Enter Square Mode',
        iconSize: 18,
        weight: 700,
      ),
    );
  }
}

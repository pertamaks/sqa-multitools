import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/providers/window_provider.dart';
import 'sqa_styles.dart';

/// A button that toggles the window between default and square mode.
///
/// Uses the [windowSizeModeProvider] to manage global window state.
class SqaWindowSizeToggle extends ConsumerWidget {
  const SqaWindowSizeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(windowSizeModeProvider);
    final theme = Theme.of(context);

    final isSquare = mode == WindowSizeMode.squareMode;

    // Requested icons: arrows_more_down and arrows_more_up
    final iconData = isSquare
        ? Symbols.arrows_more_up
        : Symbols.arrows_more_down;

    return IconButton(
      icon: Transform.rotate(
        // -90 degrees (counter-clockwise) makes Down -> Right and Up -> Left
        angle: -math.pi / 2,
        child: Icon(
          iconData,
          size: 24,
          weight: 700, // Bold as requested
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
      ),
      onPressed: () => ref.read(windowSizeModeProvider.notifier).toggle(),
      tooltip: isSquare ? 'Exit Square Mode' : 'Enter Square Mode',
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(40, 40),
        // No background/border for a more 'floating' feel
        backgroundColor: Colors.transparent,
      ).copyWith(overlayColor: SqaStyles.buttonOverlay(context, silent: true)),
    );
  }
}

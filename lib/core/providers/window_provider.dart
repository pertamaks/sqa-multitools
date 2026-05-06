import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../window/window_constants.dart';
import '../../ui/widgets/sqa_styles.dart';

enum WindowSizeMode { defaultExpanded, squareMode }

class WindowSizeModeNotifier extends Notifier<WindowSizeMode> {
  @override
  WindowSizeMode build() => WindowSizeMode.defaultExpanded;

  Future<void> toggle() async {
    final nextMode = state == WindowSizeMode.defaultExpanded
        ? WindowSizeMode.squareMode
        : WindowSizeMode.defaultExpanded;

    state = nextMode;
    await _applySize();
  }

  Future<void> _applySize() async {
    if (state == WindowSizeMode.squareMode) {
      final size = Size(
        WindowConstants.kSquareModeSize,
        WindowConstants.kSquareModeSize,
      );
      await windowManager.setMinimumSize(size);
      await windowManager.setSize(size);
    } else {
      final size = Size(
        WindowConstants.kDefaultWindowWidth,
        WindowConstants.kExpandedWindowHeight,
      );
      await windowManager.setMinimumSize(size);
      await windowManager.setSize(size);
    }
  }

  /// Reset to default when closing a plugin if needed
  void reset() {
    state = WindowSizeMode.defaultExpanded;
  }
}

final windowSizeModeProvider =
    NotifierProvider<WindowSizeModeNotifier, WindowSizeMode>(() {
      return WindowSizeModeNotifier();
    });

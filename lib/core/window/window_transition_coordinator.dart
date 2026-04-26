import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Managed provider for the WindowTransitionCoordinator.
final windowTransitionProvider = Provider<WindowTransitionCoordinator>((ref) {
  final coordinator = WindowTransitionCoordinator();
  windowManager.addListener(coordinator);

  ref.onDispose(() {
    windowManager.removeListener(coordinator);
  });

  return coordinator;
});

/// A utility that replaces hardcoded delays with event-driven synchronization.
/// Includes polling fallback for robust cross-environment reliability.
class WindowTransitionCoordinator extends WindowListener {
  Completer<void>? _resizeCompleter;
  Completer<void>? _moveCompleter;

  /// Waits for the window and Flutter UI to reach a stable state.
  ///
  /// [resize]: Wait for OS window resize confirmation.
  /// [move]: Wait for OS window move confirmation.
  /// [targetSize]: Optional expected size to check via polling if the event is missed.
  /// [targetOffset]: Optional expected position to check via polling if the event is missed.
  Future<void> waitForSync({
    bool resize = true,
    bool move = false,
    bool frame = true,
    Size? targetSize,
    Offset? targetOffset,
    Duration timeout = const Duration(milliseconds: 1000),
  }) async {
    final List<Future<void>> futures = [];
    final List<StreamSubscription<void>> subtasks = [];

    // 1. Setup Resize Sync
    if (resize) {
      _resizeCompleter ??= Completer<void>();

      // Polling Fallback: Check every 50ms if the event is missed
      if (targetSize != null) {
        final pollTimer =
            Stream<void>.periodic(const Duration(milliseconds: 50)).listen((
              _,
            ) async {
              final currentSize = await windowManager.getSize();
              if ((currentSize.width - targetSize.width).abs() < 1.0 &&
                  (currentSize.height - targetSize.height).abs() < 1.0) {
                if (_resizeCompleter != null &&
                    !_resizeCompleter!.isCompleted) {
                  _resizeCompleter!.complete();
                }
              }
            });
        subtasks.add(pollTimer);
      }

      futures.add(
        _resizeCompleter!.future.timeout(
          timeout,
          onTimeout: () {
            _resizeCompleter = null;
          },
        ),
      );
    }

    // 2. Setup Move Sync
    if (move) {
      _moveCompleter ??= Completer<void>();

      if (targetOffset != null) {
        final pollTimer =
            Stream<void>.periodic(const Duration(milliseconds: 50)).listen((
              _,
            ) async {
              final currentPos = await windowManager.getPosition();
              if ((currentPos.dx - targetOffset.dx).abs() < 1.0 &&
                  (currentPos.dy - targetOffset.dy).abs() < 1.0) {
                if (_moveCompleter != null && !_moveCompleter!.isCompleted) {
                  _moveCompleter!.complete();
                }
              }
            });
        subtasks.add(pollTimer);
      }

      futures.add(
        _moveCompleter!.future.timeout(
          timeout,
          onTimeout: () {
            _moveCompleter = null;
          },
        ),
      );
    }

    // 3. Setup Frame render sync
    if (frame) {
      final frameCompleter = Completer<void>();
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!frameCompleter.isCompleted) frameCompleter.complete();
      });
      futures.add(frameCompleter.future.timeout(timeout));
    }

    // Execute and cleanup
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }

    for (var sub in subtasks) {
      sub.cancel();
    }

    // Final settle frame
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }

  @override
  void onWindowResized() {
    if (_resizeCompleter != null && !_resizeCompleter!.isCompleted) {
      _resizeCompleter!.complete();
      _resizeCompleter = null;
    }
  }

  @override
  void onWindowMoved() {
    if (_moveCompleter != null && !_moveCompleter!.isCompleted) {
      _moveCompleter!.complete();
      _moveCompleter = null;
    }
  }
}

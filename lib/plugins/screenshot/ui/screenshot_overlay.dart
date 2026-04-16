import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/screenshot_tool.dart';
import '../../../core/models/annotation.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/window/window_utils.dart';
import '../providers/screenshot_provider.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_selection_painter.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:window_manager/window_manager.dart';
import 'package:screen_retriever/screen_retriever.dart';

class ScreenshotOverlay extends ConsumerStatefulWidget {
  const ScreenshotOverlay({super.key});

  @override
  ConsumerState<ScreenshotOverlay> createState() => _ScreenshotOverlayState();
}

class _ScreenshotOverlayState extends ConsumerState<ScreenshotOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Offset? _startPos;
  Offset? _currentPos;
  final ValueNotifier<Offset?> _barOffsetNotifier = ValueNotifier<Offset?>(
    null,
  );
  Timer? _mousePollingTimer;
  bool _isDragging = false;
  Offset _dragGrabOffset = Offset.zero;

  // Track last mouse buttons
  bool _leftMouseDownLast = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _startMousePolling();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _mousePollingTimer?.cancel();
    _barOffsetNotifier.dispose();
    super.dispose();
  }

  void _startMousePolling() {
    _mousePollingTimer?.cancel();
    _mousePollingTimer = Timer.periodic(const Duration(milliseconds: 30), (
      _,
    ) async {
      if (!mounted) return;
      final state = ref.read(screenshotProvider);
      if (!state.isOverlayVisible || _isDragging) return;

      final win32 = Platform.isWindows;
      if (!win32) return;

      // Using the now centralized WindowUtils
      // (targeting logic follows)

      // We only use win32 polls for button states to trigger confirmation
      // However, we can use screen_retriever's mouse state if preferred.
      // For simplicity, let's stick to the same pattern as recorder.
      final leftDown = WindowUtils.isLeftMouseDown();

      if (state.isTargetingWindow ||
          (state.captureMode == CaptureMode.fullScreen &&
              state.selectionRect == null)) {
        if (leftDown &&
            !_leftMouseDownLast &&
            state.targetedWindowRect != null) {
          final targetRect = state.targetedWindowRect!;
          _teleportBarToRect(targetRect);
          ref
              .read(screenshotProvider.notifier)
              .confirmTargetWindow(
                targetRect,
                state.targetWindowName ?? 'Active Window',
              );
        }

        // Window/Monitor targeting discovery
        if (state.isTargetingWindow) {
          final winInfo = WindowUtils.getWindowInfoAt();
          if (winInfo != null) {
            final windowPos = await windowManager.getPosition();
            final localRect = Rect.fromLTWH(
              winInfo.rect.left - windowPos.dx,
              winInfo.rect.top - windowPos.dy,
              winInfo.rect.width,
              winInfo.rect.height,
            );
            if (state.targetedWindowRect != localRect) {
              ref
                  .read(screenshotProvider.notifier)
                  .updateTargetedWindow(localRect, winInfo.title, winInfo.hwnd);
            }
          } else if (state.targetedWindowRect != null) {
            ref
                .read(screenshotProvider.notifier)
                .updateTargetedWindow(null, null);
          }
        } else if (state.captureMode == CaptureMode.fullScreen &&
            state.selectionRect == null) {
          // Monitor Targeting Discovery
          final cursor = await screenRetriever.getCursorScreenPoint();
          final displays = state.availableDisplays;

          Display? targetDisplay;
          for (final d in displays) {
            final rect = Rect.fromLTWH(
              d.visiblePosition?.dx ?? 0,
              d.visiblePosition?.dy ?? 0,
              d.size.width,
              d.size.height,
            );
            if (rect.contains(cursor)) {
              targetDisplay = d;
              break;
            }
          }

          if (targetDisplay != null) {
            final windowPos = await windowManager.getPosition();
            final localRect = Rect.fromLTWH(
              (targetDisplay.visiblePosition?.dx ?? 0) - windowPos.dx,
              (targetDisplay.visiblePosition?.dy ?? 0) - windowPos.dy,
              targetDisplay.size.width,
              targetDisplay.size.height,
            );

            if (state.targetedWindowRect != localRect) {
              ref.read(screenshotProvider.notifier).updateTargetedWindow(
                    localRect,
                    'Display ${displays.indexOf(targetDisplay) + 1}',
                  );
            }
          } else if (state.targetedWindowRect != null) {
            ref
                .read(screenshotProvider.notifier)
                .updateTargetedWindow(null, null);
          }
        } else {
          // Area mode or already selected: clear discovery rect
          if (state.targetedWindowRect != null) {
            ref
                .read(screenshotProvider.notifier)
                .updateTargetedWindow(null, null);
          }
        }
      }

      _leftMouseDownLast = leftDown;
    });
  }

  Offset _clampOffset(Offset offset, Size screenSize) {
    const double barWidth = 650.0;
    const double barHeight = 60.0;
    const double padding = 12.0;

    return Offset(
      offset.dx.clamp(
        padding,
        math.max(padding, screenSize.width - barWidth - padding),
      ),
      offset.dy.clamp(
        padding,
        math.max(padding, screenSize.height - barHeight - padding),
      ),
    );
  }

  void _teleportBarToRect(Rect targetRect) {
    if (!mounted) return;
    // ... Logic matches Screen Recorder for consistency ...
    final size = MediaQuery.of(context).size;
    final targetOffset = Offset(
      targetRect.center.dx - 325, // center horizontally
      targetRect.bottom + 20,
    );
    _barOffsetNotifier.value = _clampOffset(targetOffset, size);
  }

  void _onPanStart(DragStartDetails details) {
    final state = ref.read(screenshotProvider);
    if (state.selectionRect == null) {
      setState(() {
        _startPos = details.localPosition;
        _currentPos = details.localPosition;
      });
    } else {
      // Start drawing annotation
      final annotation = Annotation(
        points: [details.localPosition],
        tool: state.currentTool,
        color: state.annotationColor,
      );
      ref.read(screenshotProvider.notifier).addAnnotation(annotation);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final state = ref.read(screenshotProvider);
    if (state.selectionRect == null) {
      setState(() {
        _currentPos = details.localPosition;
      });
    } else {
      // Update annotation points
      final last = state.annotations.last;
      final updated = last.copyWith(
        points: [...last.points, details.localPosition],
      );
      ref.read(screenshotProvider.notifier).updateLastAnnotation(updated);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final state = ref.read(screenshotProvider);
    if (state.selectionRect == null &&
        _startPos != null &&
        _currentPos != null) {
      final rect = Rect.fromPoints(_startPos!, _currentPos!);
      if (rect.width > 5 && rect.height > 5) {
        _teleportBarToRect(rect);
        ref.read(screenshotProvider.notifier).setSelection(rect);
      }
      setState(() {
        _startPos = null;
        _currentPos = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenshotProvider);
    final notifier = ref.read(screenshotProvider.notifier);
    if (!state.isOverlayVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dim background with cutout
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: SqaSelectionPainter(
                  selectionRect:
                      state.selectionRect ??
                      (_startPos != null && _currentPos != null
                          ? Rect.fromPoints(_startPos!, _currentPos!)
                          : null),
                  targetedWindowRect: state.targetedWindowRect,
                  annotations: state.annotations,
                  animationValue: _animationController.value,
                  repaint: _animationController,
                ),
              ),
            ),
          ),

          ValueListenableBuilder<Offset?>(
            valueListenable: _barOffsetNotifier,
            builder: (BuildContext context, Offset? barOffset, Widget? child) {
              final barPosition = barOffset ?? Offset.zero;
              if (state.selectionRect == null) return const SizedBox.shrink();

              return Positioned(
                left: barPosition.dx,
                top: barPosition.dy,
                child: SqaFloatingBar(
                  children: [
                    SqaFloatingBarDragHandle(
                      onDragStart: (details) {
                        _isDragging = true;
                        _dragGrabOffset = details.localPosition;
                      },
                      onDragUpdate: (details) {
                        final size = MediaQuery.of(context).size;
                        _barOffsetNotifier.value = _clampOffset(
                          details.globalPosition - _dragGrabOffset,
                          size,
                        );
                      },
                      onDragEnd: () {
                        _isDragging = false;
                      },
                    ),
                    ...[
                      (ScreenshotTool.pen, Symbols.edit, 'Pen'),
                      (ScreenshotTool.line, Symbols.horizontal_rule, 'Line'),
                      (ScreenshotTool.arrow, Symbols.arrow_outward, 'Arrow'),
                      (ScreenshotTool.marker, Symbols.brush, 'Highlighter'),
                      (
                        ScreenshotTool.rectangle,
                        Symbols.rectangle,
                        'Rectangle',
                      ),
                      (ScreenshotTool.text, Symbols.text_fields, 'Text'),
                    ].map(
                      (t) => SqaFloatingBarButton(
                        icon: t.$2,
                        tooltip: t.$3,
                        isSelected: state.currentTool == t.$1,
                        onPressed: () => notifier.setTool(t.$1),
                      ),
                    ),
                    SqaFloatingBarButton(
                      icon: Symbols.delete_sweep,
                      tooltip: 'Clear All',
                      onPressed: notifier.clearAnnotations,
                    ),

                    const SqaFloatingBarDivider(),

                    // Colors (Selected 4)
                    ...[
                      Colors.red,
                      Colors.green,
                      Colors.blue,
                      Colors.white,
                    ].map(
                      (c) => SqaFloatingBarColorPicker(
                        color: c,
                        isSelected: state.annotationColor == c,
                        onTap: () => notifier.setColor(c),
                      ),
                    ),

                    const SqaFloatingBarDivider(),

                    // Final Actions
                    SqaFloatingBarButton(
                      icon: Symbols.content_copy,
                      tooltip: 'Copy to Clipboard',
                      isLoading: state.isCapturing,
                      onPressed: () => notifier.finalize(shouldCopy: true),
                    ),
                    SqaFloatingBarButton(
                      icon: Symbols.save,
                      tooltip: 'Save Screenshot',
                      isLoading: state.isCapturing,
                      onPressed: () => notifier.finalize(),
                    ),
                    SqaFloatingBarButton(
                      icon: Symbols.close,
                      tooltip: 'Cancel',
                      onPressed: state.isCapturing ? null : notifier.stopCapture,
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            },
          ),

          // Capture Processing Overlay (Dim only, no spinner)
          if (state.isCapturing)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),

          // Instructions
          if (state.selectionRect == null && !state.isCapturing)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(
                    switch(state.captureMode) {
                      CaptureMode.fullScreen => Symbols.fullscreen,
                      CaptureMode.area => Symbols.crop_free,
                      CaptureMode.window => Symbols.window,
                    },
                    size: 64,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    switch(state.captureMode) {
                      CaptureMode.fullScreen => 'Click anywhere to capture full screen',
                      CaptureMode.area => 'Drag to select capture area',
                      CaptureMode.window => 'Click a window to capture',
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Esc to cancel',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

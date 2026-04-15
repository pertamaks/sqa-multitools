import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'dart:async';
import 'dart:io';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/screen_recorder_provider.dart';
import '../models/screen_recorder_state.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/screenshot_tool.dart';
import '../../../core/models/annotation.dart';
import '../../../core/models/click_ripple.dart';
import '../../../core/window/window_utils.dart';
import '../../../ui/widgets/sqa_selection_painter.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_dropdown.dart';


class ScreenRecorderOverlay extends ConsumerStatefulWidget {
  const ScreenRecorderOverlay({super.key});

  @override
  ConsumerState<ScreenRecorderOverlay> createState() =>
      _ScreenRecorderOverlayState();
}

class _ScreenRecorderOverlayState extends ConsumerState<ScreenRecorderOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Offset? _startPos;
  Offset? _currentPos;
  final ValueNotifier<Offset?> _barOffsetNotifier = ValueNotifier<Offset?>(null);
  Timer? _mousePollingTimer;
  bool _isIgnoring = false;
  bool _isDragging = false;
  Offset _dragGrabOffset = Offset.zero;
  
  // Click Feedback State
  final List<ClickRipple> _ripples = [];
  bool _leftMouseDownLast = false;
  bool _rightMouseDownLast = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _startMousePolling();
  }

  @override
  void dispose() {
    _mousePollingTimer?.cancel();
    _animationController.dispose();
    _barOffsetNotifier.dispose();
    super.dispose();
  }

  void _startMousePolling() {
    _mousePollingTimer =
        Timer.periodic(const Duration(milliseconds: 20), (_) async {
      final state = ref.read(screenRecorderProvider);
      
      // OPTIMIZATION: If we are dragging the toolbar, skip polling to prioritize 
      // movement performance and prevent state competition.
      if (_isDragging) return;
      // 1. Global Click Detection (Win32 - Windows only)
      if (Platform.isWindows) {
        final leftDown = WindowUtils.isLeftMouseDown();
        final rightDown = WindowUtils.isRightMouseDown();

        if ((leftDown && !_leftMouseDownLast) || (rightDown && !_rightMouseDownLast)) {
          final cursor = await screenRetriever.getCursorScreenPoint();
          final windowPos = await windowManager.getPosition();
          
          // Convert screen coordinates to window-local coordinates
          final localPos = Offset(
            cursor.dx - windowPos.dx,
            cursor.dy - windowPos.dy,
          );

          // Handle Target Confirmation Click
          if ((state.isTargetingWindow || (state.captureMode == CaptureMode.fullScreen && state.selectionRect == null)) && 
              leftDown && !_leftMouseDownLast && state.targetedWindowRect != null) {
            final targetRect = state.targetedWindowRect!;
            _teleportBarToRect(targetRect);
            ref.read(screenRecorderProvider.notifier).confirmTargetWindow(
              targetRect,
              state.targetWindowName,
            );
          }

          setState(() {
            _ripples.add(ClickRipple(
              position: localPos, 
              timestamp: DateTime.now(),
              isRightClick: !leftDown && rightDown,
            ));
          });

          // Auto-cleanup after 600ms
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _ripples.removeWhere((r) => 
                  DateTime.now().difference(r.timestamp).inMilliseconds > 500
                );
              });
            }
          });
        }
        
        _leftMouseDownLast = leftDown;
        _rightMouseDownLast = rightDown;

        // 2. Window/Monitor Targeting Discovery
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
              ref.read(screenRecorderProvider.notifier).updateTargetedWindow(
                  localRect, winInfo.title, winInfo.hwnd);
            }
          } else if (state.targetedWindowRect != null) {
            ref.read(screenRecorderProvider.notifier).updateTargetedWindow(
                null, null);
          }
        } else if (state.captureMode == CaptureMode.fullScreen &&
            state.selectionRect == null) {
          // Monitor Targeting (for Full Screen Mode)
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
              ref.read(screenRecorderProvider.notifier).updateTargetedWindow(
                    localRect,
                    'Display ${displays.indexOf(targetDisplay) + 1}',
                  );
            }
          } else if (state.targetedWindowRect != null) {
            ref.read(screenRecorderProvider.notifier).updateTargetedWindow(
                null, null);
          }
        } else {
          // Default: Clear any hover highlights (crucial for Area Mode logic)
          if (state.targetedWindowRect != null) {
            ref.read(screenRecorderProvider.notifier).updateTargetedWindow(
                null, null);
          }
        }
      }

      // 3. Ignore Mouse Events Logic (100ms interval for performance)
      // We only run the hit-test logic every 5th poll (approx 100ms)
      if (DateTime.now().millisecond % 100 < 20) {
        _handleIgnoreLogic(state);
      }
    });
  }

  Future<void> _handleIgnoreLogic(ScreenRecorderState state) async {
    // Safety Guard: If we are not recording or the overlay is closing, 
    // ALWAYS ensure we are NOT ignoring mouse events and exit.
    if (!state.isRecording || !state.isOverlayVisible || !mounted || state.isTargetingWindow) {
      if (_isIgnoring) {
        _isIgnoring = false;
        await ref.read(screenRecorderProvider.notifier).setIgnoreMouseEvents(false);
      }
      return;
    }

    // If we are dragging or drawing, we MUST NOT ignore mouse events.
    if (_isDragging || _barOffsetNotifier.value == null) {
      if (_isIgnoring) {
        _isIgnoring = false;
        await ref
            .read(screenRecorderProvider.notifier)
            .setIgnoreMouseEvents(false);
      }
      return;
    }

    // Logic:
    // If tool is NOT Pointer -> Disable ignore (always interactable for drawing)
    // If tool IS Pointer -> Use polling (interactable only over bar)
    final isPointerMode = state.currentTool == ScreenshotTool.pointer;

    if (!isPointerMode) {
      if (_isIgnoring) {
        _isIgnoring = false;
        await ref
            .read(screenRecorderProvider.notifier)
            .setIgnoreMouseEvents(false);
      }
      return;
    }

    final cursor = await screenRetriever.getCursorScreenPoint();
    final windowPos = await windowManager.getPosition();

    // Screen Recorder Bar Rect (Safe Bounds)
    const double width = 620.0;
    const double height = 60.0;
    final currentOffset = _barOffsetNotifier.value ?? Offset.zero;
    final barRect = Rect.fromLTWH(
      windowPos.dx + currentOffset.dx,
      windowPos.dy + currentOffset.dy,
      width,
      height,
    );

    // Add a small margin for easier interaction
    // Note: windowPos in a spanned overlay on Windows often reflects the virtual origin (e.g. minX, minY).
    final hoverRect = barRect.inflate(10);
    final isHovering = hoverRect.contains(cursor);

    if (isHovering && _isIgnoring) {
      _isIgnoring = false;
      await ref
          .read(screenRecorderProvider.notifier)
          .setIgnoreMouseEvents(false);
    } else if (!isHovering && !_isIgnoring && state.isRecording) {
      _isIgnoring = true;
      await ref
          .read(screenRecorderProvider.notifier)
          .setIgnoreMouseEvents(true);
    }
  }

  Offset _clampOffset(Offset offset, Size screenSize) {
    // Estimated bar dimensions. We use safe padding to prevent truncation.
    const double barWidth = 620.0;
    const double barHeight = 60.0;
    const double padding = 12.0;

    return Offset(
      offset.dx.clamp(padding, math.max(padding, screenSize.width - barWidth - padding)),
      offset.dy.clamp(padding, math.max(padding, screenSize.height - barHeight - padding)),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_barOffsetNotifier.value == null) {
      final size = MediaQuery.of(context).size;
      final state = ref.read(screenRecorderProvider);
      
      // If captureRect is set (single monitor selected), center toolbar on it.
      // Otherwise (virtual desktop spanning all monitors), center on the primary 
      // monitor's local coordinates within the overlay.
      double centerX;
      double bottomY;
      
      if (state.captureRect != null) {
        // captureRect is in global logical coords; convert to local overlay coords
        // by subtracting the overlay window's origin (which may be negative on multi-mon).
        // For single-monitor overlay, captureRect == overlayRect, so local is (0, 0, w, h).
        centerX = state.captureRect!.width / 2;
        bottomY = state.captureRect!.height - 150;
      } else {
        // Virtual desktop mode — find the primary display (position 0,0) and 
        // compute its local offset within the overlay.
        // The overlay window starts at (minX, minY) of the virtual desktop.
        // Primary monitor is at logical (0, 0), so its local offset is (-minX, -minY).
        // For a typical right-extended setup: minX=0, so primary local is (0, 0, 1920, 1080).
        final primaryDisplay = state.availableDisplays.cast<Display?>().firstWhere(
          (d) => d?.visiblePosition?.dx == 0 && d?.visiblePosition?.dy == 0,
          orElse: () => state.availableDisplays.isNotEmpty ? state.availableDisplays.first : null,
        );
        if (primaryDisplay != null) {
          // Compute where the primary monitor starts in local overlay coordinates
          // If overlay starts at minX (e.g. -1920 for left-extended), primary local X = 0 - minX = 1920
          // If overlay starts at 0 (e.g. right-extended), primary local X = 0
          double minX = 0;
          double minY = 0;
          for (final d in state.availableDisplays) {
            final pos = d.visiblePosition ?? Offset.zero;
            if (pos.dx < minX) minX = pos.dx;
            if (pos.dy < minY) minY = pos.dy;
          }
          final localPrimaryX = (primaryDisplay.visiblePosition?.dx ?? 0) - minX;
          final localPrimaryY = (primaryDisplay.visiblePosition?.dy ?? 0) - minY;
          centerX = localPrimaryX + primaryDisplay.size.width / 2;
          bottomY = localPrimaryY + primaryDisplay.size.height - 150;
        } else {
          centerX = size.width / 2;
          bottomY = size.height - 150;
        }
      }
      
      _barOffsetNotifier.value = _clampOffset(
        Offset(centerX - 310, bottomY),
        size,
      );
    }
  }

  String _formatDuration(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h == '00' ? '$m:$s' : '$h:$m:$s';
  }

  void _onPanStart(DragStartDetails details) {
    final state = ref.read(screenRecorderProvider);
    if (!state.isRecording &&
        state.isTargetingWindow &&
        state.captureMode == CaptureMode.window) {
      // Confirm selection via click handled in polling loop,
      // but we still stop gesture propagation here.
      return;
    }

    if (!state.isRecording &&
        state.captureMode == CaptureMode.area &&
        state.selectionRect == null) {
      // Selecting area
      setState(() {
        _startPos = details.localPosition;
        _currentPos = details.localPosition;
      });
    } else if (state.isRecording) {
      // Drawing annotation
      final annotation = Annotation(
        points: [details.localPosition],
        tool: state.currentTool,
        color: state.annotationColor,
      );
      ref.read(screenRecorderProvider.notifier).addAnnotation(annotation);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final state = ref.read(screenRecorderProvider);
    if (!state.isRecording &&
        state.captureMode == CaptureMode.area &&
        state.selectionRect == null) {
      setState(() {
        _currentPos = details.localPosition;
      });
    } else if (state.isRecording) {
      final last = state.annotations.last;
      final updated = last.copyWith(
        points: [...last.points, details.localPosition],
      );
      ref.read(screenRecorderProvider.notifier).updateLastAnnotation(updated);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    final state = ref.read(screenRecorderProvider);
    if (!state.isRecording &&
        state.captureMode == CaptureMode.area &&
        state.selectionRect == null &&
        _startPos != null &&
        _currentPos != null) {
      final rect = Rect.fromPoints(_startPos!, _currentPos!);
      if (rect.width > 5 && rect.height > 5) {
        _teleportBarToRect(rect);
        ref.read(screenRecorderProvider.notifier).setSelection(rect);
      }
      setState(() {
        _startPos = null;
        _currentPos = null;
      });
    }
  }

  void _teleportBarToRect(Rect targetRect) {
    if (!mounted) return;

    final state = ref.read(screenRecorderProvider);
    final displays = state.availableDisplays;
    if (displays.isEmpty) return;

    double minX = 0;
    double minY = 0;
    for (final d in displays) {
      final pos = d.visiblePosition ?? Offset.zero;
      minX = math.min(minX, pos.dx);
      minY = math.min(minY, pos.dy);
    }

    final center = targetRect.center;
    Display? activeDisplay;

    for (final d in displays) {
      final dPos = d.visiblePosition ?? Offset.zero;
      final localMonitorRect = Rect.fromLTWH(
        dPos.dx - minX,
        dPos.dy - minY,
        d.size.width,
        d.size.height,
      );
      if (localMonitorRect.contains(center)) {
        activeDisplay = d;
        break;
      }
    }

    if (activeDisplay != null) {
      final dPos = activeDisplay.visiblePosition ?? Offset.zero;
      final localTargetMonitorX = dPos.dx - minX;
      final localTargetMonitorY = dPos.dy - minY;

      const double barWidth = 620.0;
      const double barHeight = 60.0;
      const double paddingBottom = 60.0;

      final targetOffset = Offset(
        localTargetMonitorX + (activeDisplay.size.width / 2) - (barWidth / 2),
        localTargetMonitorY + activeDisplay.size.height - barHeight - paddingBottom,
      );

      _barOffsetNotifier.value =
          _clampOffset(targetOffset, MediaQuery.of(context).size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    if (!state.isOverlayVisible) return const SizedBox.shrink();
    // Live selection rect for visual feedback during dragging
    final selectionRect = state.selectionRect ?? 
        (_startPos != null && _currentPos != null ? Rect.fromPoints(_startPos!, _currentPos!) : null);

    final showInstruction =
        !state.isRecording &&
        state.captureMode == CaptureMode.area &&
        state.selectionRect == null;

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
                  selectionRect: selectionRect,
                  targetedWindowRect: state.targetedWindowRect,
                  annotations: state.annotations,
                  isRecording: state.isRecording,
                  animationValue: _animationController.value,
                  ripples: _ripples,
                  repaint: _animationController,
                ),
              ),
            ),
          ),

          // Centralized Floating Toolbar
          ValueListenableBuilder<Offset?>(
            valueListenable: _barOffsetNotifier,
            builder: (context, barPosition, _) {
              if (barPosition == null) return const SizedBox.shrink();
              
              final showBar = state.isRecording ||
                  (!state.isTargetingWindow &&
                      (state.captureMode == CaptureMode.fullScreen ||
                          state.selectionRect != null));

              if (!showBar) return const SizedBox.shrink();

              return Positioned(
                left: barPosition.dx,
                top: barPosition.dy,
                child: RepaintBoundary(
                  child: MouseRegion(
                    child: SqaFloatingBar(
                      children: [
                        SqaFloatingBarDragHandle(
                          onDragStart: (details) {
                            setState(() {
                              _isDragging = true;
                              _dragGrabOffset = details.localPosition;
                            });
                          },
                          onDragUpdate: (details) {
                            // Absolute Pinning: Position = GlobalMouse - GrabOffset
                            _barOffsetNotifier.value = _clampOffset(
                                details.globalPosition - _dragGrabOffset, 
                                MediaQuery.of(context).size,
                            );
                          },
                          onDragEnd: () {
                            setState(() => _isDragging = false);
                          },
                        ),
                    // Timer & Status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isRecording && !state.isPaused)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (state.countdownSeconds > 0)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          Text(
                            state.countdownSeconds > 0
                                ? '${state.countdownSeconds}'
                                : _formatDuration(state.durationSeconds),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: state.countdownSeconds > 0
                                  ? Colors.orange
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SqaFloatingBarDivider(),

                    // Controls
                    SqaFloatingBarButton(
                      icon: state.isRecording
                          ? Symbols.stop_circle
                          : Symbols.play_arrow,
                      tooltip: state.isRecording ? 'Stop & Save' : 'Start',
                      onPressed: () => notifier.toggleRecording(),
                      isPrimary: !state.isRecording,
                      color: state.isRecording ? Colors.red : null,
                    ),

                    if (!state.isRecording)
                      SqaFloatingBarButton(
                        icon: Symbols.close,
                        tooltip: state.countdownSeconds > 0
                            ? 'Cancel Countdown'
                            : 'Cancel Overlay',
                        onPressed: () {
                          if (state.countdownSeconds > 0) {
                            notifier.cancelCountdown();
                          } else {
                            notifier.cancelOverlay();
                          }
                        },
                        color: Colors.red,
                      ),

                    // Delay selector (only before recording)
                    if (!state.isRecording) ...[
                      const SqaFloatingBarDivider(),
                      SqaDropdown<int>(
                        value: state.delaySeconds,
                        onChanged: (val) {
                          if (val != null) notifier.setDelay(val);
                        },
                        items: [0, 2, 5, 10]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('${e}s'),
                                ))
                            .toList(),
                      ),
                    ],

                    const SqaFloatingBarDivider(),

                    // Annotation Tools
                    ...[
                      (ScreenshotTool.pointer, Symbols.near_me, 'Pointer'),
                      (ScreenshotTool.pen, Symbols.edit, 'Pen'),
                      (ScreenshotTool.marker, Symbols.brush, 'Highlighter'),
                      (ScreenshotTool.arrow, Symbols.arrow_outward, 'Arrow'),
                      (ScreenshotTool.rectangle, Symbols.rectangle, 'Rectangle'),
                    ].map(
                      (t) => SqaFloatingBarButton(
                        icon: t.$2,
                        tooltip: t.$3,
                        isSelected: state.currentTool == t.$1,
                        onPressed: () => notifier.setTool(t.$1),
                      ),
                    ),

                    const SqaFloatingBarDivider(),

                    // Colors
                    ...[Colors.red, Colors.green, Colors.blue, Colors.white].map(
                      (c) => SqaFloatingBarColorPicker(
                        color: c,
                        isSelected: state.annotationColor == c,
                        onTap: () => notifier.setColor(c),
                      ),
                    ),

                    const SqaFloatingBarDivider(),

                    // Clear button
                    SqaFloatingBarButton(
                      icon: Symbols.delete_sweep,
                      tooltip: 'Clear Annotations',
                      onPressed: () => notifier.clearAnnotations(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

          // Mirrored Instructions (Visible on all displays)
          if (showInstruction || (state.isTargetingWindow && state.isOverlayVisible))
            ...() {
              double minX = 0;
              double minY = 0;
              for (final d in state.availableDisplays) {
                final pos = d.visiblePosition ?? Offset.zero;
                minX = math.min(minX, pos.dx);
                minY = math.min(minY, pos.dy);
              }

              return state.availableDisplays.map((display) {
                final displayPos = display.visiblePosition ?? Offset.zero;
                final localX = displayPos.dx - minX;
                final localY = displayPos.dy - minY;
                
                return Positioned(
                  left: localX,
                  top: localY,
                  width: display.size.width,
                  height: display.size.height,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        state.isTargetingWindow
                            ? 'Click a window to select it'
                            : 'Drag to select recording area',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              });
            }(),
        ],
      ),
    );
  }
}


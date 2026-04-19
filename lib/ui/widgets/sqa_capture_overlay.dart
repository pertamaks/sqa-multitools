import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../../core/models/capture_overlay_delegate.dart';
import '../../core/models/capture_mode.dart';
import '../../core/models/annotation.dart';
import '../../core/models/screenshot_tool.dart';
import '../../core/models/click_ripple.dart';
import '../../core/window/window_utils.dart';
import 'sqa_selection_painter.dart';
import 'sqa_floating_bar.dart';

/// Internal controller for high-performance drawing.
/// Bypasses the widget rebuild cycle for real-time annotation feedback.
class _DrawingController extends ChangeNotifier {
  List<Offset> _points = [];
  List<DateTime> _timestamps = [];

  List<Offset> get points => _points;
  List<DateTime> get timestamps => _timestamps;

  void start() {
    _points = [];
    _timestamps = [];
    notifyListeners();
  }

  void add(Offset point) {
    _points.add(point);
    _timestamps.add(DateTime.now());
    notifyListeners();
  }

  void prune(DateTime limit) {
    while (_timestamps.isNotEmpty && _timestamps.first.isBefore(limit)) {
      _points.removeAt(0);
      _timestamps.removeAt(0);
    }
    if (_points.isNotEmpty || _timestamps.isEmpty) {
      notifyListeners();
    }
  }

  void clear() {
    _points = [];
    _timestamps = [];
    notifyListeners();
  }
}

class SqaCaptureOverlay extends ConsumerStatefulWidget {
  final CaptureOverlayDelegate delegate;
  final List<Widget> Function(BuildContext context) toolbarBuilder;
  final Widget Function(BuildContext context, CaptureMode mode)? instructionBuilder;
  final ValueChanged<Offset?>? onBarOffsetChanged;

  const SqaCaptureOverlay({
    super.key,
    required this.delegate,
    required this.toolbarBuilder,
    this.instructionBuilder,
    this.onBarOffsetChanged,
  });

  @override
  ConsumerState<SqaCaptureOverlay> createState() => _SqaCaptureOverlayState();
}

class _SqaCaptureOverlayState extends ConsumerState<SqaCaptureOverlay>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final _DrawingController _drawingController = _DrawingController();
  Offset? _startPos;
  Offset? _currentPos;
  final ValueNotifier<Offset?> _barOffsetNotifier = ValueNotifier<Offset?>(null);
  Timer? _mousePollingTimer;
  Timer? _laserPruneTimer;
  bool _isDragging = false;
  Offset _dragGrabOffset = Offset.zero;

  // Click Feedback State
  final List<ClickRipple> _ripples = [];
  bool _leftMouseDownLast = false;
  bool _rightMouseDownLast = false;
  bool _isIgnoring = false;
  bool _isPollingProcessing = false;
  final FocusNode _focusNode = FocusNode();


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
  void didUpdateWidget(covariant SqaCaptureOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.delegate.isOverlayVisible && !widget.delegate.isOverlayVisible) {
      _mousePollingTimer?.cancel();
    } else if (!oldWidget.delegate.isOverlayVisible && widget.delegate.isOverlayVisible) {
      _startMousePolling();
      _focusNode.requestFocus();
    }

    // Handle Bar Re-seating on Monitor Lock
    if (oldWidget.delegate.lockedDisplay != widget.delegate.lockedDisplay &&
        widget.delegate.lockedDisplay != null) {
      // Small delay to let the physical window move settle (sync with OS)
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          _teleportBarToRect(widget.delegate.selectionRect ?? Rect.zero);
        }
      });
    }

    // Handle Bar Re-teleport when selectionRect changes (including coordinate remap)
    // _lockToMonitor physically moves the window and remaps selectionRect twice:
    //   1. null → spanning-window rect (initial setSelection)
    //   2. spanning-window rect → remapped local rect (after physical move)
    // Both transitions must trigger a re-teleport.
    if (oldWidget.delegate.selectionRect != widget.delegate.selectionRect &&
        widget.delegate.selectionRect != null &&
        widget.delegate.lockedDisplay != null) {
      _teleportBarToRect(widget.delegate.selectionRect!);
    }

  }

  @override
  void dispose() {
    _mousePollingTimer?.cancel();
    _laserPruneTimer?.cancel();
    _animationController.dispose();
    _barOffsetNotifier.dispose();
    _focusNode.dispose();
    _drawingController.dispose();

    super.dispose();
  }

  void _startMousePolling() {
    _mousePollingTimer?.cancel();
    _mousePollingTimer = Timer.periodic(const Duration(milliseconds: 50), (_) async {
      if (!mounted || _isPollingProcessing) return;
      if (!widget.delegate.isOverlayVisible || _isDragging) return;

      _isPollingProcessing = true;
      try {
        if (Platform.isWindows) {
          final leftDown = WindowUtils.isLeftMouseDown();
          final rightDown = WindowUtils.isRightMouseDown();

          // 1. Global Click Detection
          if ((leftDown && !_leftMouseDownLast) || (rightDown && !_rightMouseDownLast)) {
            final cursor = await screenRetriever.getCursorScreenPoint();
            if (!mounted || !widget.delegate.isOverlayVisible) return;
            
            final windowPos = WindowUtils.getAppWindowPosition();
            if (!mounted || !widget.delegate.isOverlayVisible) return;
            final localPos = Offset(cursor.dx - windowPos.dx, cursor.dy - windowPos.dy);

            // Handle Target Confirmation Click
            if ((widget.delegate.isTargetingWindow ||
                    (widget.delegate.captureMode == CaptureMode.fullScreen &&
                        widget.delegate.selectionRect == null)) &&
                leftDown &&
                !_leftMouseDownLast &&
                widget.delegate.targetedWindowRect != null) {
              final targetRect = widget.delegate.targetedWindowRect!;
              _teleportBarToRect(targetRect);
              widget.delegate.confirmTargetWindow(targetRect, widget.delegate.targetWindowName ?? 'Selection');
            }

            if (widget.delegate.enableClickFeedback) {
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
                        DateTime.now().difference(r.timestamp).inMilliseconds > 500);
                  });
                }
              });
            }
          }

          _leftMouseDownLast = leftDown;
          _rightMouseDownLast = rightDown;

          // 2. Window/Monitor Targeting Discovery (Reduced Frequency: 150ms)
          // We use the millisecond timestamp to gate this logic
          final nowMs = DateTime.now().millisecondsSinceEpoch;
          if (nowMs % 150 < 50) {
            if (widget.delegate.isTargetingWindow) {
              final winInfo = WindowUtils.getWindowInfoAt();
              if (winInfo != null) {
                final windowPos = WindowUtils.getAppWindowPosition();
                if (!mounted || !widget.delegate.isOverlayVisible) return;
                final localRect = Rect.fromLTWH(
                  winInfo.rect.left - windowPos.dx,
                  winInfo.rect.top - windowPos.dy,
                  winInfo.rect.width,
                  winInfo.rect.height,
                );
                if (widget.delegate.targetedWindowRect != localRect) {
                  widget.delegate.updateTargetedWindow(localRect, winInfo.title, winInfo.hwnd);
                }
              } else if (widget.delegate.targetedWindowRect != null) {
                widget.delegate.updateTargetedWindow(null, null);
              }
            } else if (widget.delegate.captureMode == CaptureMode.fullScreen &&
                widget.delegate.selectionRect == null) {
              final cursor = await screenRetriever.getCursorScreenPoint();
              if (!mounted || !widget.delegate.isOverlayVisible) return;
              final displays = widget.delegate.availableDisplays;

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
                final windowPos = WindowUtils.getAppWindowPosition();
                if (!mounted || !widget.delegate.isOverlayVisible) return;
                final localRect = Rect.fromLTWH(
                  (targetDisplay.visiblePosition?.dx ?? 0) - windowPos.dx,
                  (targetDisplay.visiblePosition?.dy ?? 0) - windowPos.dy,
                  targetDisplay.size.width,
                  targetDisplay.size.height,
                );
                if (widget.delegate.targetedWindowRect != localRect) {
                  final index = displays.indexOf(targetDisplay);
                  widget.delegate.updateTargetedWindow(localRect, 'Display ${index + 1}');
                }
              } else if (widget.delegate.targetedWindowRect != null) {
                widget.delegate.updateTargetedWindow(null, null);
              }
            } else {
              if (widget.delegate.targetedWindowRect != null) {
                widget.delegate.updateTargetedWindow(null, null);
              }
            }
          }

          // 3. Ignore Mouse Events Logic (150ms interval check)
          if (widget.delegate.enableMousePassthrough && nowMs % 150 < 50) {
            await _handleIgnoreLogic();
          }
        }
      } catch (e) {
        // Silently catch polling errors to prevent log spam in the production console
      } finally {
        _isPollingProcessing = false;
      }
    });
  }

  Future<void> _handleIgnoreLogic() async {
    if (!mounted || !widget.delegate.isOverlayVisible) return;

    final cursor = await screenRetriever.getCursorScreenPoint();
    if (!mounted || !widget.delegate.isOverlayVisible) return;
    
    final windowPos = WindowUtils.getAppWindowPosition();
    if (!mounted || !widget.delegate.isOverlayVisible) return;
    
    final delegate = widget.delegate;
    if (!delegate.isRecording || !delegate.isOverlayVisible || !mounted || delegate.isTargetingWindow) {
      if (_isIgnoring) {
        _isIgnoring = false;
        await delegate.setIgnoreMouseEvents(false);
      }
      return;
    }

    if (_isDragging || _barOffsetNotifier.value == null) {
      if (_isIgnoring) {
        _isIgnoring = false;
        await delegate.setIgnoreMouseEvents(false);
      }
      return;
    }

    final isPointerMode = delegate.currentTool == ScreenshotTool.pointer;
    if (!isPointerMode) {
      if (_isIgnoring) {
        _isIgnoring = false;
        await delegate.setIgnoreMouseEvents(false);
      }
      return;
    }

    const double width = 620.0;
    const double height = 60.0;
    final currentOffset = _barOffsetNotifier.value ?? Offset.zero;
    final barRect = Rect.fromLTWH(
      windowPos.dx + currentOffset.dx,
      windowPos.dy + currentOffset.dy,
      width,
      height,
    );

    final hoverRect = barRect.inflate(10);
    final isHovering = hoverRect.contains(cursor);

    if (isHovering && _isIgnoring) {
      _isIgnoring = false;
      await delegate.setIgnoreMouseEvents(false);
    } else if (!isHovering && !_isIgnoring && delegate.isRecording) {
      _isIgnoring = true;
      await delegate.setIgnoreMouseEvents(true);
    }
  }

  Offset _clampOffset(Offset offset, Size screenSize) {
    const double barWidth = 650.0;
    const double barHeight = 60.0;
    const double padding = 12.0;

    return Offset(
      offset.dx.clamp(padding, math.max(padding, screenSize.width - barWidth - padding)),
      offset.dy.clamp(padding, math.max(padding, screenSize.height - barHeight - padding)),
    );
  }

  void _teleportBarToRect(Rect targetRect) {
    if (!mounted) return;
    final displays = widget.delegate.availableDisplays;
    if (displays.isEmpty) return;

    final windowPos = WindowUtils.getAppWindowPosition();
    // Use the rect center in GLOBAL coordinates to find the display
    final globalCenter = targetRect.center.translate(windowPos.dx, windowPos.dy);

    Display? activeDisplay;
    for (final d in displays) {
      final dPos = d.visiblePosition ?? Offset.zero;
      final dRect = Rect.fromLTWH(dPos.dx, dPos.dy, d.size.width, d.size.height);
      if (dRect.contains(globalCenter)) {
        activeDisplay = d;
        break;
      }
    }

    if (activeDisplay != null) {
      final dPos = activeDisplay.visiblePosition ?? Offset.zero;

      const double barWidth = 620.0;
      const double barHeight = 60.0;
      const double paddingBottom = 60.0;

      // Calculate global target position for the bar
      final globalTargetX = dPos.dx + (activeDisplay.size.width / 2) - (barWidth / 2);
      final globalTargetY = dPos.dy + activeDisplay.size.height - barHeight - paddingBottom;

      // Transform to local coordinates relative to the CURRENT window position
      final targetOffset = Offset(
        globalTargetX - windowPos.dx,
        globalTargetY - windowPos.dy,
      );

      final size = MediaQuery.of(context).size;
      _barOffsetNotifier.value = _clampOffset(targetOffset, size);
      widget.onBarOffsetChanged?.call(_barOffsetNotifier.value);
    }
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.delegate.isRecording || widget.delegate.selectionRect != null) {
      _drawingController.start();
      _drawingController.add(details.localPosition);

      if (widget.delegate.currentTool == ScreenshotTool.laser) {
        _startLaserPruning();
      }
    } else if (widget.delegate.captureMode == CaptureMode.area) {
      final startPos = details.localPosition;
      final windowPos = WindowUtils.getAppWindowPosition();
      final globalStart = startPos.translate(windowPos.dx, windowPos.dy);

      Display? startDisplay;
      for (final d in widget.delegate.availableDisplays) {
        final dPos = d.visiblePosition ?? Offset.zero;
        final dRect = Rect.fromLTWH(dPos.dx, dPos.dy, d.size.width, d.size.height);
        if (dRect.contains(globalStart)) {
          startDisplay = d;
          break;
        }
      }

      // Notify Logical Lock (First-Touch)
      widget.delegate.setSelection(null, startDisplay);

      setState(() {
        _startPos = startPos;
        _currentPos = startPos;
      });
    }
  }

  void _startLaserPruning() {
    _laserPruneTimer?.cancel();
    _laserPruneTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (widget.delegate.currentTool != ScreenshotTool.laser) {
        _stopLaserPruning();
        return;
      }
      _drawingController.prune(DateTime.now().subtract(const Duration(milliseconds: 1000)));
    });
  }

  void _stopLaserPruning() {
    _laserPruneTimer?.cancel();
    _laserPruneTimer = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if ((widget.delegate.isRecording || widget.delegate.selectionRect != null) &&
        widget.delegate.currentTool != ScreenshotTool.pointer) {
      _drawingController.add(details.localPosition);
    } else if (widget.delegate.captureMode == CaptureMode.area) {
      var currentPos = details.localPosition;

      // Logical Clamping Constraint
      final lockedDisplay = widget.delegate.lockedDisplay;
      if (lockedDisplay != null) {
        final windowPos = WindowUtils.getAppWindowPosition();
        final dPos = lockedDisplay.visiblePosition ?? Offset.zero;

        // Logical bounds of the monitor relative to our spanning window
        final localMinX = dPos.dx - windowPos.dx;
        final localMinY = dPos.dy - windowPos.dy;
        final localMaxX = localMinX + lockedDisplay.size.width;
        final localMaxY = localMinY + lockedDisplay.size.height;

        currentPos = Offset(
          currentPos.dx.clamp(localMinX, localMaxX),
          currentPos.dy.clamp(localMinY, localMaxY),
        );
      }

      setState(() {
        _currentPos = currentPos;
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _stopLaserPruning();
    if (widget.delegate.isRecording || widget.delegate.selectionRect != null) {
      if (_drawingController.points.isNotEmpty) {
        final annotation = Annotation(
          points: List.from(_drawingController.points),
          pointTimestamps: List.from(_drawingController.timestamps),
          tool: widget.delegate.currentTool,
          color: widget.delegate.annotationColor,
        );
        widget.delegate.addAnnotation(annotation);
        _drawingController.clear();
      }
    } else if (widget.delegate.selectionRect == null && _startPos != null && _currentPos != null) {
      final rect = Rect.fromPoints(_startPos!, _currentPos!);
      if (rect.width > 5 && rect.height > 5) {
        _teleportBarToRect(rect);
        widget.delegate.setSelection(rect);
      }
      setState(() {
        _startPos = null;
        _currentPos = null;
      });
    }
  }

  String _formatDuration(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h == '00' ? '$m:$s' : '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final delegate = widget.delegate;
    if (!delegate.isOverlayVisible) return const SizedBox.shrink();

    final selectionRect = delegate.selectionRect ??
        (_startPos != null && _currentPos != null ? Rect.fromPoints(_startPos!, _currentPos!) : null);

    final showInstruction = !delegate.isRecording && delegate.selectionRect == null;

    return DefaultTextStyle(
      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
            // Call cancel via delegate (which eventually calls cancelOverlay/stopCapture)
            widget.delegate.cancelOverlay();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Stack(

            children: [
              // Custom Paint Surface
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: SqaSelectionPainter(
                      selectionRect: selectionRect,
                      targetedWindowRect: delegate.targetedWindowRect,
                      annotations: delegate.annotations,
                      isRecording: delegate.isRecording,
                      isCapturing: delegate.isCapturing,
                      animationValue: _animationController.value,
                      ripples: _ripples,
                      clickFeedbackColor: delegate.clickFeedbackColor,
                      rightClickFeedbackColor: delegate.rightClickFeedbackColor,
                      activePoints: _drawingController.points,
                      activeTimestamps: _drawingController.timestamps,
                      activeTool: delegate.currentTool,
                      activeColor: delegate.annotationColor,
                      repaint: Listenable.merge([
                        _animationController,
                        _drawingController,
                        if (widget.delegate.annotationsChanged != null) widget.delegate.annotationsChanged!,
                      ]),
                    ),
                  ),
                ),
              ),

          // Multi-monitor Instructions
          if (showInstruction && !delegate.isCapturing)
            ..._buildMultiMonitorInstructions(),


          // Floating Bar
          ValueListenableBuilder<Offset?>(
            valueListenable: _barOffsetNotifier,
            builder: (context, barPosition, _) {
              if (barPosition == null || delegate.isCapturing) return const SizedBox.shrink();

              final showBar = delegate.isRecording || (delegate.selectionRect != null || delegate.captureMode == CaptureMode.fullScreen);
              if (!showBar) return const SizedBox.shrink();

              return Positioned(
                left: barPosition.dx,
                top: barPosition.dy,
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
                          final size = MediaQuery.of(context).size;
                          _barOffsetNotifier.value = _clampOffset(details.globalPosition - _dragGrabOffset, size);
                          widget.onBarOffsetChanged?.call(_barOffsetNotifier.value);
                        },
                        onDragEnd: () {
                          setState(() => _isDragging = false);
                        },
                      ),

                      // Timer & Status (if recording or countdown)
                      if (delegate.isRecording || delegate.countdownSeconds > 0)
                        _buildTimerDisplay(delegate),

                      if (delegate.isRecording || delegate.countdownSeconds > 0)
                        const SqaFloatingBarDivider(),

                      // Custom Content from Plugin
                      ...widget.toolbarBuilder(context),
                    ],
                  ),
                ),
              );
            },
          ),

          // Processing indicator removed to prevent dimming in screenshot results
        ],
      ),
    ),
  );
}

  Widget _buildTimerDisplay(CaptureOverlayDelegate delegate) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (delegate.isRecording && !delegate.isPaused)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          if (delegate.countdownSeconds > 0)
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
            delegate.countdownSeconds > 0
                ? '${delegate.countdownSeconds}'
                : _formatDuration(delegate.durationSeconds),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 14,
              color: delegate.countdownSeconds > 0
                  ? Colors.orangeAccent
                  : colorScheme.onSurface,
              shadows: delegate.countdownSeconds > 0
                  ? [
                      Shadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMultiMonitorInstructions() {
    final delegate = widget.delegate;
    double minX = 0, minY = 0;
    for (final d in delegate.availableDisplays) {
      final pos = d.visiblePosition ?? Offset.zero;
      minX = math.min(minX, pos.dx);
      minY = math.min(minY, pos.dy);
    }

    return delegate.availableDisplays.map((display) {
      final dPos = display.visiblePosition ?? Offset.zero;
      final localX = dPos.dx - minX;
      final localY = dPos.dy - minY;

      return Positioned(
        left: localX,
        top: localY,
        width: display.size.width,
        height: display.size.height,
        child: Center(
          child: widget.instructionBuilder?.call(context, delegate.captureMode) ??
              _DefaultInstruction(
                mode: delegate.captureMode,
                targeting: delegate.isTargetingWindow,
              ),
        ),
      );
    }).toList();
  }
}

class _DefaultInstruction extends StatelessWidget {
  final CaptureMode mode;
  final bool targeting;

  const _DefaultInstruction({required this.mode, required this.targeting});

  @override
  Widget build(BuildContext context) {
    final icon = switch (mode) {
      CaptureMode.fullScreen => Symbols.fullscreen,
      CaptureMode.area => Symbols.crop_free,
      CaptureMode.window => Symbols.window,
    };
    final text = switch (mode) {
      CaptureMode.fullScreen => 'Click a monitor to capture',
      CaptureMode.area => 'Drag to select capture area',
      CaptureMode.window => 'Click a window to capture',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 64, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(height: 16),
        Text(
          text,
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
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
        ),
      ],
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../providers/screen_recorder_provider.dart';
import '../models/capture_mode.dart';
import '../../screenshot/models/screenshot_tool.dart';
import '../../screenshot/models/annotation.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_dropdown.dart';
import '../models/screen_recorder_state.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:async';
import 'dart:io'; // added for Platform check
import 'package:win32/win32.dart'; // For global mouse detection
import '../engine/window_utils.dart';

class ClickRipple {
  final Offset position;
  final DateTime timestamp;
  final bool isRightClick;
  final double maxRadius;

  ClickRipple({
    required this.position,
    required this.timestamp,
    this.isRightClick = false,
    this.maxRadius = 30.0,
  });

  double getProgress(DateTime now) {
    final elapsed = now.difference(timestamp).inMilliseconds;
    return (elapsed / 500).clamp(0.0, 1.0);
  }
}

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
  Offset? _barOffset;
  Timer? _mousePollingTimer;
  bool _isIgnoring = false;
  bool _isDragging = false;
  
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
    super.dispose();
  }

  void _startMousePolling() {
    _mousePollingTimer =
        Timer.periodic(const Duration(milliseconds: 20), (_) async {
      final state = ref.read(screenRecorderProvider);
      
      
      // 1. Global Click Detection (Win32 - Windows only)
      if (Platform.isWindows) {
        final bool leftDown = GetAsyncKeyState(VK_LBUTTON) < 0;
        final bool rightDown = GetAsyncKeyState(VK_RBUTTON) < 0;

        if ((leftDown && !_leftMouseDownLast) || (rightDown && !_rightMouseDownLast)) {
          final cursor = await screenRetriever.getCursorScreenPoint();
          final windowPos = await windowManager.getPosition();
          
          // Convert screen coordinates to window-local coordinates
          final localPos = Offset(
            cursor.dx - windowPos.dx,
            cursor.dy - windowPos.dy,
          );

          // Handle Target Confirmation Click
          if (state.isTargetingWindow && leftDown && !_leftMouseDownLast) {
            final winInfo = WindowUtils.getWindowInfoAt(cursor);
            if (winInfo != null) {
              // Convert global physical rect to local logical rect
              final localRect = Rect.fromLTWH(
                winInfo.rect.left - windowPos.dx,
                winInfo.rect.top - windowPos.dy,
                winInfo.rect.width,
                winInfo.rect.height,
              );
              
              ref.read(screenRecorderProvider.notifier).confirmTargetWindow(localRect, winInfo.title);
              _leftMouseDownLast = leftDown;
              _rightMouseDownLast = rightDown;
              return; // Stop further processing for this click
            }
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

        // 2. Window Targeting Discovery
        if (state.isTargetingWindow) {
          final cursor = await screenRetriever.getCursorScreenPoint();
          final winInfo = WindowUtils.getWindowInfoAt(cursor);
          if (winInfo != null) {
            final windowPos = await windowManager.getPosition();
            final localRect = Rect.fromLTWH(
              winInfo.rect.left - windowPos.dx,
              winInfo.rect.top - windowPos.dy,
              winInfo.rect.width,
              winInfo.rect.height,
            );
            
            if (state.targetedWindowRect != localRect) {
              ref.read(screenRecorderProvider.notifier).updateTargetedWindow(localRect, winInfo.title);
            }
          } else if (state.targetedWindowRect != null) {
            ref.read(screenRecorderProvider.notifier).updateTargetedWindow(null, null);
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
    if (_isDragging || _barOffset == null) {
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
    final barRect = Rect.fromLTWH(
      windowPos.dx + _barOffset!.dx,
      windowPos.dy + _barOffset!.dy,
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
    if (_barOffset == null) {
      final size = MediaQuery.of(context).size;
      
      // Default initial placement: Bottom-Center of the entire virtual desktop.
      // We can refine this to track the primary display's local center if needed.
      _barOffset = _clampOffset(
        Offset(size.width / 2 - 310, size.height - 150),
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
        ref.read(screenRecorderProvider.notifier).setSelection(rect);
      }
      setState(() {
        _startPos = null;
        _currentPos = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    if (!state.isOverlayVisible) return const SizedBox.shrink();

    final showInstruction =
        !state.isRecording &&
        state.captureMode == CaptureMode.area &&
        state.selectionRect == null;

    final barPosition = _barOffset ?? Offset.zero;

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
                painter: _RecorderOverlayPainter(
                  selectionRect:
                      state.selectionRect ??
                      (_startPos != null && _currentPos != null
                          ? Rect.fromPoints(_startPos!, _currentPos!)
                          : null),
                  targetedWindowRect: state.targetedWindowRect, // Added
                  isTargeting: state.isTargetingWindow, // Added
                  annotations: state.annotations,
                  isRecording: state.isRecording,
                  animationValue: _animationController,
                  ripples: _ripples,
                ),
              ),
            ),
          ),

          // Centralized Floating Toolbar
          if (state.isRecording ||
              state.selectionRect != null ||
              state.captureMode != CaptureMode.area)
            Positioned(
              left: barPosition.dx,
              top: barPosition.dy,
              child: RepaintBoundary(
                child: MouseRegion(
                  child: SqaFloatingBar(
                    children: [
                      SqaFloatingBarDragHandle(
                        onDragStart: () {
                          setState(() => _isDragging = true);
                        },
                        onDragUpdate: (delta) {
                          setState(() {
                            final size = MediaQuery.of(context).size;
                            _barOffset = _clampOffset(barPosition + delta, size);
                          });
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
          ),

          // Instructions
          if (showInstruction || (state.isTargetingWindow && state.isOverlayVisible))
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  state.isTargetingWindow ? 'Click a window to select it' : 'Drag to select recording area',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RecorderOverlayPainter extends CustomPainter {
  final Rect? selectionRect;
  final Rect? targetedWindowRect;
  final bool isTargeting;
  final List<Annotation> annotations;
  final bool isRecording;
  final Animation<double> animationValue;
  final List<ClickRipple> ripples;

  _RecorderOverlayPainter({
    this.selectionRect,
    this.targetedWindowRect,
    this.isTargeting = false,
    required this.annotations,
    required this.isRecording,
    required this.animationValue,
    required this.ripples,
  }) : super(repaint: animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5);

    if (selectionRect == null && targetedWindowRect == null) {
      if (!isRecording && !isTargeting) canvas.drawRect(Offset.zero & size, backgroundPaint);
    } else if (isTargeting && targetedWindowRect != null) {
      // Draw Targeting Highlight
      final targetPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
        
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetedWindowRect!, const Radius.circular(8)),
        targetPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetedWindowRect!, const Radius.circular(8)),
        borderPaint,
      );
    } else if (selectionRect != null) {
      // Draw dim background with cutout (only if not recording, or always to denote area)
      final path = Path()
        ..addRect(Offset.zero & size)
        ..addRect(selectionRect!)
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, backgroundPaint);

      // Draw selection border (OUTSET to avoid recording leakage)
      final color = isRecording ? Colors.red : Colors.blue;
      
      // Calculate breathing opacity and size for the glow
      final breathe = animationValue.value;
      
      // Outer Glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: isRecording ? (0.2 + breathe * 0.3) : 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0);
      canvas.drawRect(selectionRect!, glowPaint);

      // Main thin border (outset by 4px to ensure zero leakage)
      final borderPaint = Paint()
        ..color = color.withValues(alpha: isRecording ? (0.8 + breathe * 0.2) : 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(selectionRect!.inflate(4.0), borderPaint);

      // Corner Brackets (High Fidelity)
      final bracketPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      const double bracketSize = 20.0;
      final r = selectionRect!.inflate(4.0); // Outset coordinates

      // Top Left
      canvas.drawPath(
        Path()
          ..moveTo(r.left, r.top + bracketSize)
          ..lineTo(r.left, r.top)
          ..lineTo(r.left + bracketSize, r.top),
        bracketPaint,
      );
      // Top Right
      canvas.drawPath(
        Path()
          ..moveTo(r.right - bracketSize, r.top)
          ..lineTo(r.right, r.top)
          ..lineTo(r.right, r.top + bracketSize),
        bracketPaint,
      );
      // Bottom Right
      canvas.drawPath(
        Path()
          ..moveTo(r.right, r.bottom - bracketSize)
          ..lineTo(r.right, r.bottom)
          ..lineTo(r.right - bracketSize, r.bottom),
        bracketPaint,
      );
      // Bottom Left
      canvas.drawPath(
        Path()
          ..moveTo(r.left + bracketSize, r.bottom)
          ..lineTo(r.left, r.bottom)
          ..lineTo(r.left, r.bottom - bracketSize),
        bracketPaint,
      );
    }

    // Draw annotations
    for (final ann in annotations) {
      final paint = Paint()
        ..color = ann.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = ann.strokeWidth
        ..strokeCap = StrokeCap.round;

      if (ann.points.length < 2) continue;

      if (ann.tool == ScreenshotTool.pen || ann.tool == ScreenshotTool.marker) {
        if (ann.tool == ScreenshotTool.marker) {
          paint.color = ann.color.withValues(alpha: 0.4);
        }
        final path = Path()..moveTo(ann.points.first.dx, ann.points.first.dy);
        for (var i = 1; i < ann.points.length; i++) {
          path.lineTo(ann.points[i].dx, ann.points[i].dy);
        }
        canvas.drawPath(path, paint);
      } else if (ann.tool == ScreenshotTool.line) {
        canvas.drawLine(ann.points.first, ann.points.last, paint);
      } else if (ann.tool == ScreenshotTool.rectangle) {
        canvas.drawRect(
          Rect.fromPoints(ann.points.first, ann.points.last),
          paint,
        );
      } else if (ann.tool == ScreenshotTool.arrow) {
        final start = ann.points.first;
        final end = ann.points.last;
        canvas.drawLine(start, end, paint);

        final dX = end.dx - start.dx;
        final dY = end.dy - start.dy;
        final angle = (dX == 0 && dY == 0) ? 0.0 : (Offset(dX, dY).direction);
        const double arrowSize = 12;
        const double arrowAngle = 0.5;

        final headPath = Path()
          ..moveTo(end.dx, end.dy)
          ..lineTo(
            end.dx - arrowSize * math.cos(angle - arrowAngle),
            end.dy - arrowSize * math.sin(angle - arrowAngle),
          )
          ..lineTo(
            end.dx - arrowSize * math.cos(angle + arrowAngle),
            end.dy - arrowSize * math.sin(angle + arrowAngle),
          )
          ..close();

        final fillPaint = Paint()
          ..color = ann.color
          ..style = PaintingStyle.fill;
        canvas.drawPath(headPath, fillPaint);
      }
    }

    // Draw click ripples
    final now = DateTime.now();
    for (final ripple in ripples) {
      final progress = ripple.getProgress(now);
      if (progress >= 1.0) continue;

      final opacity = 1.0 - progress;
      final radius = ripple.maxRadius * progress;

      final ripplePaint = Paint()
        ..color = ripple.isRightClick 
            ? Colors.amber.withValues(alpha: opacity * 0.6)
            : Colors.white.withValues(alpha: opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(ripple.position, radius, ripplePaint);
      
      // Core dot
      final corePaint = Paint()
        ..color = ripple.isRightClick 
            ? Colors.amber.withValues(alpha: opacity * 0.8)
            : Colors.white.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(ripple.position, 4.0 * (1.0 - progress), corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

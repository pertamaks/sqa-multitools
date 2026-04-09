import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../providers/screen_recorder_provider.dart';
import '../models/capture_mode.dart';
import '../../screenshot/models/screenshot_tool.dart';
import '../../screenshot/models/annotation.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';

class ScreenRecorderOverlay extends ConsumerStatefulWidget {
  const ScreenRecorderOverlay({super.key});

  @override
  ConsumerState<ScreenRecorderOverlay> createState() =>
      _ScreenRecorderOverlayState();
}

class _ScreenRecorderOverlayState extends ConsumerState<ScreenRecorderOverlay> {
  Offset? _startPos;
  Offset? _currentPos;

  String _formatDuration(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h == '00' ? '$m:$s' : '$h:$m:$s';
  }

  void _onPanStart(DragStartDetails details) {
    final state = ref.read(screenRecorderProvider);
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

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dim background with cutout
          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: CustomPaint(
              size: Size.infinite,
              painter: _RecorderOverlayPainter(
                selectionRect:
                    state.selectionRect ??
                    (_startPos != null && _currentPos != null
                        ? Rect.fromPoints(_startPos!, _currentPos!)
                        : null),
                annotations: state.annotations,
                isRecording: state.isRecording,
              ),
            ),
          ),

          // Centralized Floating Toolbar
          if (state.isRecording ||
              (state.captureMode == CaptureMode.area &&
                  state.selectionRect != null))
            SqaFloatingBar(
              selectionRect: state.selectionRect,
              customWidths: const {0: 120.0}, // The timer section is wider
              children: [
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
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(state.durationSeconds),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),

                const SqaFloatingBarDivider(),

                // Controls
                SqaFloatingBarButton(
                  icon: state.isRecording
                      ? (state.isPaused ? Symbols.play_arrow : Symbols.pause)
                      : Symbols.play_arrow,
                  tooltip: state.isRecording
                      ? (state.isPaused ? 'Resume' : 'Pause')
                      : 'Start',
                  onPressed: () {
                    if (state.isRecording) {
                      notifier.togglePause();
                    } else {
                      notifier.toggleRecording();
                    }
                  },
                  isPrimary: !state.isRecording || state.isPaused,
                ),

                SqaFloatingBarButton(
                  icon: Symbols.stop,
                  tooltip: 'Stop',
                  onPressed: () => state.isRecording
                      ? notifier.toggleRecording()
                      : notifier.setOverlayVisible(false),
                  color: Colors.red,
                ),

                const SqaFloatingBarDivider(),

                // Annotation Tools
                ...[
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

          // Instructions
          if (showInstruction)
            const Center(
              child: Text(
                'Drag to select recording area',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 10)],
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
  final List<Annotation> annotations;
  final bool isRecording;

  _RecorderOverlayPainter({
    this.selectionRect,
    required this.annotations,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5);

    if (selectionRect == null) {
      if (!isRecording) canvas.drawRect(Offset.zero & size, backgroundPaint);
    } else {
      // Draw dim background with cutout
      final path = Path()
        ..addRect(Offset.zero & size)
        ..addRect(selectionRect!)
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, backgroundPaint);

      // Draw selection border
      final borderPaint = Paint()
        ..color = isRecording ? Colors.red : Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(selectionRect!, borderPaint);
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

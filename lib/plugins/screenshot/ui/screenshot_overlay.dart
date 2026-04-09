import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../models/screenshot_tool.dart';
import '../models/annotation.dart';
import '../providers/screenshot_provider.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';

class ScreenshotOverlay extends ConsumerStatefulWidget {
  const ScreenshotOverlay({super.key});

  @override
  ConsumerState<ScreenshotOverlay> createState() => _ScreenshotOverlayState();
}

class _ScreenshotOverlayState extends ConsumerState<ScreenshotOverlay> {
  Offset? _startPos;
  Offset? _currentPos;

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
            child: CustomPaint(
              size: Size.infinite,
              painter: _OverlayPainter(
                selectionRect:
                    state.selectionRect ??
                    (_startPos != null && _currentPos != null
                        ? Rect.fromPoints(_startPos!, _currentPos!)
                        : null),
                annotations: state.annotations,
              ),
            ),
          ),

          // Combined Floating Toolbar with Centralized SqaFloatingBar
          if (state.selectionRect != null)
            SqaFloatingBar(
              selectionRect: state.selectionRect,
              children: [
                ...[
                  (ScreenshotTool.pen, Symbols.edit, 'Pen'),
                  (ScreenshotTool.line, Symbols.horizontal_rule, 'Line'),
                  (ScreenshotTool.arrow, Symbols.arrow_outward, 'Arrow'),
                  (ScreenshotTool.marker, Symbols.brush, 'Highlighter'),
                  (ScreenshotTool.rectangle, Symbols.rectangle, 'Rectangle'),
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
                ...[Colors.red, Colors.green, Colors.blue, Colors.white].map(
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
                  onPressed: () => notifier.finalize(shouldCopy: true),
                ),
                SqaFloatingBarButton(
                  icon: Symbols.save,
                  tooltip: 'Save Screenshot',
                  onPressed: () => notifier.finalize(),
                  isPrimary: true,
                ),
                SqaFloatingBarButton(
                  icon: Symbols.close,
                  tooltip: 'Cancel',
                  onPressed: notifier.stopCapture,
                  color: Colors.red,
                ),
              ],
            ),

          // Instructions
          if (state.selectionRect == null)
            const Center(
              child: Text(
                'Drag to select a region',
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

class _OverlayPainter extends CustomPainter {
  final Rect? selectionRect;
  final List<Annotation> annotations;

  _OverlayPainter({this.selectionRect, required this.annotations});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5);

    if (selectionRect == null) {
      canvas.drawRect(Offset.zero & size, backgroundPaint);
    } else {
      // Draw dim background with cutout
      final path = Path()
        ..addRect(Offset.zero & size)
        ..addRect(selectionRect!)
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, backgroundPaint);

      // Draw selection border
      final borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(selectionRect!, borderPaint);

      // Draw corner handles (optional for mock)
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

        // Draw arrow head
        final dX = end.dx - start.dx;
        final dY = end.dy - start.dy;
        final angle = (dX == 0 && dY == 0) ? 0.0 : (Offset(dX, dY).direction);
        const double arrowSize = 12;
        const double arrowAngle = 0.5;

        // Better arrow head calculation
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
      } else if (ann.tool == ScreenshotTool.text) {
        // Mock text rendering
        final textPainter = TextPainter(
          text: TextSpan(
            text: 'Text Annotation',
            style: TextStyle(
              color: ann.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, ann.points.first);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

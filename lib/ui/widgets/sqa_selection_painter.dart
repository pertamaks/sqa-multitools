import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/models/annotation.dart';
import '../../core/models/screenshot_tool.dart';
import '../../core/models/click_ripple.dart';

/// A shared, high-fidelity painter for screen selection and annotations.
/// Used by both Screen Recorder and Screenshot plugins to ensure UI consistency.
class SqaSelectionPainter extends CustomPainter {
  final Rect? selectionRect;
  final Rect? targetedWindowRect;
  final List<Annotation> annotations;
  final bool isRecording;
  final double animationValue; // 0.0 to 1.0, used for breathing effects
  final List<ClickRipple> ripples;

  SqaSelectionPainter({
    this.selectionRect,
    this.targetedWindowRect,
    required this.annotations,
    this.isRecording = false,
    this.animationValue = 0.0,
    this.ripples = const [],
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5);

    // 1. Handle Background Dimming & Cutout (Spotlight)
    if (selectionRect != null) {
      final path = Path()
        ..addRect(Offset.zero & size)
        ..addRect(selectionRect!)
        ..fillType = PathFillType.evenOdd;
      canvas.drawPath(path, backgroundPaint);
    }

    // 2. Window/Monitor Hover Highlight
    if (targetedWindowRect != null && selectionRect == null) {
      final targetPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      
      final borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
        
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetedWindowRect!, const Radius.circular(4)),
        targetPaint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(targetedWindowRect!, const Radius.circular(4)),
        borderPaint,
      );
    } else if (selectionRect != null) {
      // 3. Draw Active Selection Border (Glow & Brackets)
      final color = isRecording ? Colors.red : Colors.blue;
      final breathe = animationValue;
      
      // Outer Glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: isRecording ? (0.2 + breathe * 0.3) : 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0);
      canvas.drawRect(selectionRect!, glowPaint);

      // Main thin border (outset by 4px)
      final borderPaint = Paint()
        ..color = color.withValues(alpha: isRecording ? (0.8 + breathe * 0.2) : 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(selectionRect!.inflate(4.0), borderPaint);

      // High-Fidelity Corner Brackets
      final bracketPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      const double bracketSize = 20.0;
      final r = selectionRect!.inflate(4.0);

      // Top Left
      canvas.drawPath(Path()..moveTo(r.left, r.top + bracketSize)..lineTo(r.left, r.top)..lineTo(r.left + bracketSize, r.top), bracketPaint);
      // Top Right
      canvas.drawPath(Path()..moveTo(r.right - bracketSize, r.top)..lineTo(r.right, r.top)..lineTo(r.right, r.top + bracketSize), bracketPaint);
      // Bottom Right
      canvas.drawPath(Path()..moveTo(r.right, r.bottom - bracketSize)..lineTo(r.right, r.bottom)..lineTo(r.right - bracketSize, r.bottom), bracketPaint);
      // Bottom Left
      canvas.drawPath(Path()..moveTo(r.left + bracketSize, r.bottom)..lineTo(r.left, r.bottom)..lineTo(r.left, r.bottom - bracketSize), bracketPaint);
    } else if (selectionRect == null && targetedWindowRect == null) {
      // Clear background if not selecting/targeting
      if (!isRecording) {
        // No-op or draw clear dim if desired. Here we follow 'Clear Targeting' rule.
      }
    }

    // 4. Draw Annotations
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
        canvas.drawRect(Rect.fromPoints(ann.points.first, ann.points.last), paint);
      } else if (ann.tool == ScreenshotTool.arrow) {
        _drawArrow(canvas, ann.points.first, ann.points.last, paint, ann.color);
      } else if (ann.tool == ScreenshotTool.text && ann.text != null) {
        _drawText(canvas, ann.points.first, ann.text!, ann.color);
      }
    }

    // 5. Draw Click Ripples
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
      
      final corePaint = Paint()
        ..color = ripple.isRightClick 
            ? Colors.amber.withValues(alpha: opacity * 0.8)
            : Colors.white.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(ripple.position, 4.0 * (1.0 - progress), corePaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint, Color color) {
    canvas.drawLine(start, end, paint);
    final dX = end.dx - start.dx;
    final dY = end.dy - start.dy;
    final angle = (dX == 0 && dY == 0) ? 0.0 : (Offset(dX, dY).direction);
    const double arrowSize = 12;
    const double arrowAngle = 0.5;

    final headPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize * math.cos(angle - arrowAngle), end.dy - arrowSize * math.sin(angle - arrowAngle))
      ..lineTo(end.dx - arrowSize * math.cos(angle + arrowAngle), end.dy - arrowSize * math.sin(angle + arrowAngle))
      ..close();

    final fillPaint = Paint()..color = color..style = PaintingStyle.fill;
    canvas.drawPath(headPath, fillPaint);
  }

  void _drawText(Canvas canvas, Offset position, String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

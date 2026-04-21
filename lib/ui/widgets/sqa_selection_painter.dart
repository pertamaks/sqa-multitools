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
  final bool isCapturing;
  final double animationValue; // 0.0 to 1.0, used for breathing effects
  final List<ClickRipple> ripples;
  final Color clickFeedbackColor;
  final Color rightClickFeedbackColor;

  // Active Drawing State (for zero-rebuild loop)
  final List<Offset> activePoints;
  final List<DateTime> activeTimestamps;
  final ScreenshotTool? activeTool;
  final Color? activeColor;
  final Annotation? hoveredAnnotation;

  SqaSelectionPainter({
    this.selectionRect,
    this.targetedWindowRect,
    required this.annotations,
    required this.isRecording,
    required this.isCapturing,
    required this.animationValue,
    this.ripples = const [],
    this.clickFeedbackColor = Colors.white,
    this.rightClickFeedbackColor = Colors.amber,
    this.activePoints = const [],
    this.activeTimestamps = const [],
    this.activeTool,
    this.activeColor,
    this.hoveredAnnotation,
    super.repaint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Dimming Layer (Spotlight)
    if (!isCapturing) {
      final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: isRecording ? 0.3 : 0.6);

      if (selectionRect != null) {
        final path = Path()
          ..addRect(Offset.zero & size)
          ..addRect(selectionRect!)
          ..fillType = PathFillType.evenOdd;
        canvas.drawPath(path, backgroundPaint);
      }
    }

    // 2. Window/Monitor Hover Highlight
    if (!isCapturing && targetedWindowRect != null && selectionRect == null) {
      final targetPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRRect(RRect.fromRectAndRadius(targetedWindowRect!, const Radius.circular(4)), targetPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(targetedWindowRect!, const Radius.circular(4)), borderPaint);
    } else if (!isCapturing && selectionRect != null) {
      // 3. Draw Active Selection Border (Glow & Brackets)
      final color = isRecording ? Colors.red : Colors.blue;
      final breathe = animationValue;

      final glowPaint = Paint()
        ..color = color.withValues(alpha: isRecording ? (0.2 + breathe * 0.3) : 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0);
      canvas.drawRect(selectionRect!, glowPaint);

      final borderPaint = Paint()
        ..color = color.withValues(alpha: isRecording ? (0.8 + breathe * 0.2) : 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(selectionRect!.inflate(4.0), borderPaint);

      final bracketPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      const double bracketSize = 20.0;
      final r = selectionRect!.inflate(4.0);

      canvas.drawPath(Path()..moveTo(r.left, r.top + bracketSize)..lineTo(r.left, r.top)..lineTo(r.left + bracketSize, r.top), bracketPaint);
      canvas.drawPath(Path()..moveTo(r.right - bracketSize, r.top)..lineTo(r.right, r.top)..lineTo(r.right, r.top + bracketSize), bracketPaint);
      canvas.drawPath(Path()..moveTo(r.right, r.bottom - bracketSize)..lineTo(r.right, r.bottom)..lineTo(r.right - bracketSize, r.bottom), bracketPaint);
      canvas.drawPath(Path()..moveTo(r.left + bracketSize, r.bottom)..lineTo(r.left, r.bottom)..lineTo(r.left, r.bottom - bracketSize), bracketPaint);
    }

    // 4. Draw Existing Annotations
    for (final ann in annotations) {
      _drawSingleAnnotation(canvas, ann);
    }

    // 5. Draw Active Stroke (the line currently being drawn)
    if (activePoints.length >= 2 && activeTool != null && activeColor != null) {
      _drawSingleAnnotation(
        canvas,
        Annotation(
          points: activePoints,
          pointTimestamps: activeTimestamps,
          tool: activeTool!,
          color: activeColor!,
        ),
      );
    }

    // 6. Draw Click Ripples
    final now = DateTime.now();
    for (final ripple in ripples) {
      final progress = ripple.getProgress(now);
      if (progress >= 1.0) continue;

      final opacity = 1.0 - progress;
      final radius = ripple.maxRadius * progress;

      final ripplePaint = Paint()
        ..color = ripple.isRightClick ? rightClickFeedbackColor.withValues(alpha: opacity * 0.6) : clickFeedbackColor.withValues(alpha: opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(ripple.position, radius, ripplePaint);

      final corePaint = Paint()
        ..color = ripple.isRightClick ? rightClickFeedbackColor.withValues(alpha: opacity * 0.8) : clickFeedbackColor.withValues(alpha: opacity * 0.8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(ripple.position, 4.0 * (1.0 - progress), corePaint);
    }
 
    // 7. Draw Hover Highlight (Glow & Bolder)
    if (hoveredAnnotation != null) {
      _drawHoverHighlight(canvas, hoveredAnnotation!);
    }
  }
 
  void _drawHoverHighlight(Canvas canvas, Annotation ann) {
    // 1. Draw Glow
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (ann.tool == ScreenshotTool.marker && ann.strokeWidth <= 2.0 ? 24.0 : ann.strokeWidth) + 8.0
      ..strokeCap = ann.tool == ScreenshotTool.marker ? StrokeCap.square : StrokeCap.round
      ..strokeJoin = ann.tool == ScreenshotTool.marker ? StrokeJoin.miter : StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    
    _drawAnnotationSurface(canvas, ann, glowPaint);
 
    // 2. Draw Bolder Original (White)
    final topPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = (ann.tool == ScreenshotTool.marker && ann.strokeWidth <= 2.0 ? 24.0 : ann.strokeWidth) + 2.0
      ..strokeCap = ann.tool == ScreenshotTool.marker ? StrokeCap.square : StrokeCap.round
      ..strokeJoin = ann.tool == ScreenshotTool.marker ? StrokeJoin.miter : StrokeJoin.round;
 
    _drawAnnotationSurface(canvas, ann, topPaint);
  }
 
  /// Helper to draw only the path/shape surface without specific colors/logic
  void _drawAnnotationSurface(Canvas canvas, Annotation ann, Paint paint) {
    if (ann.points.isEmpty) return;
 
    if (ann.tool == ScreenshotTool.pen || ann.tool == ScreenshotTool.marker || ann.tool == ScreenshotTool.laser) {
      final path = Path()..moveTo(ann.points.first.dx, ann.points.first.dy);
      for (var i = 1; i < ann.points.length; i++) {
        path.lineTo(ann.points[i].dx, ann.points[i].dy);
      }
      canvas.drawPath(path, paint);
    } else if (ann.tool == ScreenshotTool.line) {
      if (ann.points.length >= 2) canvas.drawLine(ann.points.first, ann.points.last, paint);
    } else if (ann.tool == ScreenshotTool.rectangle) {
      if (ann.points.length >= 2) canvas.drawRect(Rect.fromPoints(ann.points.first, ann.points.last), paint);
    } else if (ann.tool == ScreenshotTool.arrow) {
      if (ann.points.length >= 2) {
        canvas.drawLine(ann.points.first, ann.points.last, paint);
        _drawArrowHead(canvas, ann.points.first, ann.points.last, paint);
      }
    }
  }
 
  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dX = end.dx - start.dx;
    final dY = end.dy - start.dy;
    final angle = (dX == 0 && dY == 0) ? 0.0 : (Offset(dX, dY).direction);
    const double arrowSize = 14;
    const double arrowAngle = 0.5;
 
    final headPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(end.dx - arrowSize * math.cos(angle - arrowAngle), end.dy - arrowSize * math.sin(angle - arrowAngle))
      ..lineTo(end.dx - arrowSize * math.cos(angle + arrowAngle), end.dy - arrowSize * math.sin(angle + arrowAngle))
      ..close();
 
    final headPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(headPath, headPaint);
  }

  void _drawSingleAnnotation(Canvas canvas, Annotation ann) {
    if (ann.points.length < 2 && ann.tool != ScreenshotTool.text) return;

    final paint = Paint()
      ..color = ann.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = ann.tool == ScreenshotTool.marker && ann.strokeWidth <= 2.0 ? 24.0 : ann.strokeWidth
      ..strokeCap = ann.tool == ScreenshotTool.marker ? StrokeCap.square : StrokeCap.round
      ..strokeJoin = ann.tool == ScreenshotTool.marker ? StrokeJoin.miter : StrokeJoin.round;

    if (ann.tool == ScreenshotTool.pen || ann.tool == ScreenshotTool.marker) {
      if (ann.tool == ScreenshotTool.marker) {
        paint.color = ann.color.withValues(alpha: 0.4);
      }
      final path = Path()..moveTo(ann.points.first.dx, ann.points.first.dy);
      for (var i = 1; i < ann.points.length; i++) {
        path.lineTo(ann.points[i].dx, ann.points[i].dy);
      }
      canvas.drawPath(path, paint);
    } else if (ann.tool == ScreenshotTool.laser) {
      final now = DateTime.now();
      const fadeDuration = 1000; // ms

      for (var i = 0; i < ann.points.length - 1; i++) {
        final p1 = ann.points[i];
        final p2 = ann.points[i + 1];
        
        // Calculate opacity based on point age
        double opacity = 1.0;
        if (ann.pointTimestamps.length > i) {
          final age = now.difference(ann.pointTimestamps[i]).inMilliseconds;
          opacity = (1.0 - (age / fadeDuration)).clamp(0.0, 1.0);
        }

        if (opacity <= 0) continue;

        // Draw Glow
        final laserPaint = Paint()
          ..color = ann.color.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
        canvas.drawLine(p1, p2, laserPaint);

        // Draw Core
        final corePaint = Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(p1, p2, corePaint);
      }
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

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(headPath, fillPaint);
  }

  void _drawText(Canvas canvas, Offset position, String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

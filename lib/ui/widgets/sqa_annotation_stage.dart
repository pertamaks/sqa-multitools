import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/models/annotation.dart';
import '../../core/models/screenshot_tool.dart';
import '../../core/models/click_ripple.dart';
import 'sqa_selection_painter.dart';

/// Internal controller for high-performance drawing.
/// Bypasses the widget rebuild cycle for real-time annotation feedback.
class _DrawingController extends ChangeNotifier {
  final List<Offset> _points = [];
  final List<DateTime> _timestamps = [];

  List<Offset> get points => _points;
  List<DateTime> get timestamps => _timestamps;

  void start() {
    _points.clear();
    _timestamps.clear();
    notifyListeners();
  }

  void add(Offset point) {
    _points.add(point);
    _timestamps.add(DateTime.now());
    notifyListeners();
  }

  void replaceLast(Offset point) {
    if (_points.isNotEmpty) {
      _points[_points.length - 1] = point;
      _timestamps[_timestamps.length - 1] = DateTime.now();
      notifyListeners();
    }
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
    _points.clear();
    _timestamps.clear();
    notifyListeners();
  }
}

class SqaAnnotationStage extends StatefulWidget {
  final ScreenshotTool currentTool;
  final Color annotationColor;
  final List<Annotation> annotations;
  final ValueChanged<Annotation> onAnnotationAdded;
  final ValueChanged<Annotation> onAnnotationRemoved;

  // Render props passed down to painter
  final Rect? selectionRect;
  final Rect? targetedWindowRect;
  final bool isRecording;
  final bool isCapturing;
  final double animationValue;
  final List<ClickRipple> ripples;
  final Color clickFeedbackColor;
  final Color rightClickFeedbackColor;
  final Listenable? repaintCapture; // Used to listen to animation controller or other external repaints

  // Interaction delegation
  final bool canDraw; // Allows drawing tools to activate
  final void Function(DragStartDetails details)? onAreaDragStart;
  final void Function(DragUpdateDetails details)? onAreaDragUpdate;
  final void Function(DragEndDetails details)? onAreaDragEnd;
  
  final Key? captureKey;
  final bool textHasBackground;

  const SqaAnnotationStage({
    super.key,
    required this.currentTool,
    required this.annotationColor,
    required this.annotations,
    required this.onAnnotationAdded,
    required this.onAnnotationRemoved,
    required this.selectionRect,
    required this.targetedWindowRect,
    required this.isRecording,
    required this.isCapturing,
    required this.animationValue,
    required this.ripples,
    required this.clickFeedbackColor,
    required this.rightClickFeedbackColor,
    this.repaintCapture,
    required this.canDraw,
    this.onAreaDragStart,
    this.onAreaDragUpdate,
    this.onAreaDragEnd,
    this.captureKey,
    this.textHasBackground = false,
  });

  @override
  State<SqaAnnotationStage> createState() => _SqaAnnotationStageState();
}

class _SqaAnnotationStageState extends State<SqaAnnotationStage> {
  final _DrawingController _drawingController = _DrawingController();
  Timer? _laserPruneTimer;
  Annotation? _hoveredAnnotation;

  // Text Tool State
  Rect? _textInputRect;
  late TextEditingController _textController;
  late FocusNode _textFocusNode;

  // Moving Annotation State
  final ValueNotifier<Annotation?> _movingAnnotationNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFocusNode = FocusNode();
    _textFocusNode.addListener(() {
      if (!_textFocusNode.hasFocus && _textInputRect != null) {
        _submitText(_textController.text);
      }
    });
  }

  void _submitText(String text) {
    if (text.trim().isNotEmpty && _textInputRect != null) {
      final rect = _textInputRect!;
      final newAnnotation = Annotation(
        tool: ScreenshotTool.text,
        points: [rect.topLeft], // Store top-left for anchoring
        color: widget.annotationColor,
        text: text,
        strokeWidth: rect.width, // We hijack strokeWidth to store the maxWidth for wrapping
        hasBackground: widget.textHasBackground,
      );
      widget.onAnnotationAdded(newAnnotation);
    }
    setState(() {
      _textInputRect = null;
      _textController.clear();
    });
  }

  @override
  void dispose() {
    _laserPruneTimer?.cancel();
    _drawingController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    _movingAnnotationNotifier.dispose();
    super.dispose();
  }

  void _onHover(Offset position) {
    if (widget.currentTool != ScreenshotTool.eraser && widget.currentTool != ScreenshotTool.pointer && widget.currentTool != ScreenshotTool.text) {
      if (_hoveredAnnotation != null) {
        setState(() => _hoveredAnnotation = null);
      }
      return;
    }

    final hit = _findAnnotationAt(position);
    if (hit != _hoveredAnnotation) {
      setState(() => _hoveredAnnotation = hit?.tool == ScreenshotTool.text || widget.currentTool == ScreenshotTool.eraser ? hit : null);
    }
  }

  Annotation? _findAnnotationAt(Offset position) {
    const double hitRadius = 15.0;
    
    // Check in reverse order so we hit the top-most (most recent) annotation first
    final annotations = widget.annotations;
    for (int i = annotations.length - 1; i >= 0; i--) {
      if (_isHit(annotations[i], position, hitRadius)) {
        return annotations[i];
      }
    }
    return null;
  }

  bool _isHit(Annotation ann, Offset p, double radius) {
    if (ann.points.isEmpty) return false;

    switch (ann.tool) {
      case ScreenshotTool.pen:
      case ScreenshotTool.marker:
      case ScreenshotTool.laser:
        // Use path segments
        for (int i = 0; i < ann.points.length - 1; i++) {
          if (_distToSegment(p, ann.points[i], ann.points[i + 1]) < radius) return true;
        }
        return false;

      case ScreenshotTool.line:
      case ScreenshotTool.arrow:
        if (ann.points.length >= 2) {
          return _distToSegment(p, ann.points.first, ann.points.last) < radius;
        }
        return false;

      case ScreenshotTool.rectangle:
        if (ann.points.length >= 2) {
          final rect = Rect.fromPoints(ann.points.first, ann.points.last).inflate(radius);
          return rect.contains(p);
        }
        return false;

      case ScreenshotTool.text:
        if (ann.text != null && ann.points.isNotEmpty) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: ann.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            textDirection: TextDirection.ltr,
          );
          if (ann.points.length >= 2) {
            final maxWidth = (ann.points.last.dx - ann.points.first.dx).abs();
            final safeWidth = (maxWidth - 18.0) > 0 ? (maxWidth - 18.0) : 0.0;
            textPainter.layout(maxWidth: safeWidth);
          } else {
            textPainter.layout();
          }
          final textRect = Rect.fromLTWH(
            ann.points.first.dx + 9.0,
            ann.points.first.dy + 9.0,
            textPainter.width,
            textPainter.height,
          ).inflate(radius);
          return textRect.contains(p);
        }
        return false;

      default:
        return false;
    }
  }

  double _distToSegment(Offset p, Offset a, Offset b) {
    final l2 = (a - b).distanceSquared;
    if (l2 == 0) return (p - a).distance;
    var t = ((p.dx - a.dx) * (b.dx - a.dx) + (p.dy - a.dy) * (b.dy - a.dy)) / l2;
    t = math.max(0, math.min(1, t));
    return (p - Offset(a.dx + t * (b.dx - a.dx), a.dy + t * (b.dy - a.dy))).distance;
  }

  void _onPanStart(DragStartDetails details) {
    if (_textInputRect != null) {
      _textFocusNode.unfocus();
      return;
    }

    if (widget.canDraw && widget.currentTool == ScreenshotTool.eraser) {
      final hit = _findAnnotationAt(details.localPosition);
      if (hit != null) {
        widget.onAnnotationRemoved(hit);
        setState(() => _hoveredAnnotation = null);
      }
      return;
    }

    if (widget.canDraw && (widget.currentTool == ScreenshotTool.text || widget.currentTool == ScreenshotTool.pointer)) {
      final hit = _findAnnotationAt(details.localPosition);
      if (hit != null && hit.tool == ScreenshotTool.text) {
        widget.onAnnotationRemoved(hit);
        _movingAnnotationNotifier.value = hit;
        setState(() => _hoveredAnnotation = null);
        return;
      }
    }

    if (widget.canDraw && widget.currentTool != ScreenshotTool.pointer) {
      _drawingController.start();
      _drawingController.add(Offset(details.localPosition.dx.roundToDouble(), details.localPosition.dy.roundToDouble()));

      if (widget.currentTool == ScreenshotTool.laser) {
        _startLaserPruning();
      }
    } else {
      widget.onAreaDragStart?.call(details);
    }
  }

  void _startLaserPruning() {
    _laserPruneTimer?.cancel();
    _laserPruneTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (widget.currentTool != ScreenshotTool.laser) {
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
    if (_movingAnnotationNotifier.value != null) {
      final ann = _movingAnnotationNotifier.value!;
      final newPoints = ann.points.map((p) => p + details.delta).toList();
      _movingAnnotationNotifier.value = ann.copyWith(points: newPoints);
      return;
    }

    if (widget.canDraw && widget.currentTool == ScreenshotTool.eraser) {
      final hit = _findAnnotationAt(details.localPosition);
      if (hit != null) {
        widget.onAnnotationRemoved(hit);
        setState(() => _hoveredAnnotation = null);
      }
      return;
    }

    if (widget.canDraw && widget.currentTool != ScreenshotTool.pointer) {
      if (widget.currentTool == ScreenshotTool.text && _drawingController.points.isNotEmpty) {
        _drawingController.replaceLast(Offset(details.localPosition.dx.roundToDouble(), details.localPosition.dy.roundToDouble()));
      } else {
        _drawingController.add(Offset(details.localPosition.dx.roundToDouble(), details.localPosition.dy.roundToDouble()));
      }
    } else {
      widget.onAreaDragUpdate?.call(details);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _stopLaserPruning();

    if (_movingAnnotationNotifier.value != null) {
      widget.onAnnotationAdded(_movingAnnotationNotifier.value!);
      _movingAnnotationNotifier.value = null;
      return;
    }

    // Handle Text Tool - Show input on end of selection/tap
    if (widget.currentTool == ScreenshotTool.text && widget.canDraw) {
      if (_drawingController.points.isNotEmpty) {
        final start = _drawingController.points.first;
        final end = _drawingController.points.last;
        
        // Default to a 300px box if they just clicked without dragging
        Rect rect = Rect.fromPoints(start, end);
        if (rect.width < 50) {
          rect = Rect.fromLTWH(start.dx, start.dy, 300, 100);
        }

        setState(() {
          _textInputRect = rect;
          _textController.clear();
          _textFocusNode.requestFocus();
        });
        _drawingController.clear();
      }
      return;
    }

    if (widget.canDraw && widget.currentTool != ScreenshotTool.pointer) {
      if (_drawingController.points.isNotEmpty) {
        final annotation = Annotation(
          points: List.from(_drawingController.points),
          pointTimestamps: List.from(_drawingController.timestamps),
          tool: widget.currentTool,
          color: widget.annotationColor,
          strokeWidth: widget.currentTool == ScreenshotTool.marker ? 24.0 : 2.0,
        );
        widget.onAnnotationAdded(annotation);
        _drawingController.clear();
      }
    } else {
      widget.onAreaDragEnd?.call(details);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Custom Paint Surface
        MouseRegion(
          onHover: (event) => _onHover(event.localPosition),
          onExit: (_) => setState(() => _hoveredAnnotation = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: RepaintBoundary(
              key: widget.captureKey,
              child: CustomPaint(
                size: Size.infinite,
                painter: SqaSelectionPainter(
                  selectionRect: widget.selectionRect,
                  targetedWindowRect: widget.targetedWindowRect,
                  annotations: widget.annotations,
                  isRecording: widget.isRecording,
                  isCapturing: widget.isCapturing,
                  animationValue: widget.animationValue,
                  ripples: widget.ripples,
                  clickFeedbackColor: widget.clickFeedbackColor,
                  rightClickFeedbackColor: widget.rightClickFeedbackColor,
                  activePoints: _drawingController.points,
                  activeTimestamps: _drawingController.timestamps,
                  activeTool: widget.currentTool,
                  activeColor: widget.annotationColor,
                  hoveredAnnotation: _hoveredAnnotation,
                  movingAnnotation: _movingAnnotationNotifier,
                  repaint: Listenable.merge([_drawingController, _movingAnnotationNotifier, if (widget.repaintCapture != null) widget.repaintCapture!]),
                ),
              ),
            ),
          ),
        ),

        // Text Tool Input
        if (_textInputRect != null)
          Positioned(
            left: _textInputRect!.left,
            top: _textInputRect!.top,
            width: _textInputRect!.width,
            child: TextField(
                  onTapOutside: (_) {},
                  controller: _textController,
              focusNode: _textFocusNode,
              autofocus: true,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: TextStyle(
                color: widget.annotationColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.annotationColor.withValues(alpha: 0.5), style: BorderStyle.solid),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.annotationColor.withValues(alpha: 0.5), style: BorderStyle.solid),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: widget.annotationColor, style: BorderStyle.solid),
                ),
                contentPadding: const EdgeInsets.all(8),
                fillColor: widget.textHasBackground 
                  ? widget.annotationColor.withValues(alpha: 0.25)
                  : Colors.transparent,
                filled: true,
              ),
            ),
          ),
      ],
    );
  }
}

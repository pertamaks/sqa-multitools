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
  });

  @override
  State<SqaAnnotationStage> createState() => _SqaAnnotationStageState();
}

class _SqaAnnotationStageState extends State<SqaAnnotationStage> {
  final _DrawingController _drawingController = _DrawingController();
  Timer? _laserPruneTimer;
  Annotation? _hoveredAnnotation;

  // Text Tool State
  Offset? _textInputPos;
  late TextEditingController _textController;
  late FocusNode _textFocusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _laserPruneTimer?.cancel();
    _drawingController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _onHover(Offset position) {
    if (widget.currentTool != ScreenshotTool.eraser) {
      if (_hoveredAnnotation != null) {
        setState(() => _hoveredAnnotation = null);
      }
      return;
    }

    final hit = _findAnnotationAt(position);
    if (hit != _hoveredAnnotation) {
      setState(() => _hoveredAnnotation = hit);
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
        if (ann.points.isNotEmpty) {
          // Estimate text bounds (16 fontSize * approx length)
          final textLen = (ann.text ?? '').length;
          final rect = Rect.fromLTWH(ann.points.first.dx, ann.points.first.dy, textLen * 10.0, 24.0).inflate(radius);
          return rect.contains(p);
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
    if (widget.canDraw && widget.currentTool == ScreenshotTool.eraser) {
      final hit = _findAnnotationAt(details.localPosition);
      if (hit != null) {
        widget.onAnnotationRemoved(hit);
        setState(() => _hoveredAnnotation = null);
      }
      return;
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
    if (widget.canDraw && widget.currentTool == ScreenshotTool.eraser) {
      final hit = _findAnnotationAt(details.localPosition);
      if (hit != null) {
        widget.onAnnotationRemoved(hit);
        setState(() => _hoveredAnnotation = null);
      }
      return;
    }

    if (widget.canDraw && widget.currentTool != ScreenshotTool.pointer) {
      _drawingController.add(Offset(details.localPosition.dx.roundToDouble(), details.localPosition.dy.roundToDouble()));
    } else {
      widget.onAreaDragUpdate?.call(details);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    _stopLaserPruning();

    // Handle Text Tool - Show input on end of selection/tap
    if (widget.currentTool == ScreenshotTool.text && widget.canDraw) {
      if (_drawingController.points.isNotEmpty) {
        setState(() {
          _textInputPos = _drawingController.points.first;
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
    final List<Listenable> repaintSources = [
      _drawingController,
      if (widget.repaintCapture != null) widget.repaintCapture!,
    ];

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
                  repaint: Listenable.merge(repaintSources),
                ),
              ),
            ),
          ),
        ),

        // Text Tool Input
        if (_textInputPos != null)
          Positioned(
            left: _textInputPos!.dx,
            top: _textInputPos!.dy,
            child: SizedBox(
              width: 300,
              child: TextField(
                controller: _textController,
                focusNode: _textFocusNode,
                autofocus: true,
                style: TextStyle(
                  color: widget.annotationColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    widget.onAnnotationAdded(Annotation(
                      points: [_textInputPos!],
                      tool: ScreenshotTool.text,
                      color: widget.annotationColor,
                      text: value,
                    ));
                  }
                  setState(() {
                    _textInputPos = null;
                    _textController.clear();
                  });
                },
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'screenshot_tool.dart';

class Annotation {
  final List<Offset> points;
  final ScreenshotTool tool;
  final Color color;
  final double strokeWidth;
  final String? text;

  Annotation({
    required this.points,
    required this.tool,
    required this.color,
    this.strokeWidth = 2.0,
    this.text,
  });

  Annotation copyWith({
    List<Offset>? points,
    ScreenshotTool? tool,
    Color? color,
    double? strokeWidth,
    String? text,
  }) {
    return Annotation(
      points: points ?? this.points,
      tool: tool ?? this.tool,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      text: text ?? this.text,
    );
  }
}

import 'package:flutter/material.dart';
import 'screenshot_tool.dart';

class Annotation {
  final List<Offset> points;
  final List<DateTime> pointTimestamps;
  final ScreenshotTool tool;
  final Color color;
  final double strokeWidth;
  final String? text;
  final bool hasBackground;

  Annotation({
    required this.points,
    this.pointTimestamps = const [],
    required this.tool,
    required this.color,
    this.strokeWidth = 2.0,
    this.text,
    this.hasBackground = false,
  });

  Annotation copyWith({
    List<Offset>? points,
    List<DateTime>? pointTimestamps,
    ScreenshotTool? tool,
    Color? color,
    double? strokeWidth,
    String? text,
    bool? hasBackground,
  }) {
    return Annotation(
      points: points ?? this.points,
      pointTimestamps: pointTimestamps ?? this.pointTimestamps,
      tool: tool ?? this.tool,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      text: text ?? this.text,
      hasBackground: hasBackground ?? this.hasBackground,
    );
  }
}

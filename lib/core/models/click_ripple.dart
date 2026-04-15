import 'package:flutter/material.dart';

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

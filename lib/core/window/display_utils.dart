import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';

/// Utilities for multi-monitor coordinate normalization and scale conversion.
class DisplayUtils {
  /// Finds the primary display or baseline display from the list.
  /// Usually the display with (0,0) offset or the first display.
  static Display getPrimaryDisplay(List<Display> displays) {
    if (displays.isEmpty) {
      return Display(
        id: 0,
        name: 'Primary',
        size: Size.zero,
        visiblePosition: Offset.zero,
        visibleSize: Size.zero,
        scaleFactor: 1.0,
      );
    }
    return displays.firstWhere(
      (d) => (d.visiblePosition?.dx ?? 0) == 0 && (d.visiblePosition?.dy ?? 0) == 0,
      orElse: () => displays.first,
    );
  }

  /// Resolves the primary scale factor.
  static double getPrimaryScaleFactor(List<Display> displays) {
    final primary = getPrimaryDisplay(displays);
    return (primary.scaleFactor ?? 1.0).toDouble();
  }

  /// Calculates the display's bounds in Flutter's logical coordinate space.
  ///
  /// On Windows with mixed DPI, Flutter window is scaled by the primary display DPI.
  /// A secondary display with a different scale factor has `display.size` in its own logical units.
  /// To render correctly within Flutter's layout coordinates relative to `originOffset`,
  /// we normalize secondary display sizes against the primary scale factor.
  static Rect getDisplayFlutterBounds(
    Display display, {
    Offset originOffset = Offset.zero,
    double? primaryScale,
    List<Display>? allDisplays,
  }) {
    final pScale = primaryScale ??
        (allDisplays != null ? getPrimaryScaleFactor(allDisplays) : (display.scaleFactor ?? 1.0).toDouble());
    final dScale = (display.scaleFactor ?? 1.0).toDouble();

    // Scale normalization ratio (how much larger/smaller in Flutter's layout coordinates)
    final scaleRatio = (pScale > 0) ? (dScale / pScale) : 1.0;

    final pos = display.visiblePosition ?? Offset.zero;
    final localLeft = pos.dx - originOffset.dx;
    final localTop = pos.dy - originOffset.dy;

    final width = display.size.width * scaleRatio;
    final height = display.size.height * scaleRatio;

    return Rect.fromLTWH(localLeft, localTop, width, height);
  }

  /// Calculates the virtual desktop spanning rect across all displays in primary logical coordinates.
  static Rect buildSpanningRect(List<Display> displays) {
    if (displays.isEmpty) return Rect.zero;

    double minX = 0;
    double minY = 0;
    double maxX = 0;
    double maxY = 0;

    for (final d in displays) {
      final pos = d.visiblePosition ?? Offset.zero;
      final size = d.size;
      minX = math.min(minX, pos.dx);
      minY = math.min(minY, pos.dy);
      maxX = math.max(maxX, pos.dx + size.width);
      maxY = math.max(maxY, pos.dy + size.height);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

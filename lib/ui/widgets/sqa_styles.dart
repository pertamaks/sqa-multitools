import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized UI styles and tokens for SQA-Multitools.
///
/// This class ensures design consistency across all plugins by providing
/// standardized values for border radius, spacing, and interaction states.
class SqaStyles {
  // --- Border Radius Tiers ---

  /// Small radius (6.0) for compact controls like dropdowns and small switches.
  static final radiusSmall = BorderRadius.circular(6.0);

  /// Medium radius (8.0) for interactive elements like buttons and segmented controls.
  static final radiusMedium = BorderRadius.circular(8.0);

  /// Large radius (24.0) for major UI sections and windows.
  static final radiusLarge = BorderRadius.circular(12.0);

  /// Extra large radius (32.0) for special containers.
  static final radiusExtraLarge = BorderRadius.circular(32.0);

  /// Standard window radius (12.0).
  static const double radiusWindow = 8.0;
  static final borderRadiusWindow = BorderRadius.circular(radiusWindow);

  /// Margin around the window content (0.0 since shadow is removed).
  static const double shellMargin = 0.0;

  // --- Interaction States ---

  /// Provides a standardized, premium overlay color for hover/pressed states.
  ///
  /// Usage:
  /// ```dart
  /// overlayColor: SqaStyles.buttonOverlay(context),
  /// ```
  static WidgetStateProperty<Color?> buttonOverlay(
    BuildContext context, {
    Color? baseColor,
    bool silent = false,
  }) {
    final theme = Theme.of(context);
    final color =
        baseColor ??
        (silent ? theme.colorScheme.onSurface : theme.colorScheme.primary);
    final alphaFactor = silent ? 0.5 : 1.0;

    return WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return color.withValues(alpha: 0.12 * alphaFactor);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return color.withValues(alpha: 0.08 * alphaFactor);
      }
      return null;
    });
  }

  /// Standardized shape for buttons using the medium radius.
  static WidgetStateProperty<OutlinedBorder?> buttonShape =
      WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: radiusMedium),
      );

  /// Standardized shape for cards and fields using the large radius.
  static WidgetStateProperty<OutlinedBorder?> cardShape =
      WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: radiusLarge),
      );
}

/// Standardized spacing tokens for SQA-Multitools.
class SqaSpacing {
  /// 4.0
  static const double xSmall = 4.0;

  /// 8.0
  static const double small = 8.0;

  /// 12.0
  static const double medium = 12.0;

  /// 16.0
  static const double large = 16.0;

  /// 24.0
  static const double xLarge = 24.0;

  /// 32.0
  static const double xxLarge = 32.0;

  /// 48.0
  static const double xxxLarge = 48.0;

  // --- Layout Constants ---
  static const double horizontalPadding = 16.0;
  static const double verticalPadding = 12.0;
}


/// Centralized Typography system for SQA-Multitools.
class SqaTextStyles {
  /// Standard headline style (20px, Bold)
  static TextStyle headline(BuildContext context) =>
      GoogleFonts.dmSans(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Standard body style
  static TextStyle body(BuildContext context) =>
      GoogleFonts.dmSans(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      );

  /// Secondary body style (faded/italic)
  static TextStyle bodySecondary(BuildContext context) =>
      GoogleFonts.dmSans(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12,
      );

  /// Standard label style (Bold, 12px)
  static TextStyle labelBold(BuildContext context) =>
      GoogleFonts.dmSans(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      );

  /// Monospace style for codes/timers
  static TextStyle mono(BuildContext context, {double? fontSize, Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        color: color,
      );
}

/// A custom scroll behavior that enables mouse dragging (click and drag) on desktop.
///
/// This provides a more "premium" and mobile-like interaction for scrollable
/// areas like the TabBar and Markdown documents.
class SqaScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

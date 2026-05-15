import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Design Tokens for SQA-Multitools.
/// 
/// This file serves as the single source of truth for the SQA design system,
/// as mandated by the Phase 3 Production Polish roadmap.
class SqaTokens {
  // --- Spacing ---
  static const double spacingNone = 0.0;
  static const double spacingXXSmall = 2.0;
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;
  static const double spacingXXLarge = 32.0;
  static const double spacingXXXLarge = 48.0;
  static const double spacingTiny = 4.0; // Standardized for micro-spacing
  static const double spacingExtraSmall = 4.0; // Alias for spacingXSmall
  
  static const double fontSizeTiny = 11.0;
  static const double fontSizeSmall = 12.0; // Standardized for labels/secondary text
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeXXXLarge = 32.0;

  static const double borderWidthThin = 1.0;
  static const double borderWidthThick = 2.0;

  // --- Border Radii ---
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 32.0;
  static const double radiusFull = 999.0;

  static final BorderRadius borderRadiusSmall = BorderRadius.circular(radiusSmall);
  static final BorderRadius borderRadiusMedium = BorderRadius.circular(radiusMedium);
  static final BorderRadius borderRadiusLarge = BorderRadius.circular(radiusLarge);
  static final BorderRadius borderRadiusExtraLarge = BorderRadius.circular(radiusExtraLarge);

  // --- Layout ---
  static const double windowRadius = radiusLarge;
  static const double contentPaddingHorizontal = spacingLarge;
  static const double contentPaddingVertical = spacingMedium;
  static const double toolbarHeight = 56.0;

  // --- Animation ---
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  static const Curve curveStandard = Curves.easeInOutCubic;
  static const Curve curveDecelerate = Curves.easeOutCubic;

  // --- Typography ---
  static TextStyle headline(BuildContext context) => GoogleFonts.dmSans(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle body(BuildContext context) => GoogleFonts.dmSans(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      );

  static TextStyle bodySecondary(BuildContext context) => GoogleFonts.dmSans(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontSize: 12,
      );

  static TextStyle labelBold(BuildContext context) => GoogleFonts.dmSans(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      );

  static TextStyle mono(BuildContext context, {double? fontSize, Color? color}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: fontSize,
        color: color,
      );
}

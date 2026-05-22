import 'dart:ui';
import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

class SqaStyles {
  // --- Border Radius Tiers ---

  /// Small radius for compact controls.
  static final radiusSmall = SqaTokens.borderRadiusSmall;

  /// Medium radius for interactive elements.
  static final radiusMedium = SqaTokens.borderRadiusMedium;

  /// Large radius for major UI sections.
  static final radiusLarge = SqaTokens.borderRadiusLarge;

  /// Extra large radius for special containers.
  static final radiusExtraLarge = SqaTokens.borderRadiusExtraLarge;

  /// Standard window radius.
  static const double radiusWindow = SqaTokens.windowRadius;
  static final borderRadiusWindow = SqaTokens.borderRadiusLarge;

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
  static const double xSmall = SqaTokens.spacingXSmall;

  /// 8.0
  static const double small = SqaTokens.spacingSmall;

  /// 12.0
  static const double medium = SqaTokens.spacingMedium;

  /// 16.0
  static const double large = SqaTokens.spacingLarge;

  /// 24.0
  static const double xLarge = SqaTokens.spacingXLarge;

  /// 32.0
  static const double xxLarge = SqaTokens.spacingXXLarge;

  /// 48.0
  static const double xxxLarge = SqaTokens.spacingXXXLarge;

  // --- Layout Constants ---
  static const double horizontalPadding = SqaTokens.contentPaddingHorizontal;
  static const double verticalPadding = SqaTokens.contentPaddingVertical;
}


/// Centralized Typography system for SQA-Multitools.
class SqaTextStyles {
  /// Standard headline style
  static TextStyle headline(BuildContext context) => SqaTokens.headline(context);

  /// Standard body style
  static TextStyle body(BuildContext context) => SqaTokens.body(context);

  /// Secondary body style
  static TextStyle bodySecondary(BuildContext context) => SqaTokens.bodySecondary(context);

  /// Standard label style
  static TextStyle labelBold(BuildContext context) => SqaTokens.labelBold(context);

  /// Monospace style
  static TextStyle mono(BuildContext context, {double? fontSize, Color? color}) =>
      SqaTokens.mono(context, fontSize: fontSize, color: color);
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

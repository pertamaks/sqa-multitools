import 'package:flutter/material.dart';

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

  /// Large radius (12.0) for containers, cards, fields, and major UI sections.
  static final radiusLarge = BorderRadius.circular(12.0);

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
  }) {
    final theme = Theme.of(context);
    final color = baseColor ?? theme.colorScheme.primary;

    return WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.pressed)) {
        return color.withValues(alpha: 0.12);
      }
      if (states.contains(WidgetState.hovered) ||
          states.contains(WidgetState.focused)) {
        return color.withValues(alpha: 0.08);
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

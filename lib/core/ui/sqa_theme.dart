import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../../ui/widgets/sqa_styles.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized theme management for SQA-Multitools.
class SqaTheme {
  /// Generates a [ThemeData] based on the provided parameters.
  static ThemeData createTheme({
    required Brightness brightness,
    required ColorScheme? dynamicScheme,
    required Color seedColor,
    required bool useDynamicColor,
  }) {
    ColorScheme scheme;

    if (useDynamicColor && dynamicScheme != null) {
      scheme = dynamicScheme.harmonized();
    } else {
      final baseScheme = ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
      );

      // Overriding neutral roles to keep surfaces clean while preserving accents
      final neutralScheme = ColorScheme.fromSeed(
        seedColor: Colors.grey,
        brightness: brightness,
      );

      scheme = baseScheme.copyWith(
        surface: neutralScheme.surface,
        onSurface: neutralScheme.onSurface,
        onSurfaceVariant: neutralScheme.onSurfaceVariant,
        surfaceContainerLowest: neutralScheme.surfaceContainerLowest,
        surfaceContainerLow: neutralScheme.surfaceContainerLow,
        surfaceContainer: neutralScheme.surfaceContainer,
        surfaceContainerHigh: neutralScheme.surfaceContainerHigh,
        surfaceContainerHighest: neutralScheme.surfaceContainerHighest,
        outline: neutralScheme.outline,
        outlineVariant: neutralScheme.outlineVariant,
      );
    }

    // Base text theme using Inter
    final baseTextTheme = GoogleFonts.dmSansTextTheme(
      brightness == Brightness.dark
          ? ThemeData.dark().textTheme
          : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: GoogleFonts.dmSans().fontFamily,
      textTheme: baseTextTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.windows: _NoTransitionsBuilder(),
          TargetPlatform.linux: _NoTransitionsBuilder(),
          TargetPlatform.macOS: _NoTransitionsBuilder(),
        },
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        trackVisibility: WidgetStateProperty.all(false),
        thickness: WidgetStateProperty.all(4.0),
        radius: const Radius.circular(2.0),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return scheme.primary.withValues(alpha: 0.8);
          }
          return scheme.primary.withValues(alpha: 0.5);
        }),
        interactive: true,
      ),
      filledButtonTheme: _filledButtonTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      iconButtonTheme: _iconButtonTheme(),
      menuButtonTheme: _menuButtonTheme(),
      datePickerTheme: DatePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
        dayOverlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return scheme.primary.withValues(alpha: 0.08);
          }
          if (states.contains(WidgetState.pressed)) {
            return scheme.primary.withValues(alpha: 0.12);
          }
          return null;
        }),
        headerHeadlineStyle: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headerHelpStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        dayStyle: GoogleFonts.inter(fontSize: 14),
      ),
      timePickerTheme: TimePickerThemeData(
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
        hourMinuteShape:
            RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
        dayPeriodShape:
            RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
        hourMinuteColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primaryContainer;
          }
          return scheme.surfaceContainerHigh;
        }),
        hourMinuteTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimaryContainer;
          }
          return scheme.onSurface;
        }),
        dayPeriodColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.onPrimary;
          return scheme.onSurfaceVariant;
        }),
        hourMinuteTextStyle: GoogleFonts.jetBrainsMono(
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        dayPeriodTextStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        color: scheme.surfaceContainerLow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: SqaStyles.radiusMedium,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SqaSpacing.medium,
          vertical: SqaSpacing.small,
        ),
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme() {
    return FilledButtonThemeData(
      style: _commonButtonStyle(isFilled: true),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: _commonButtonStyle(),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: _commonButtonStyle(),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: _commonButtonStyle(),
    );
  }

  static IconButtonThemeData _iconButtonTheme() {
    return IconButtonThemeData(
      style: _commonButtonStyle(),
    );
  }

  static MenuButtonThemeData _menuButtonTheme() {
    return MenuButtonThemeData(
      style: _commonButtonStyle(),
    );
  }

  static ButtonStyle _commonButtonStyle({bool isFilled = false}) {
    return ButtonStyle(
      mouseCursor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return SystemMouseCursors.basic;
        }
        return SystemMouseCursors.click;
      }),
      shape: isFilled
          ? WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
            )
          : null,
    );
  }
}

/// A no-animation page transition that renders the child immediately.
class _NoTransitionsBuilder extends PageTransitionsBuilder {
  const _NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

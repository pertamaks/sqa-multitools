import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

class SqaDatePicker {
  /// Shows a premium, SQA-styled single date picker.
  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              surface: colorScheme.surfaceContainerHigh,
              onSurface: colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: SqaTokens.borderRadiusLarge,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              elevation: 24,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: SqaTokens.borderRadiusMedium,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SqaTokens.borderRadiusMedium,
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SqaTokens.spacingMedium,
                vertical: SqaTokens.spacingMedium,
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: colorScheme.surfaceContainerHigh,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: SqaTokens.borderRadiusLarge,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              headerBackgroundColor: colorScheme.surfaceContainerHighest,
              headerForegroundColor: colorScheme.onSurface,
              dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
              todayBorder: BorderSide(color: colorScheme.primary, width: 1.5),
              dayStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0,
              ),
              dayShape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: SqaTokens.borderRadiusMedium),
              ),
              headerHelpStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              headerHeadlineStyle: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: SqaTokens.fontSizeXXLarge,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// Shows a premium, SQA-styled date range picker.
  static Future<DateTimeRange?> showRange(
    BuildContext context, {
    DateTimeRange? initialDateRange,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: colorScheme.copyWith(
              surface: colorScheme.surfaceContainerHigh,
              onSurface: colorScheme.onSurface,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: SqaTokens.borderRadiusLarge,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              elevation: 24,
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: SqaTokens.borderRadiusMedium,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SqaTokens.borderRadiusMedium,
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SqaTokens.spacingMedium,
                vertical: SqaTokens.spacingMedium,
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: colorScheme.surfaceContainerHigh,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: SqaTokens.borderRadiusLarge,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              rangePickerShape: RoundedRectangleBorder(
                borderRadius: SqaTokens.borderRadiusLarge,
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              headerBackgroundColor: colorScheme.surfaceContainerHighest,
              headerForegroundColor: colorScheme.onSurface,
              dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
              todayBorder: BorderSide(color: colorScheme.primary, width: 1.5),
              dayStyle: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 0,
              ),
              dayShape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: SqaTokens.borderRadiusMedium),
              ),
              rangePickerHeaderHelpStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              rangePickerHeaderHeadlineStyle: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold, fontSize: SqaTokens.fontSizeXXLarge),
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: ClipRRect(
                borderRadius: SqaTokens.borderRadiusLarge,
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}

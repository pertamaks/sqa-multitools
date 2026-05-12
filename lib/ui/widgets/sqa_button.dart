import 'package:flutter/material.dart';
import 'sqa_styles.dart';

enum SqaButtonType { primary, tonal, outlined }

/// A standardized button for SQA-Multitools.
///
/// Features a compact 32px height, 12px bold typography, and 8px border radius
/// to ensure a consistent premium feel across all plugins.
class SqaButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final SqaButtonType type;
  final double? width;
  final bool isFullWidth;
  final bool isLoading;
  final Color? color;
  final String? tooltip;

  const SqaButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.type = SqaButtonType.tonal,
    this.width,
    this.isFullWidth = false,
    this.isLoading = false,
    this.color,
    this.tooltip,
  });

  /// Primary action button (Filled)
  factory SqaButton.primary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    double? width,
    bool isFullWidth = false,
    bool isLoading = false,
    Color? color,
    String? tooltip,
  }) {
    return SqaButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      type: SqaButtonType.primary,
      width: width,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      color: color,
      tooltip: tooltip,
    );
  }

  /// Secondary action button (Tonal)
  factory SqaButton.tonal({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    double? width,
    bool isFullWidth = false,
    bool isLoading = false,
    Color? color,
    String? tooltip,
  }) {
    return SqaButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      type: SqaButtonType.tonal,
      width: width,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      color: color,
      tooltip: tooltip,
    );
  }

  /// Tertiary action button (Outlined)
  factory SqaButton.outlined({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    double? width,
    bool isFullWidth = false,
    bool isLoading = false,
    Color? color,
    String? tooltip,
  }) {
    return SqaButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      type: SqaButtonType.outlined,
      width: width,
      isFullWidth: isFullWidth,
      isLoading: isLoading,
      color: color,
      tooltip: tooltip,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 32,
        width: isFullWidth ? double.infinity : width,
        child: FilledButton(
          onPressed: null,
          style: _getButtonStyle(context),
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    Widget button;
    final localColor = color;
    final style = _getButtonStyle(context);
    final child = _buildContent(context);

    final bool isIconOnly = icon != null && label.isEmpty;

    switch (type) {
      case SqaButtonType.primary:
        button = (icon != null && !isIconOnly)
            ? FilledButton.icon(
                onPressed: onPressed,
                style: style.copyWith(
                  backgroundColor: localColor != null
                      ? WidgetStateProperty.all(localColor)
                      : null,
                ),
                icon: Icon(icon, size: 18),
                label: child,
              )
            : FilledButton(
                onPressed: onPressed,
                style: style.copyWith(
                  backgroundColor: localColor != null
                      ? WidgetStateProperty.all(localColor)
                      : null,
                ),
                child: isIconOnly ? Icon(icon, size: 18) : child,
              );
        break;
      case SqaButtonType.tonal:
        button = (icon != null && !isIconOnly)
            ? FilledButton.tonalIcon(
                onPressed: onPressed,
                style: style.copyWith(
                  backgroundColor: localColor != null
                      ? WidgetStateProperty.all(
                          localColor.withValues(alpha: 0.2),
                        )
                      : null,
                  foregroundColor: localColor != null
                      ? WidgetStateProperty.all(localColor)
                      : null,
                ),
                icon: Icon(icon, size: 18),
                label: child,
              )
            : FilledButton.tonal(
                onPressed: onPressed,
                style: style.copyWith(
                  backgroundColor: localColor != null
                      ? WidgetStateProperty.all(
                          localColor.withValues(alpha: 0.2),
                        )
                      : null,
                  foregroundColor: localColor != null
                      ? WidgetStateProperty.all(localColor)
                      : null,
                ),
                child: isIconOnly ? Icon(icon, size: 18) : child,
              );
        break;
      case SqaButtonType.outlined:
        button = (icon != null && !isIconOnly)
            ? OutlinedButton.icon(
                onPressed: onPressed,
                style: style.copyWith(
                  foregroundColor: localColor != null
                      ? WidgetStateProperty.all(localColor)
                      : null,
                  side: localColor != null
                      ? WidgetStateProperty.all(
                          BorderSide(color: localColor.withValues(alpha: 0.5)),
                        )
                      : null,
                ),
                icon: Icon(icon, size: 18),
                label: child,
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: style.copyWith(
                  foregroundColor: localColor != null
                      ? WidgetStateProperty.all(localColor)
                      : null,
                  side: localColor != null
                      ? WidgetStateProperty.all(
                          BorderSide(color: localColor.withValues(alpha: 0.5)),
                        )
                      : null,
                ),
                child: isIconOnly ? Icon(icon, size: 18) : child,
              );
        break;
    }

    final result = SizedBox(
      height: 32,
      width: isFullWidth ? double.infinity : width,
      child: button,
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: result,
      );
    }

    return result;
  }

  Widget _buildContent(BuildContext context) {
    return Text(
      label,
      style: SqaTextStyles.labelBold(context),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    return ButtonStyle(
      minimumSize: WidgetStateProperty.all(Size(width ?? 40, 32)),
      padding: WidgetStateProperty.all(
        label.isEmpty
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: SqaSpacing.medium, vertical: 0),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
      ),
      mouseCursor: WidgetStateProperty.resolveWith<MouseCursor?>((states) {
        if (states.contains(WidgetState.disabled)) return SystemMouseCursors.basic;
        return SystemMouseCursors.click;
      }),
    );
  }
}

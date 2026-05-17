import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'sqa_button.dart';
import 'sqa_settings_button.dart';
import 'sqa_hover_icon_button.dart';
import 'sqa_design_tokens.dart';

/// A standardized row of action buttons: [Clear] | [Primary Action] | [Settings].
///
/// Ensures consistent layout and behavior across all plugins that follow
/// the standard "input -> format/generate -> output" pattern.
class SqaActionButtonGroup extends StatelessWidget {
  final VoidCallback? onClear;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final String sourcePluginId;
  final String? clearTooltip;
  final String? settingsTooltip;
  final double actionWidth;

  const SqaActionButtonGroup({
    super.key,
    required this.onClear,
    required this.actionLabel,
    required this.actionIcon,
    required this.onAction,
    required this.sourcePluginId,
    this.clearTooltip = 'Clear Results',
    this.settingsTooltip,
    this.actionWidth = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Clear Button
        SqaHoverIconButton(
          icon: Symbols.delete,
          onPressed: onClear!,
          color: theme.colorScheme.outline,
          padding: SqaTokens.spacingSmall,
          iconSize: SqaTokens.spacingLarge + SqaTokens.spacingXXSmall,
          tooltip: clearTooltip ?? 'Clear Results',
          borderRadius: SqaTokens.borderRadiusLarge,
        ),
        const SizedBox(width: SqaTokens.spacingSmall),

        // Primary Action
        SqaButton.primary(
          label: actionLabel,
          icon: actionIcon,
          onPressed: onAction,
          width: actionWidth,
        ),
        const SizedBox(width: SqaTokens.spacingSmall),

        // Settings Gear
        SqaSettingsButton(
          sourcePluginId: sourcePluginId,
          tooltip: settingsTooltip,
        ),
      ],
    );
  }
}

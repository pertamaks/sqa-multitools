import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'sqa_button.dart';
import 'sqa_settings_button.dart';
import 'sqa_styles.dart';

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
        IconButton(
          icon: const Icon(Symbols.delete, size: 20),
          onPressed: onClear,
          style: IconButton.styleFrom(
            foregroundColor: theme.colorScheme.outline,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(40, 40),
            shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
          ),
          tooltip: clearTooltip,
        ),
        const SizedBox(width: 8),

        // Primary Action
        SqaButton.primary(
          label: actionLabel,
          icon: actionIcon,
          onPressed: onAction,
          width: actionWidth,
        ),
        const SizedBox(width: 8),

        // Settings Gear
        SqaSettingsButton(
          sourcePluginId: sourcePluginId,
          tooltip: settingsTooltip,
        ),
      ],
    );
  }
}

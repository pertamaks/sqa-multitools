import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../core/providers/plugin_provider.dart';
import 'sqa_styles.dart';
import 'sqa_hover_icon_button.dart';

/// A reusable gear icon button that jumps to the Settings plugin
/// and opens the 'Plugins' tab, while remembering where it came from.
class SqaSettingsButton extends ConsumerWidget {
  final String sourcePluginId;
  final String? tooltip;

  const SqaSettingsButton({
    super.key,
    required this.sourcePluginId,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SqaHoverIconButton(
      icon: Symbols.tune,
      onPressed: () {
        ref
            .read(navigationServiceProvider)
            .jumpToPluginSettings(sourcePluginId);
      },
      color: Theme.of(context).colorScheme.outline,
      padding: 8,
      iconSize: 20,
      tooltip: tooltip ?? 'Plugin Settings',
      borderRadius: SqaStyles.radiusLarge,
    );
  }
}

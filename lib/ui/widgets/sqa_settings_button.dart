import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../core/providers/plugin_provider.dart';
import 'sqa_styles.dart';

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
    return IconButton(
      icon: const Icon(Symbols.tune, size: 20),
      onPressed: () {
        ref
            .read(navigationServiceProvider)
            .jumpToPluginSettings(sourcePluginId);
      },
      style: IconButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.outline,
        padding: const EdgeInsets.all(8),
        minimumSize: const Size(40, 40),
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
      ),
      tooltip: tooltip ?? 'Plugin Settings',
    );
  }
}

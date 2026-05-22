import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/services/logging_service.dart';
import 'sqa_design_tokens.dart';

/// A simpler version that uses a Builder with try-catch for immediate build errors.
class SqaSafePluginBuilder extends ConsumerWidget {
  final Widget Function(BuildContext) builder;
  final String pluginId;
  final String pluginName;

  const SqaSafePluginBuilder({
    super.key,
    required this.builder,
    required this.pluginId,
    required this.pluginName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      return builder(context);
    } catch (e, stack) {
      ref.read(loggingServiceProvider.notifier).logError(
        'UI Crash in plugin $pluginId: $e',
        'PluginBoundary',
        e,
        stack,
      );
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(SqaTokens.spacingXLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.extension_off, 
                size: SqaTokens.spacingXXXLarge, 
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: SqaTokens.spacingLarge),
              Text(
                '$pluginName has encountered an error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SqaTokens.spacingSmall),
              Text(
                'The plugin crashed during rendering. This has been logged.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SqaTokens.spacingXLarge),
              FilledButton.tonalIcon(
                onPressed: () {
                  // Recovery logic could go here
                },
                icon: const Icon(Symbols.refresh, size: SqaTokens.spacingLarge + 2),
                label: const Text('Reload Plugin'),
              ),
            ],
          ),
        ),
      );
    }
  }
}

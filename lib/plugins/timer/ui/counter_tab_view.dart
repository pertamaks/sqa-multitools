import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/counter_provider.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';

class CounterTabView extends ConsumerWidget {
  const CounterTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final notifier = ref.read(counterProvider.notifier);
    final theme = Theme.of(context);

    return SqaPluginScrollableContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SqaButton.tonal(
                onPressed: notifier.decrement,
                icon: Symbols.remove,
                label: '',
                width: SqaTokens.spacingXXLarge + SqaTokens.spacingLarge,
              ),
              const SizedBox(width: SqaTokens.spacingXXLarge),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    '$count',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SqaTokens.spacingXXLarge),
              SqaButton.primary(
                onPressed: notifier.increment,
                icon: Symbols.add,
                label: '',
                width: SqaTokens.spacingXXLarge + SqaTokens.spacingLarge,
              ),
            ],
          ),
          const SizedBox(height: SqaTokens.spacingXXLarge),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: count != 0
                ? SqaButton.tonal(
                    key: const ValueKey('reset'),
                    onPressed: () async {
                      final confirmed = await SqaModal.showDanger(
                        context,
                        title: 'Reset Counter',
                        message:
                            'Are you sure you want to reset the counter to zero?',
                        confirmLabel: 'Reset',
                      );
                      if (confirmed == true) {
                        notifier.reset();
                      }
                    },
                    icon: Symbols.restart_alt,
                    label: 'Reset',
                    width: SqaTokens.spacingXXXLarge * 2.5,
                  )
                : const SizedBox(height: SqaTokens.spacingXXLarge, key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}

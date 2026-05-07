import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/security_payloads_provider.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_button.dart';

class SecurityDisclaimer extends ConsumerWidget {
  const SecurityDisclaimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 100),
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: SqaCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: colorScheme.errorContainer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Symbols.warning, color: colorScheme.error, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SAFETY WARNING',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'These payloads are for authorized security testing only. Using them on unauthorized targets is illegal and unethical.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 32,
                  child: SqaButton.primary(
                    label: 'I UNDERSTAND',
                    onPressed: () => ref
                        .read(securityPayloadsProvider.notifier)
                        .dismissDisclaimer(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

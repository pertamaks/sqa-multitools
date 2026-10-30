import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../services/hash_service.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_toast.dart';

class HashResultsList extends StatelessWidget {
  final List<HashResult> hashes;

  const HashResultsList({super.key, required this.hashes});

  @override
  Widget build(BuildContext context) {
    if (hashes.isEmpty) {
      return Center(
        child: Text(
          'Enter text to generate cryptographic hashes (MD5, SHA-1, SHA-256, SHA-512)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
        ),
      );
    }

    final theme = Theme.of(context);

    return ListView.separated(
      itemCount: hashes.length,
      separatorBuilder: (_, _) => const SizedBox(height: SqaTokens.spacingSmall),
      itemBuilder: (context, index) {
        final item = hashes[index];
        return SqaCard(
          padding: const EdgeInsets.symmetric(
            horizontal: SqaTokens.spacingMedium,
            vertical: SqaTokens.spacingSmall,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 70,
                child: Text(
                  item.algorithm,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: SelectableText(
                  item.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
              ),
              SqaHoverIconButton(
                icon: Symbols.content_copy,
                tooltip: 'Copy ${item.algorithm}',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.value));
                  SqaToast.show(context, 'Copied ${item.algorithm} hash');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

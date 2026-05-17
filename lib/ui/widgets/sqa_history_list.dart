import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'sqa_design_tokens.dart';
import 'sqa_card.dart';
import 'sqa_hover_icon_button.dart';
import 'sqa_modal.dart';

/// A centralized, premium history list component used across all plugins.
///
/// Standardizes the appearance of recent captures, generations, or transactions
/// with integrated section headers, empty states, and list dividers.
class SqaHistoryList<T> extends StatelessWidget {
  final List<T> items;
  final String title;
  final Widget Function(BuildContext context, T item, bool isLast) itemBuilder;
  final VoidCallback? onClearAll;
  final String? clearAllTooltip;
  final String emptyLabel;
  final IconData emptyIcon;
  final EdgeInsets? padding;
  final double dividerIndent;

  const SqaHistoryList({
    super.key,
    required this.items,
    required this.title,
    required this.itemBuilder,
    this.onClearAll,
    this.clearAllTooltip = 'Clear All',
    this.emptyLabel = 'No history yet',
    this.emptyIcon = Symbols.history,
    this.padding,
    this.dividerIndent = SqaTokens.spacingSmall, // Standardized small gap
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: SqaTokens.spacingXXXLarge + SqaTokens.spacingLarge,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                emptyIcon,
                size: SqaTokens.spacingXXXLarge * 1.5,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
              ),
              const SizedBox(height: SqaTokens.spacingLarge),
              Text(
                emptyLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const Spacer(),
            if (onClearAll != null)
              SqaHoverIconButton(
                icon: Symbols.delete_sweep,
                onPressed: () async {
                  final confirmed = await SqaModal.showDanger(
                    context,
                    title: 'Clear $title',
                    message: 'Are you sure you want to clear all items from this list?',
                    confirmLabel: 'Clear All',
                  );
                  if (confirmed == true) {
                    onClearAll!();
                  }
                },
                tooltip: clearAllTooltip,
                iconSize: SqaTokens.spacingLarge + SqaTokens.spacingTiny,
                color: theme.colorScheme.error.withValues(alpha: 0.7),
              ),
          ],
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
        SqaCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                itemBuilder(context, items[i], i == items.length - 1),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: dividerIndent,
                    endIndent: dividerIndent,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

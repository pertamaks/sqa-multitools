import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/text_state.dart';
import '../providers/text_provider.dart';
import '../providers/identity_provider.dart';
import '../widgets/text_config_panel.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_toast.dart';
import 'widgets/history_tile.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../core/utils/locale_names.dart';
import 'package:flutter/services.dart';

class LoremTabView extends ConsumerStatefulWidget {
  const LoremTabView({super.key});

  @override
  ConsumerState<LoremTabView> createState() => _LoremTabViewState();
}

class _LoremTabViewState extends ConsumerState<LoremTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showResult(List<String> session, String title) {
    final text = session.join('\n');
    
    showDialog<void>(
      context: context,
      builder: (context) => SqaModal<void>.custom(
        title: title,
        scrollable: false,
        confirmLabel: 'Close',
        customActions: [
          SqaButton.tonal(
            label: 'Copy',
            icon: Symbols.content_copy,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              SqaToast.show(context, 'Copied to clipboard', type: SqaToastType.success);
            },
          ),
          const SizedBox(width: 8),
          SqaButton.primary(
            label: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: SqaField(
          label: 'Generated Data',
          showLabel: false,
          isMonospace: true,
          readOnly: true,
          isMultiline: true,
          maxLines: null,
          expands: true,
          fontSize: 12,
          showLineNumbers: true,
          showCopyButton: false,
          initialValue: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(textGeneratorProvider);
    final identityState = ref.watch(identityProvider);
    final notifier = ref.read(textGeneratorProvider.notifier);
    final history = state.resultsMap[state.selectedType] ?? [];
    final theme = Theme.of(context);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              _getUsageDescription(state.selectedType),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: SqaSpacing.xLarge),
          const TextConfigPanel(),
          SizedBox(height: SqaSpacing.xLarge),
          
          if (history.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'History',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                SqaHoverIconButton(
                  icon: Symbols.delete_sweep,
                  onPressed: () async {
                    final confirmed = await SqaModal.showDanger(
                      context,
                      title: 'Clear History',
                      message: 'Are you sure you want to clear all generation history for this category?',
                      confirmLabel: 'Clear All',
                    );
                    if (confirmed == true) {
                      notifier.clear();
                    }
                  },
                  tooltip: 'Clear All',
                  iconSize: 18,
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SqaCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < history.length; i++) ...[
                    DataHistoryTile(
                      title: '${state.selectedType.label} • ${LocaleNames.getDisplayName(identityState.locale.name)} (${history.length - i})',
                      subtitle: history[i].first,
                      icon: Symbols.notes,
                      onTap: () => _showResult(history[i], 'Lorem Result'),
                      onDelete: () => ref.read(textGeneratorProvider.notifier).removeHistory(history[i]),
                      customActions: [
                        SqaHoverIconButton(
                          icon: Symbols.content_copy,
                          tooltip: 'Copy all',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: history[i].join('\n')));
                            SqaToast.show(context, 'Copied to clipboard', type: SqaToastType.success);
                          },
                        ),
                      ],
                    ),
                    if (i < history.length - 1) 
                      const Divider(height: 1, indent: 64),
                  ],
                ],
              ),
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Symbols.history,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No history yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getUsageDescription(TextType type) {
    switch (type) {
      case TextType.bytes:
        return 'Generate a specific number of random characters.';
      case TextType.sentence:
        return 'Generate random sentences with a target word count.';
      case TextType.paragraph:
        return 'Generate text blocks with a specific number of sentences.';
      case TextType.chapter:
        return 'Generate long-form content with multiple paragraphs.';
    }
  }
}

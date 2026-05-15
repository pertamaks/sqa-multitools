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
import '../../../ui/widgets/sqa_history_list.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
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
          const SizedBox(width: SqaTokens.spacingXXSmall),
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
          fontSize: SqaTokens.fontSizeSmall,
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
          const SizedBox(height: SqaTokens.spacingXLarge),
          const TextConfigPanel(),
          const SizedBox(height: SqaTokens.spacingXLarge),
          
          SqaHistoryList<List<String>>(
            items: history,
            title: 'History',
            onClearAll: () => notifier.clear(),
            itemBuilder: (context, item, isLast) {
              final index = history.indexOf(item);
              final displayIndex = history.length - index;
              return DataHistoryTile(
                title: '${state.selectedType.label} • ${LocaleNames.getDisplayName(identityState.locale.name)} ($displayIndex)',
                subtitle: item.first,
                icon: Symbols.notes,
                onTap: () => _showResult(item, 'Lorem Result'),
                onDelete: () => notifier.removeHistory(item),
                customActions: [
                  SqaHoverIconButton(
                    icon: Symbols.content_copy,
                    tooltip: 'Copy all',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.join('\n')));
                      SqaToast.show(context, 'Copied to clipboard', type: SqaToastType.success);
                    },
                  ),
                ],
              );
            },
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

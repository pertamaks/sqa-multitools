import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/glyphs_state.dart';
import '../providers/glyphs_provider.dart';
import '../providers/identity_provider.dart';
import '../widgets/glyphs_config_panel.dart';
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

class GlyphsTabView extends ConsumerStatefulWidget {
  const GlyphsTabView({super.key});

  @override
  ConsumerState<GlyphsTabView> createState() => _GlyphsTabViewState();
}

class _GlyphsTabViewState extends ConsumerState<GlyphsTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showResult(List<String> session, String title) {
    final text = session.join('\n');
    final state = ref.read(glyphsGeneratorProvider);
    
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
          isMonospace: state.selectedCategory == GlyphsCategory.specials,
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
    final state = ref.watch(glyphsGeneratorProvider);
    final identityState = ref.watch(identityProvider);
    final notifier = ref.read(glyphsGeneratorProvider.notifier);
    final history = state.resultsMap[state.selectedCategory] ?? [];
    final theme = Theme.of(context);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              _getUsageDescription(state.selectedCategory),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: SqaTokens.spacingXLarge),
          const GlyphsConfigPanel(),
          const SizedBox(height: SqaTokens.spacingXLarge),
          
          SqaHistoryList<List<String>>(
            items: history,
            title: 'History',
            onClearAll: () => notifier.clear(),
            itemBuilder: (context, item, isLast) {
              final index = history.indexOf(item);
              final displayIndex = history.length - index;
              return DataHistoryTile(
                title: '${state.selectedCategory.label} • ${LocaleNames.getDisplayName(identityState.locale.name)} ($displayIndex)',
                subtitle: item.first,
                icon: Symbols.glyphs,
                onTap: () => _showResult(item, 'Glyphs Result'),
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

  String _getUsageDescription(GlyphsCategory category) {
    switch (category) {
      case GlyphsCategory.specials:
        return 'Access mathematical, currency, and technical symbols.';
      case GlyphsCategory.japanese:
        return 'Generate Japanese Hiragana, Katakana, and Kanji characters.';
      case GlyphsCategory.chinese:
        return 'Generate Chinese ideographs (Simplified/Traditional).';
      case GlyphsCategory.arabic:
        return 'Generate Arabic script and localized placeholders.';
      case GlyphsCategory.vietnamese:
        return 'Generate Vietnamese text with proper diacritics.';
    }
  }
}

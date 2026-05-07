import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/glyphs_state.dart';
import '../models/text_state.dart';
import '../providers/glyphs_provider.dart';
import '../widgets/glyphs_config_panel.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(glyphsGeneratorProvider);
    final notifier = ref.read(glyphsGeneratorProvider.notifier);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaSegmentedButton<GlyphsCategory>(
            hasChild: true,
            segments: const [
              ButtonSegment(
                value: GlyphsCategory.specials,
                label: Text('Specials'),
                icon: Icon(Symbols.font_download),
              ),
              ButtonSegment(
                value: GlyphsCategory.japanese,
                label: Text('JA'),
                icon: Icon(Symbols.language_japanese_kana),
              ),
              ButtonSegment(
                value: GlyphsCategory.chinese,
                label: Text('ZH'),
                icon: Icon(Symbols.language_chinese_dayi),
              ),
              ButtonSegment(
                value: GlyphsCategory.arabic,
                label: Text('AR'),
                icon: Icon(Symbols.language_pinyin),
              ),
              ButtonSegment(
                value: GlyphsCategory.vietnamese,
                label: Text('VI'),
                icon: Icon(Symbols.language_korean_latin),
              ),
            ],
            selected: {state.selectedCategory},
            onSelectionChanged: (set) => notifier.setCategory(set.first),
          ),
          SqaSegmentedButton<TextType>(
            isChild: true,
            segments: const [
              ButtonSegment(
                value: TextType.bytes,
                label: Text('Bytes'),
                icon: Icon(Symbols.abc),
              ),
              ButtonSegment(
                value: TextType.sentence,
                label: Text('Sentence'),
                icon: Icon(Symbols.short_text),
              ),
              ButtonSegment(
                value: TextType.paragraph,
                label: Text('Paragraph'),
                icon: Icon(Symbols.notes),
              ),
              ButtonSegment(
                value: TextType.chapter,
                label: Text('Chapter'),
                icon: Icon(Symbols.book),
              ),
            ],
            selected: {state.selectedType},
            onSelectionChanged: (set) => notifier.setType(set.first),
          ),
          const SizedBox(height: 12),
          Text(
            _getUsageDescription(state.selectedCategory),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const GlyphsConfigPanel(),
          if ((state.resultsMap[state.selectedCategory] ?? <String>[])
              .isNotEmpty) ...[
            const SizedBox(height: 24),
            SqaField(
              label: 'Result',
              initialValue:
                  (state.resultsMap[state.selectedCategory] ?? <String>[]).join(
                    '\n\n---\n\n',
                  ),
              icon: Symbols.content_copy,
              isMultiline: true,
              collapsedMaxLines: 10,
              isMonospace: state.selectedCategory == GlyphsCategory.specials,
            ),
          ],
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

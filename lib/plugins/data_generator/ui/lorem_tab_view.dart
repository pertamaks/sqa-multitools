import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/text_state.dart';
import '../providers/text_provider.dart';
import '../widgets/text_config_panel.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';

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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(textGeneratorProvider);
    final notifier = ref.read(textGeneratorProvider.notifier);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaSegmentedButton<TextType>(
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
            _getUsageDescription(state.selectedType),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const TextConfigPanel(),
          if ((state.resultsMap[state.selectedType] ?? <String>[])
              .isNotEmpty) ...[
            const SizedBox(height: 24),
            SqaField(
              label: 'Result',
              initialValue: (state.resultsMap[state.selectedType] ?? <String>[])
                  .join('\n\n---\n\n'),
              icon: Symbols.content_copy,
              isMultiline: true,
              collapsedMaxLines: 10,
            ),
          ],
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

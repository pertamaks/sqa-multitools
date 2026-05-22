import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../providers/text_provider.dart';
import '../models/text_state.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';

class TextConfigPanel extends ConsumerStatefulWidget {
  const TextConfigPanel({super.key});

  @override
  ConsumerState<TextConfigPanel> createState() => _TextConfigPanelState();
}

class _TextConfigPanelState extends ConsumerState<TextConfigPanel> {
  late TextEditingController _sizeController;

  @override
  void initState() {
    super.initState();
    _sizeController = TextEditingController(
      text: ref.read(textGeneratorProvider).size.toString(),
    );
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(textGeneratorProvider);
    final notifier = ref.read(textGeneratorProvider.notifier);
    // Sync controller if state changed from elsewhere
    if (_sizeController.text != state.size.toString()) {
      _sizeController.text = state.size.toString();
    }

    String labelText;
    String hintText;
    switch (state.selectedType) {
      case TextType.bytes:
        labelText = 'CHARACTERS';
        hintText = 'e.g. 100';
        break;
      case TextType.sentence:
        labelText = 'WORDS PER SENTENCE';
        hintText = 'e.g. 12';
        break;
      case TextType.paragraph:
        labelText = 'SENTENCES PER PARAGRAPH';
        hintText = 'e.g. 5';
        break;
      case TextType.chapter:
        labelText = 'PARAGRAPHS PER CHAPTER';
        hintText = 'e.g. 6';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: SqaTokens.spacingLarge),
        SqaField(
          label: labelText,
          hintText: hintText,
          controller: _sizeController,
          onChanged: (val) {
            final intValue = int.tryParse(val) ?? 0;
            if (intValue > 0) {
              notifier.setSize(intValue);
            }
          },
        ),
      ],
    );
  }
}

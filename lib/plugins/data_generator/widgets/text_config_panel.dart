import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/utils/locale_names.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_settings_button.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../providers/text_provider.dart';
import '../providers/identity_provider.dart';
import '../models/text_state.dart';

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
    final identityState = ref.watch(identityProvider);

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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Clear Button
            IconButton(
              icon: const Icon(Symbols.delete, size: 20),
              onPressed: () => notifier.clear(),
              style: IconButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.outline,
                padding: const EdgeInsets.all(8),
                minimumSize: const Size(40, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: SqaStyles.radiusLarge,
                ),
              ),
              tooltip: 'Clear Results',
            ),
            const SizedBox(width: 8),
            SqaButton.tonal(
              label: 'Generate',
              icon: Symbols.wand_stars,
              onPressed: () => notifier.generate(),
              width: 120,
            ),
            const SizedBox(width: 8),
            SqaSettingsButton(
              sourcePluginId: 'com.sqa.data_generator',
              tooltip:
                  '${LocaleNames.getDisplayName(identityState.locale.name)}, ${identityState.quantity} items',
            ),
          ],
        ),
        const SizedBox(height: 16),
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

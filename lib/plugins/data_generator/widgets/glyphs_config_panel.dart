import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/utils/locale_names.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_action_button_group.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../providers/glyphs_provider.dart';
import '../providers/identity_provider.dart';
import '../models/text_state.dart';

class GlyphsConfigPanel extends ConsumerStatefulWidget {
  const GlyphsConfigPanel({super.key});

  @override
  ConsumerState<GlyphsConfigPanel> createState() => _GlyphsConfigPanelState();
}

class _GlyphsConfigPanelState extends ConsumerState<GlyphsConfigPanel> {
  late TextEditingController _sizeController;

  @override
  void initState() {
    super.initState();
    _sizeController = TextEditingController(
      text: ref.read(glyphsGeneratorProvider).size.toString(),
    );
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(glyphsGeneratorProvider);
    final notifier = ref.read(glyphsGeneratorProvider.notifier);
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
        SqaActionButtonGroup(
          onClear: () async {
            if ((state.resultsMap[state.selectedCategory] ?? []).isNotEmpty) {
              final confirmed = await SqaModal.showDanger(
                context,
                title: 'Clear Results',
                message: 'Discard currently generated results?',
                confirmLabel: 'Discard',
              );
              if (confirmed != true) return;
            }
            notifier.clear();
          },
          actionLabel: 'Generate',
          actionIcon: Symbols.wand_stars,
          onAction: () => notifier.generate(),
          sourcePluginId: 'com.sqa.data_generator',
          settingsTooltip:
              '${LocaleNames.getDisplayName(identityState.locale.name)}, ${identityState.quantity} items',
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

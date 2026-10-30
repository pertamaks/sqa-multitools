import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/conversion_types.dart';
import '../models/omniconverter_state.dart';
import '../providers/omniconverter_provider.dart';
import 'widgets/omniconverter_output_modal.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_dropdown.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_modal.dart';

import '../../../ui/widgets/sqa_toast.dart';
import '../../../core/providers/coachmark_provider.dart';
import '../../../core/providers/plugin_provider.dart';
import '../../../core/providers/window_provider.dart';



class OmniConverterView extends ConsumerStatefulWidget {
  const OmniConverterView({super.key});

  static final categorySelectorKey = GlobalKey(debugLabel: 'omniconverter.category');
  static final inputFieldKey = GlobalKey(debugLabel: 'omniconverter.input');
  static final controlToolbarKey = GlobalKey(debugLabel: 'omniconverter.toolbar');
  static final convertButtonKey = GlobalKey(debugLabel: 'omniconverter.convert');

  @override
  ConsumerState<OmniConverterView> createState() => _OmniConverterViewState();
}

class _OmniConverterViewState extends ConsumerState<OmniConverterView> {
  late final TextEditingController _inputController;
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(omniConverterProvider);
    _inputController = TextEditingController(text: state.input);
    _horizontalController = ScrollController();

    _inputController.addListener(() {
      ref.read(omniConverterProvider.notifier).updateInput(_inputController.text);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  void _showOutputModal(OmniConverterState state) {
    showDialog<void>(
      context: context,
      builder: (context) => OmniConverterOutputModal(state: state),
    );
  }

  Future<void> _clearAll() async {
    final state = ref.read(omniConverterProvider);
    if (state.input.isNotEmpty) {
      final confirmed = await SqaModal.showDanger(
        context,
        title: 'Clear Input',
        message: 'Are you sure you want to clear the input text?',
        confirmLabel: 'Clear',
      );
      if (confirmed != true) return;
    }

    ref.read(omniConverterProvider.notifier).clear();
    _inputController.clear();
  }

  void _handleConvert() {
    final notifier = ref.read(omniConverterProvider.notifier);
    notifier.convert();

    final state = ref.read(omniConverterProvider);
    if (state.errorMessage != null) {
      SqaToast.show(context, state.errorMessage!, type: SqaToastType.error);
    } else {
      _showOutputModal(state);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(omniConverterProvider);
    final notifier = ref.read(omniConverterProvider.notifier);

    // Sync controller if external update
    if (_inputController.text != state.input) {
      _inputController.value = TextEditingValue(
        text: state.input,
        selection: TextSelection.collapsed(offset: state.input.length),
      );
    }

    return SqaPluginLayout(
      icon: Symbols.sync_alt,
      title: 'OmniConverter',
      description: 'Transform, encode, decode, and inspect data effortlessly.',
      onShowCoachmark: () {
        ref
            .read(coachmarkServiceProvider.notifier)
            .requestPluginTour('com.sqa.plugin.omniconverter');
      },
      trailing: SqaButton.primary(
        key: OmniConverterView.convertButtonKey,
        icon: Symbols.auto_fix,
        label: '',
        onPressed: state.input.isEmpty ? null : _handleConvert,
      ),
      secondaryHeader: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SqaTokens.spacingXLarge,
          vertical: SqaTokens.spacingSmall,
        ),
        child: Center(
          child: SqaSegmentedButton<ConversionCategory>(
            key: OmniConverterView.categorySelectorKey,
            stretches: false,
            segments: const [
              ButtonSegment(
                value: ConversionCategory.encoding,
                label: Text('Encodings'),
                icon: Icon(Symbols.code, size: SqaTokens.spacingLarge),
              ),
              ButtonSegment(
                value: ConversionCategory.format,
                label: Text('Formats'),
                icon: Icon(Symbols.data_object, size: SqaTokens.spacingLarge),
              ),
              ButtonSegment(
                value: ConversionCategory.jwt,
                label: Text('JWT Token'),
                icon: Icon(Symbols.key, size: SqaTokens.spacingLarge),
              ),
              ButtonSegment(
                value: ConversionCategory.hash,
                label: Text('Hash & Checksum'),
                icon: Icon(Symbols.tag, size: SqaTokens.spacingLarge),
              ),
              ButtonSegment(
                value: ConversionCategory.textCase,
                label: Text('Text & Case'),
                icon: Icon(Symbols.text_fields, size: SqaTokens.spacingLarge),
              ),
            ],
            selected: {state.category},
            onSelectionChanged: (set) {
              notifier.setCategory(set.first);
            },
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SqaTokens.spacingLarge,
          0,
          SqaTokens.spacingLarge,
          SqaTokens.spacingLarge,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildToolbar(context, state, notifier),
            const SizedBox(height: SqaTokens.spacingMedium),
            Expanded(
              child: SqaField(
                key: OmniConverterView.inputFieldKey,
                label: 'Raw Input',
                showLabel: false,
                controller: _inputController,
                isMultiline: true,
                isMonospace: true,
                minLines: 1,
                showLineNumbers: true,
                showCopyButton: false,
                wrap: state.wrapText,
                horizontalScrollController: _horizontalController,
                expands: true,
                hintText: _getInputPlaceholder(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    OmniConverterState state,
    OmniConverterNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      key: OmniConverterView.controlToolbarKey,
      padding: const EdgeInsets.symmetric(
        horizontal: SqaTokens.spacingXSmall,
        vertical: SqaTokens.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: SqaTokens.borderRadiusMedium,
      ),
      child: Row(
        children: [
          const SizedBox(width: SqaTokens.spacingMedium),
          _buildCategoryControls(state, notifier),
          const Spacer(),
          // Settings
          SqaHoverIconButton(
            icon: Symbols.tune,
            onPressed: () {
              ref
                  .read(navigationServiceProvider)
                  .jumpToPluginSettings('com.sqa.plugin.omniconverter');
            },
            tooltip: 'Plugin Settings',
            iconSize: SqaTokens.spacingXLarge,
          ),
          // Clear
          SqaHoverIconButton(
            icon: Symbols.delete_sweep,
            onPressed: _clearAll,
            tooltip: 'Clear Input',
            iconSize: SqaTokens.spacingXLarge,
            color: theme.colorScheme.error.withValues(alpha: 0.7),
          ),
          const SizedBox(width: SqaTokens.spacingSmall),
          Container(
            height: SqaTokens.spacingXLarge,
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: SqaTokens.spacingSmall),
          // Wrap Toggle
          _buildWrapToggle(
            state.wrapText,
            (val) => notifier.setWrapText(val),
          ),
          const SizedBox(width: SqaTokens.spacingSmall),
        ],
      ),
    );
  }

  Widget _buildCategoryControls(OmniConverterState state, OmniConverterNotifier notifier) {
    final windowMode = ref.watch(windowSizeModeProvider);
    final isSquare = windowMode == WindowSizeMode.squareMode;

    switch (state.category) {
      case ConversionCategory.encoding:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SqaDropdown<EncodingSubMode>(
              value: state.encodingMode,
              widthInChars: 8,
              items: EncodingSubMode.values.map((mode) {
                return DropdownMenuItem(
                  value: mode,
                  child: Text(
                    _encodingLabel(mode),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (mode) {
                if (mode != null) notifier.setEncodingMode(mode);
              },
            ),
            const SizedBox(width: SqaTokens.spacingXSmall),
            SqaSegmentedButton<ConversionDirection>(
              stretches: false,
              segments: [
                ButtonSegment(
                  value: ConversionDirection.forward,
                  tooltip: 'Encode',
                  label: isSquare ? const Text('Encode') : null,
                  icon: const Icon(Symbols.arrow_forward, size: 14),
                ),
                ButtonSegment(
                  value: ConversionDirection.reverse,
                  tooltip: 'Decode',
                  label: isSquare ? const Text('Decode') : null,
                  icon: const Icon(Symbols.arrow_back, size: 14),
                ),
              ],
              selected: {state.direction},
              onSelectionChanged: (set) => notifier.setDirection(set.first),
            ),
          ],
        );


      case ConversionCategory.format:
        return SqaDropdown<FormatSubMode>(
          value: state.formatMode,
          widthInChars: 12,
          items: FormatSubMode.values.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Text(
                _formatLabel(mode),
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (mode) {
            if (mode != null) notifier.setFormatMode(mode);
          },
        );

      case ConversionCategory.textCase:
        return SqaDropdown<TextCaseSubMode>(
          value: state.textCaseMode,
          widthInChars: 14,
          items: TextCaseSubMode.values.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Text(
                _textCaseLabel(mode),
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: (mode) {
            if (mode != null) notifier.setTextCaseMode(mode);
          },
        );


      case ConversionCategory.jwt:
        return Text(
          'JWT INSPECTOR',
          style: SqaTokens.labelBold(context).copyWith(
            fontSize: SqaTokens.spacingSmall + 2,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.1,
          ),
        );

      case ConversionCategory.hash:
        return Text(
          'HASH GENERATOR',
          style: SqaTokens.labelBold(context).copyWith(
            fontSize: SqaTokens.spacingSmall + 2,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.1,
          ),
        );
    }
  }

  Widget _buildWrapToggle(bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    final isActive = value;
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.4);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(SqaTokens.radiusSmall),
      child: Tooltip(
        message: isActive ? 'Text Wrapping: ON' : 'Text Wrapping: OFF',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(SqaTokens.radiusSmall),
            border: Border.all(
              color: isActive
                  ? activeColor.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Text(
            'WRAP',
            style: SqaTokens.labelBold(context).copyWith(
              fontSize: SqaTokens.spacingSmall + 1,
              color: isActive ? activeColor : inactiveColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }


  String _getInputPlaceholder(OmniConverterState state) {
    switch (state.category) {
      case ConversionCategory.jwt:
        return 'Paste JWT token here (e.g. eyJhbGciOi...)';
      case ConversionCategory.format:
        return 'Paste JSON, YAML, or XML structured data here...';
      case ConversionCategory.hash:
        return 'Enter text or payload to compute cryptographic hashes...';
      case ConversionCategory.textCase:
        return 'Enter text to transform casing or clean lines...';
      case ConversionCategory.encoding:
        return state.direction == ConversionDirection.forward
            ? 'Enter text to encode...'
            : 'Enter encoded string to decode...';
    }
  }

  String _encodingLabel(EncodingSubMode mode) {
    switch (mode) {
      case EncodingSubMode.base64:
        return 'Base64';
      case EncodingSubMode.url:
        return 'URL / URI';
      case EncodingSubMode.html:
        return 'HTML Entities';
      case EncodingSubMode.hex:
        return 'Hexadecimal';
      case EncodingSubMode.binary:
        return 'Binary';
    }
  }

  String _formatLabel(FormatSubMode mode) {
    switch (mode) {
      case FormatSubMode.jsonToYaml:
        return 'JSON ➔ YAML';
      case FormatSubMode.yamlToJson:
        return 'YAML ➔ JSON';
      case FormatSubMode.jsonToXml:
        return 'JSON ➔ XML';
      case FormatSubMode.xmlToJson:
        return 'XML ➔ JSON';
    }
  }

  String _textCaseLabel(TextCaseSubMode mode) {
    switch (mode) {
      case TextCaseSubMode.camelCase:
        return 'camelCase';
      case TextCaseSubMode.pascalCase:
        return 'PascalCase';
      case TextCaseSubMode.snakeCase:
        return 'snake_case';
      case TextCaseSubMode.kebabCase:
        return 'kebab-case';
      case TextCaseSubMode.constantCase:
        return 'CONSTANT_CASE';
      case TextCaseSubMode.titleCase:
        return 'Title Case';
      case TextCaseSubMode.cleanDuplicates:
        return 'Remove Duplicate Lines';
      case TextCaseSubMode.sortLines:
        return 'Sort Lines';
      case TextCaseSubMode.trimLines:
        return 'Trim Lines';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';

import '../providers/beautifier_provider.dart';
import '../widgets/beautifier_highlighter.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_action_button_group.dart';
import '../../../ui/widgets/sqa_modal.dart';

class BeautifierView extends ConsumerStatefulWidget {
  const BeautifierView({super.key});

  @override
  ConsumerState<BeautifierView> createState() => _BeautifierViewState();
}

class _BeautifierViewState extends ConsumerState<BeautifierView> {
  late BeautifierHighlightController _inputController;
  late BeautifierHighlightController _outputController;
  late ScrollController _inputHorizontalController;
  late ScrollController _outputHorizontalController;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(beautifierProvider);
    final initialTheme = atomOneDarkTheme;

    _inputController = BeautifierHighlightController(
      text: initialState.input,
      language: initialState.language,
      theme: initialTheme,
    );

    _outputController = BeautifierHighlightController(
      text: initialState.output,
      language: initialState.language,
      theme: initialTheme,
    );

    _inputHorizontalController = ScrollController();
    _outputHorizontalController = ScrollController();

    _inputController.addListener(() {
      ref.read(beautifierProvider.notifier).updateInput(_inputController.text);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    _inputHorizontalController.dispose();
    _outputHorizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beautifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final codeTheme = isDark ? atomOneDarkTheme : githubTheme;

    _inputController.language = state.language;
    _outputController.language = state.language;
    _inputController.theme = codeTheme;
    _outputController.theme = codeTheme;

    ref.listen(beautifierProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        SqaToast.show(context, next.error!, type: SqaToastType.error);
      }
    });

    if (_outputController.text != state.output) {
      _outputController.text = state.output;
    }

    return SqaPluginLayout(
      icon: Symbols.code_blocks,
      title: 'Code Beautifier',
      description: 'Format messy source code into readable structure.',
      child: SqaPluginScrollableContent(
        center: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SOURCE LANGUAGE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                SqaSegmentedButton<BeautifierLanguage>(
                  segments: BeautifierLanguage.values.map((lang) {
                    return ButtonSegment(
                      value: lang,
                      label: Text(lang.label),
                      icon: Icon(lang.icon),
                    );
                  }).toList(),
                  selected: {state.language},
                  onSelectionChanged: (set) {
                    ref
                        .read(beautifierProvider.notifier)
                        .setLanguage(set.first);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _getUsageDescription(state.language),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SqaField(
              label: 'Raw Input',
              controller: _inputController,
              isMultiline: true,
              isMonospace: true,
              minLines: 1,
              showLineNumbers: true,
              wrap: state.inputWrapText,
              horizontalScrollController: _inputHorizontalController,
              collapsedMaxLines: 15,
              trailing: _buildWrapToggle(
                state.inputWrapText,
                (val) =>
                    ref.read(beautifierProvider.notifier).setInputWrapText(val),
              ),
            ),
            const SizedBox(height: 16),
            SqaActionButtonGroup(
              onClear: _clearAll,
              actionLabel: 'Format Code',
              actionIcon: Symbols.auto_fix,
              onAction: () => ref.read(beautifierProvider.notifier).format(),
              sourcePluginId: 'com.sqa.beautifier',
              actionWidth: 160,
            ),
            const SizedBox(height: 16),
            SqaField(
              label: 'Beautified Output',
              controller: _outputController,
              isMultiline: true,
              isMonospace: true,
              readOnly: true,
              minLines: 1,
              showLineNumbers: true,
              wrap: state.outputWrapText,
              horizontalScrollController: _outputHorizontalController,
              collapsedMaxLines: 15,
              trailing: _buildWrapToggle(
                state.outputWrapText,
                (val) => ref
                    .read(beautifierProvider.notifier)
                    .setOutputWrapText(val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAll() async {
    final state = ref.read(beautifierProvider);
    if (state.input.isNotEmpty || state.output.isNotEmpty) {
      final confirmed = await SqaModal.showDanger(
        context,
        title: 'Clear Code',
        message: 'Are you sure you want to clear all input and output code?',
        confirmLabel: 'Clear',
      );
      if (confirmed != true) return;
    }

    ref.read(beautifierProvider.notifier).clear();
    _inputController.clear();
    _outputController.clear();
  }

  Widget _buildWrapToggle(bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'WRAP',
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        SqaSwitch(value: value, onChanged: onChanged),
      ],
    );
  }

  String _getUsageDescription(BeautifierLanguage language) {
    switch (language) {
      case BeautifierLanguage.json:
        return 'Standardize JSON indentation and key sorting for better readability.';
      case BeautifierLanguage.sql:
        return 'Format SQL queries with proper keyword capitalization and alignment.';
      case BeautifierLanguage.xml:
        return 'Prettify XML tags and attributes with hierarchical indentation.';
      case BeautifierLanguage.html:
        return 'Clean up HTML structure and nested elements.';
      case BeautifierLanguage.dart:
        return 'Basic Dart formatting for code snippets and logic.';
      case BeautifierLanguage.yaml:
        return 'Validate and format YAML configuration files.';
      case BeautifierLanguage.javascript:
        return 'Format JS code with consistent bracing and spacing.';
      case BeautifierLanguage.css:
        return 'Organize CSS rules and properties into a clean structure.';
    }
  }
}

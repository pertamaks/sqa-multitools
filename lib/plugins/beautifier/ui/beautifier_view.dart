import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';

import '../providers/beautifier_provider.dart';
import '../models/beautifier_state.dart';
import '../widgets/beautifier_highlighter.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../core/providers/plugin_provider.dart';

class BeautifierView extends ConsumerStatefulWidget {
  const BeautifierView({super.key});

  @override
  ConsumerState<BeautifierView> createState() => _BeautifierViewState();
}

class _BeautifierViewState extends ConsumerState<BeautifierView> {
  late BeautifierHighlightController _inputController;
  late ScrollController _inputHorizontalController;

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

    _inputHorizontalController = ScrollController();

    _inputController.addListener(() {
      ref.read(beautifierProvider.notifier).updateInput(_inputController.text);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputHorizontalController.dispose();
    super.dispose();
  }

  void _showOutputModal(String output, BeautifierLanguage language) {
    showDialog<void>(
      context: context,
      builder: (context) => BeautifierOutputModal(
        output: output,
        language: language,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(beautifierProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final codeTheme = isDark ? atomOneDarkTheme : githubTheme;

    _inputController.language = state.language;
    _inputController.theme = codeTheme;

    // Listen for formatting completion
    ref.listen(beautifierProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        SqaToast.show(context, next.error!, type: SqaToastType.error);
      } else if (next.output.isNotEmpty && next.output != previous?.output) {
        _showOutputModal(next.output, next.language);
      }
    });

    return SqaPluginLayout(
      icon: Symbols.code_blocks,
      title: 'Beautifier',
      description: 'Clean and format source code instantly.',
      trailing: SqaButton.primary(
        icon: Symbols.auto_fix,
        label: '',
        onPressed: state.input.isEmpty 
          ? null 
          : () => ref.read(beautifierProvider.notifier).format(),
      ),
      secondaryHeader: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SqaTokens.spacingXLarge,
          vertical: SqaTokens.spacingSmall,
        ),
        child: Center(
          child: SqaSegmentedButton<BeautifierLanguage>(
            stretches: false,
            segments: BeautifierLanguage.values.map((lang) {
              return ButtonSegment(
                value: lang,
                label: Text(lang.label),
                icon: Icon(lang.icon, size: SqaTokens.spacingLarge),
              );
            }).toList(),
            selected: {state.language},
            onSelectionChanged: (set) {
              ref.read(beautifierProvider.notifier).setLanguage(set.first);
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
            _buildToolbar(context, state),
            const SizedBox(height: SqaTokens.spacingMedium),
            Expanded(
              child: SqaField(
                label: 'Raw Input',
                showLabel: false,
                controller: _inputController,
                isMultiline: true,
                isMonospace: true,
                minLines: 1,
                showLineNumbers: true,
                showCopyButton: false,
                wrap: state.inputWrapText,
                horizontalScrollController: _inputHorizontalController,
                expands: true,
                hintText: 'Paste your messy code here...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, BeautifierState state) {
    final theme = Theme.of(context);
    
    return Container(
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
          Text(
            state.language.label.toUpperCase(),
            style: SqaTokens.labelBold(context).copyWith(
              fontSize: SqaTokens.spacingSmall + 2,
              color: theme.colorScheme.primary,
              letterSpacing: 1.1,
            ),
          ),
          const Spacer(),
          // Settings (Tune)
          SqaHoverIconButton(
            icon: Symbols.tune,
            onPressed: () {
              ref.read(navigationServiceProvider).jumpToPluginSettings('com.sqa.beautifier');
            },
            tooltip: 'Plugin Settings',
            iconSize: SqaTokens.spacingXLarge,
          ),
          // Clear Input
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
            state.inputWrapText,
            (val) => ref.read(beautifierProvider.notifier).setInputWrapText(val),
          ),
          const SizedBox(width: SqaTokens.spacingSmall),
        ],
      ),
    );
  }

  Future<void> _clearAll() async {
    final state = ref.read(beautifierProvider);
    if (state.input.isNotEmpty) {
      final confirmed = await SqaModal.showDanger(
        context,
        title: 'Clear Input',
        message: 'Are you sure you want to clear the input code?',
        confirmLabel: 'Clear',
      );
      if (confirmed != true) return;
    }

    ref.read(beautifierProvider.notifier).clear();
    _inputController.clear();
  }

  Widget _buildWrapToggle(bool value, ValueChanged<bool> onChanged) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'WRAP',
          style: SqaTokens.labelBold(context).copyWith(
            fontSize: SqaTokens.spacingSmall + 1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: SqaTokens.spacingXSmall),
        SqaSwitch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class BeautifierOutputModal extends StatelessWidget {
  final String output;
  final BeautifierLanguage language;

  const BeautifierOutputModal({
    super.key,
    required this.output,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return SqaModal<void>.custom(
      title: '${language.label} Output',
      scrollable: false,
      confirmLabel: 'Close',
      customActions: [
        SqaButton.tonal(
          label: 'Copy',
          icon: Symbols.content_copy,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: output));
            SqaToast.show(context, 'Output copied to clipboard', type: SqaToastType.success);
          },
        ),
        const SizedBox(width: SqaTokens.spacingSmall),
        SqaButton.primary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: SqaField(
        label: 'Output',
        showLabel: false,
        isMonospace: true,
        readOnly: true,
        isMultiline: true,
        maxLines: null,
        expands: true,
        fontSize: SqaTokens.spacingMedium,
        showLineNumbers: true,
        showCopyButton: false,
        initialValue: output,
      ),
    );
  }
}

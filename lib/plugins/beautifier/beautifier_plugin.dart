import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:highlight/languages/json.dart' as hl_json;
import 'package:highlight/languages/dart.dart' as hl_dart;
import 'package:highlight/languages/xml.dart' as hl_xml;
import 'package:highlight/languages/sql.dart' as hl_sql;
import 'package:highlight/languages/yaml.dart' as hl_yaml;
import 'package:highlight/languages/javascript.dart' as hl_javascript;
import 'package:highlight/languages/css.dart' as hl_css;

import '../../ui/widgets/sqa_field.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_dropdown.dart';
import '../../ui/widgets/sqa_segmented_button.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_switch.dart';
import '../../ui/widgets/sqa_toast.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../ui/widgets/sqa_action_button_group.dart';
import '../../core/models/sqa_plugin.dart';
import './providers/beautifier_provider.dart';

class BeautifierPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.beautifier';
  @override
  String get name => 'Beautifier';
  @override
  String get description => 'Format and beautify code for various languages.';
  @override
  IconData get icon => Symbols.code_blocks;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _BeautifierView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const _BeautifierSettings();
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

enum BeautifierLanguage {
  json('JSON', 'json', Symbols.file_json),
  sql('SQL', 'sql', Symbols.database),
  xml('XML', 'xml', Symbols.code),
  html('HTML', 'xml', Symbols.html),
  dart('Dart', 'dart', Symbols.flutter),
  yaml('YAML', 'yaml', Symbols.docs),
  javascript('JavaScript', 'javascript', Symbols.javascript),
  css('CSS', 'css', Symbols.css);

  final String label;
  final String highlightName;
  final IconData icon;
  const BeautifierLanguage(this.label, this.highlightName, this.icon);

  dynamic get highlightMode {
    switch (this) {
      case BeautifierLanguage.json:
        return hl_json.json;
      case BeautifierLanguage.sql:
        return hl_sql.sql;
      case BeautifierLanguage.xml:
      case BeautifierLanguage.html:
        return hl_xml.xml;
      case BeautifierLanguage.dart:
        return hl_dart.dart;
      case BeautifierLanguage.yaml:
        return hl_yaml.yaml;
      case BeautifierLanguage.javascript:
        return hl_javascript.javascript;
      case BeautifierLanguage.css:
        return hl_css.css;
    }
  }
}

class BeautifierHighlightController extends TextEditingController {
  BeautifierLanguage language;
  Map<String, TextStyle> theme;

  BeautifierHighlightController({
    super.text,
    required this.language,
    required this.theme,
  });

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final highlightResult = highlight.parse(
      text,
      language: language.highlightName,
    );
    return TextSpan(
      style: style,
      children: _convert(highlightResult.nodes ?? []),
    );
  }

  List<TextSpan> _convert(List<Node> nodes) {
    final List<TextSpan> spans = [];
    for (final node in nodes) {
      spans.add(
        TextSpan(
          style: theme[node.className],
          text: node.value,
          children: node.children != null ? _convert(node.children!) : null,
        ),
      );
    }
    return spans;
  }
}

class _BeautifierSettings extends ConsumerWidget {
  const _BeautifierSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final autoFormat = ref.watch(
      beautifierProvider.select((s) => s.autoFormat),
    );
    final inputWrap = ref.watch(
      beautifierProvider.select((s) => s.inputWrapText),
    );
    final indentWidth = ref.watch(
      beautifierProvider.select((s) => s.indentWidth),
    );
    final outputWrap = ref.watch(
      beautifierProvider.select((s) => s.outputWrapText),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BEAUTIFIER SETTINGS',
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        SqaSettingsTile(
          title: 'AUTO-FORMAT ON CHANGE',
          subtitle: 'Format code automatically as you type.',
          trailing: SqaSwitch(
            value: autoFormat,
            onChanged: (val) =>
                ref.read(beautifierProvider.notifier).setAutoFormat(val),
          ),
        ),
        SqaSettingsTile(
          title: 'INDENTATION WIDTH',
          subtitle: 'Number of spaces per indentation level.',
          trailing: SizedBox(
            width: 80,
            child: SqaDropdown<int>(
              value: indentWidth,
              items: [2, 4, 8].map((w) {
                return DropdownMenuItem(value: w, child: Text('$w'));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  ref.read(beautifierProvider.notifier).setIndentWidth(val);
                }
              },
            ),
          ),
        ),
        SqaSettingsTile(
          title: 'WRAP INPUT TEXT',
          subtitle: 'Allow long lines to wrap in the raw input field.',
          trailing: SqaSwitch(
            value: inputWrap,
            onChanged: (val) =>
                ref.read(beautifierProvider.notifier).setInputWrapText(val),
          ),
        ),
        SqaSettingsTile(
          title: 'WRAP OUTPUT TEXT',
          subtitle: 'Allow long lines to wrap in the beautified field.',
          trailing: SqaSwitch(
            value: outputWrap,
            onChanged: (val) =>
                ref.read(beautifierProvider.notifier).setOutputWrapText(val),
          ),
        ),
      ],
    );
  }
}

class _BeautifierView extends ConsumerStatefulWidget {
  const _BeautifierView();

  @override
  ConsumerState<_BeautifierView> createState() => _BeautifierViewState();
}

class _BeautifierViewState extends ConsumerState<_BeautifierView> {
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  ),
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

  void _clearAll() {
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
}

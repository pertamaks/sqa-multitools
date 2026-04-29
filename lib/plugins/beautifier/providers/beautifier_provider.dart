import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dart_style/dart_style.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';
import '../widgets/beautifier_highlighter.dart';
import '../models/beautifier_state.dart';
import '../../../core/services/preferences_service.dart';
import '../utils/sql_formatter.dart';
import '../utils/html_formatter.dart';
import '../utils/js_formatter.dart';
import '../utils/css_formatter.dart';

part 'beautifier_provider.g.dart';

@riverpod
class BeautifierNotifier extends _$BeautifierNotifier {
  final _dartFormatter = DartFormatter(
    languageVersion: DartFormatter.latestLanguageVersion,
  );
  final _yamlWriter = YamlWriter();

  @override
  BeautifierState build() {
    final prefs = ref.watch(preferencesServiceProvider);
    return BeautifierState(
      autoFormat: prefs.getBeautifierAutoFormat(),
      inputWrapText: prefs.getBeautifierInputWrapText(),
      outputWrapText: prefs.getBeautifierOutputWrapText(),
      indentWidth: prefs.getBeautifierIndentWidth(),
    );
  }

  void updateInput(String input) {
    state = state.copyWith(input: input);
    if (state.autoFormat) {
      format();
    }
  }

  void setLanguage(BeautifierLanguage language) {
    state = state.copyWith(language: language);
    if (state.autoFormat) {
      format();
    }
  }

  void setAutoFormat(bool value) {
    state = state.copyWith(autoFormat: value);
    ref.read(preferencesServiceProvider).setBeautifierAutoFormat(value);
    if (value) {
      format();
    }
  }

  void setInputWrapText(bool value) {
    state = state.copyWith(inputWrapText: value);
    ref.read(preferencesServiceProvider).setBeautifierInputWrapText(value);
  }

  void setOutputWrapText(bool value) {
    state = state.copyWith(outputWrapText: value);
    ref.read(preferencesServiceProvider).setBeautifierOutputWrapText(value);
  }

  void setIndentWidth(int value) {
    state = state.copyWith(indentWidth: value);
    ref.read(preferencesServiceProvider).setBeautifierIndentWidth(value);
    if (state.autoFormat) {
      format();
    }
  }

  void clear() {
    state = state.copyWith(input: '', output: '');
  }

  void format() {
    final input = state.input.trim();
    if (input.isEmpty) {
      state = state.copyWith(output: '', error: null);
      return;
    }

    String formatted = '';
    String? error;

    try {
      switch (state.language) {
        case BeautifierLanguage.json:
          final dynamic decoded = json.decode(input);
          formatted = const JsonEncoder.withIndent('  ').convert(decoded);
          break;
        case BeautifierLanguage.dart:
          formatted = _dartFormatter.format(input);
          break;
        case BeautifierLanguage.xml:
          final document = XmlDocument.parse(input);
          formatted = document.toXmlString(
            pretty: true,
            indent: ' ' * state.indentWidth,
          );
          break;
        case BeautifierLanguage.html:
          formatted = HtmlFormatter.format(
            input,
            indentWidth: state.indentWidth,
          );
          break;
        case BeautifierLanguage.yaml:
          final dynamic yamlMap = loadYaml(input);
          formatted = _yamlWriter.write(yamlMap);
          break;
        case BeautifierLanguage.sql:
          formatted = _formatSql(input);
          break;
        case BeautifierLanguage.javascript:
          formatted = JsFormatter.format(input, indentWidth: state.indentWidth);
          break;
        case BeautifierLanguage.css:
          formatted = CssFormatter.format(
            input,
            indentWidth: state.indentWidth,
          );
          break;
      }
    } catch (e) {
      error = 'Invalid ${state.language.label} format';
      formatted = 'ERROR: $error\n$e';
    }

    state = state.copyWith(output: formatted, error: error);
  }

  String _formatSql(String input) {
    return SqlFormatter.format(input, indentWidth: state.indentWidth);
  }
}

import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dart_style/dart_style.dart';
import 'package:xml/xml.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_writer/yaml_writer.dart';
import '../beautifier_plugin.dart';
import '../models/beautifier_state.dart';
import '../../../core/services/preferences_service.dart';

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
        case BeautifierLanguage.html:
          final document = XmlDocument.parse(input);
          formatted = document.toXmlString(pretty: true, indent: '  ');
          break;
        case BeautifierLanguage.yaml:
          final dynamic yamlMap = loadYaml(input);
          formatted = _yamlWriter.write(yamlMap);
          break;
        default:
          formatted = _simpleFormat(input, state.language);
          break;
      }
    } catch (e) {
      error = 'Invalid ${state.language.label} format';
      formatted = 'ERROR: $error\n$e';
    }

    state = state.copyWith(output: formatted, error: error);
  }

  String _simpleFormat(String input, BeautifierLanguage lang) {
    int indent = 0;
    final lines = input.split('\n');
    final buffer = StringBuffer();

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('}') ||
          line.startsWith(']') ||
          line.startsWith('</')) {
        indent = (indent - 1).clamp(0, 20);
      }

      buffer.writeln('  ' * indent + line);

      if (line.endsWith('{') ||
          line.endsWith('[') ||
          (line.contains('<') && !line.contains('</') && line.contains('>')) ||
          (lang == BeautifierLanguage.sql &&
              (line.endsWith(';') || line.contains('SELECT')))) {
        // Very basic SQL nudge
        if (line.endsWith('{') || line.endsWith('[')) indent++;
      }
    }
    return buffer.toString().trim();
  }
}

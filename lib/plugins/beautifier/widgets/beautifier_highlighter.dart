import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:highlight/highlight.dart' show highlight, Node;
import 'package:highlight/languages/json.dart' as hl_json;
import 'package:highlight/languages/dart.dart' as hl_dart;
import 'package:highlight/languages/xml.dart' as hl_xml;
import 'package:highlight/languages/sql.dart' as hl_sql;
import 'package:highlight/languages/yaml.dart' as hl_yaml;
import 'package:highlight/languages/javascript.dart' as hl_javascript;
import 'package:highlight/languages/css.dart' as hl_css;

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

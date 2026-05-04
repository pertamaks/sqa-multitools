import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../security_payload_models.dart';

class PayloadParser {
  static List<PayloadCategory> parse(String rawMarkdown) {
    final List<PayloadCategory> categories = [];
    final lines = rawMarkdown.split(RegExp(r'\r?\n'));

    String? currentCategoryName;
    List<String> currentCategoryLines = [];

    void flushCategory() {
      if (currentCategoryName != null) {
        final content = currentCategoryLines.join('\n');
        categories.add(
          PayloadCategory(
            name: currentCategoryName,
            description: _extractDescription(content),
            icon: _getCategoryIcon(currentCategoryName),
            sections: _parseSections(content),
          ),
        );
      }
    }

    bool isInCodeBlock = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('```')) {
        isInCodeBlock = !isInCodeBlock;
      }

      if (!isInCodeBlock && line.startsWith('# ')) {
        flushCategory();
        currentCategoryName = line.substring(2).trim();
        currentCategoryLines = [];
      } else {
        currentCategoryLines.add(line);
      }
    }
    flushCategory();

    return categories;
  }

  static String _extractDescription(String content) {
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && !trimmed.startsWith('#')) {
        return trimmed;
      }
    }
    return '';
  }

  static List<PayloadSection> _parseSections(String content) {
    final List<PayloadSection> sections = [];
    final lines = content.split('\n');

    String? currentSectionTitle;
    List<String> currentSectionLines = [];

    void flushSection() {
      if (currentSectionTitle != null) {
        final sectionMarkdown = currentSectionLines.join('\n');
        final structured = _tryParseTable(sectionMarkdown);

        sections.add(
          PayloadSection(
            id: currentSectionTitle.toLowerCase().replaceAll(
              RegExp(r'[^a-z0-9]'),
              '_',
            ),
            title: currentSectionTitle,
            icon: _getSectionIcon(currentSectionTitle),
            markdown: '\n\n${sectionMarkdown.trimRight()}\n\n',
            structuredPayloads: structured,
          ),
        );
      }
    }

    bool isInCodeBlock = false;
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('```')) {
        isInCodeBlock = !isInCodeBlock;
      }

      if (!isInCodeBlock && line.startsWith('## ')) {
        flushSection();
        currentSectionTitle = line.substring(3).trim();
        currentSectionLines = [];
      } else {
        currentSectionLines.add(line);
      }
    }
    flushSection();

    return sections;
  }

  static List<SecurityPayload>? _tryParseTable(String markdown) {
    final lines = markdown.split('\n');
    final List<SecurityPayload> payloads = [];

    bool tableHeaderFound = false;
    bool separatorFound = false;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      if (line.startsWith('|') && line.toLowerCase().contains('| payload |')) {
        tableHeaderFound = true;
        continue;
      }

      if (tableHeaderFound &&
          !separatorFound &&
          line.startsWith('|') &&
          line.contains('---')) {
        separatorFound = true;
        continue;
      }

      if (tableHeaderFound && separatorFound && line.startsWith('|')) {
        // Remove the empty parts from split results if they are just the outer pipes
        final filtered = line.split('|').map((e) => e.trim()).toList();

        // Remove first and last if they are empty (from the outer |)
        if (filtered.first.isEmpty) filtered.removeAt(0);
        if (filtered.last.isEmpty) filtered.removeLast();

        if (filtered.length >= 6) {
          payloads.add(
            SecurityPayload(
              name: filtered[0].replaceAll('**', ''),
              payload: filtered[1].replaceAll('`', ''),
              description: filtered[2],
              howToTest: filtered[3],
              successIndicator: filtered[4],
              risk: PayloadRisk.fromString(filtered[5]),
            ),
          );
        }
      }
    }

    return payloads.isEmpty ? null : payloads;
  }

  static IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('web')) return Symbols.language;
    if (lower.contains('system')) return Symbols.terminal;
    if (lower.contains('auth')) return Symbols.lock;
    if (lower.contains('inject')) return Symbols.database;
    if (lower.contains('risk')) return Symbols.legend_toggle;
    return Symbols.category;
  }

  static IconData _getSectionIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('sql')) return Symbols.database;
    if (lower.contains('xss')) return Symbols.code;
    if (lower.contains('csrf')) return Symbols.security_update_warning;
    if (lower.contains('xxe')) return Symbols.article;
    if (lower.contains('command')) return Symbols.terminal;
    if (lower.contains('path') || lower.contains('traversal')) {
      return Symbols.folder_open;
    }
    if (lower.contains('ssrf')) return Symbols.public;
    if (lower.contains('upload')) return Symbols.upload_file;
    if (lower.contains('jwt')) return Symbols.key;
    if (lower.contains('fuzz')) return Symbols.cyclone;
    return Symbols.label;
  }
}

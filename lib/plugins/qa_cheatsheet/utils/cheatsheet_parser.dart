import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/cheatsheet_models.dart';

class CheatsheetParser {
  static List<CheatsheetCategory> parse(String rawMarkdown) {
    final List<CheatsheetCategory> categories = [];
    final lines = rawMarkdown.split(RegExp(r'\r?\n'));
    
    String? currentCategoryName;
    List<String> currentCategoryLines = [];

    void flushCategory() {
      if (currentCategoryName != null) {
        final content = currentCategoryLines.join('\n');
        categories.add(CheatsheetCategory(
          name: currentCategoryName,
          description: _extractDescription(content),
          icon: _getCategoryIcon(currentCategoryName),
          sections: _parseSections(content),
        ));
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

  static List<CheatsheetSection> _parseSections(String content) {
    final List<CheatsheetSection> sections = [];
    final lines = content.split('\n');
    
    String? currentSectionTitle;
    List<String> currentSectionLines = [];

    void flushSection() {
      if (currentSectionTitle != null) {
        sections.add(CheatsheetSection(
          id: currentSectionTitle.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
          title: currentSectionTitle,
          icon: _getSectionIcon(currentSectionTitle),
          markdown: '\n\n${currentSectionLines.join('\n').trimRight()}\n\n',
        ));
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

  static IconData _getCategoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('fundament')) return Symbols.school;
    if (lower.contains('tech')) return Symbols.terminal;
    if (lower.contains('strat')) return Symbols.strategy;
    return Symbols.category;
  }

  static IconData _getSectionIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('type')) return Symbols.checklist;
    if (lower.contains('bug')) return Symbols.pest_control;
    if (lower.contains('sever')) return Symbols.grid_view;
    if (lower.contains('test case')) return Symbols.article;
    if (lower.contains('http')) return Symbols.http;
    if (lower.contains('sql')) return Symbols.database;
    if (lower.contains('git')) return Symbols.commit;
    if (lower.contains('linux')) return Symbols.terminal;
    if (lower.contains('api')) return Symbols.api;
    if (lower.contains('mobile')) return Symbols.smartphone;
    if (lower.contains('a11y')) return Symbols.accessibility;
    if (lower.contains('automation')) return Symbols.smart_toy;
    if (lower.contains('pom')) return Symbols.frame_inspect;
    return Symbols.label;
  }
}

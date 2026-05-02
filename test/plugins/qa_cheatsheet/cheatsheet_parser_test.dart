import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/plugins/qa_cheatsheet/utils/cheatsheet_parser.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('CheatsheetParser', () {
    test('parse correctly extracts categories and sections', () {
      const rawMarkdown = '''
# Fundamentals
This is the description for fundamentals.

## Test Types
Markdown content for test types.

## Bug Reporting
Markdown content for bug reporting.

# Technical Skills
Description for technical.

## SQL Basics
Markdown content for SQL.
''';

      final categories = CheatsheetParser.parse(rawMarkdown);

      expect(categories.length, 2);
      
      expect(categories[0].name, 'Fundamentals');
      expect(categories[0].description, 'This is the description for fundamentals.');
      expect(categories[0].icon, Symbols.school);
      expect(categories[0].sections.length, 2);
      expect(categories[0].sections[0].title, 'Test Types');
      expect(categories[0].sections[1].title, 'Bug Reporting');

      expect(categories[1].name, 'Technical Skills');
      expect(categories[1].icon, Symbols.terminal);
      expect(categories[1].sections.length, 1);
      expect(categories[1].sections[0].title, 'SQL Basics');
    });

    test('parse handles code blocks correctly without breaking headers', () {
      const rawMarkdown = '''
# Category 1
Description.

## Section 1
```
# This is NOT a category header
## This is NOT a section header
```
''';

      final categories = CheatsheetParser.parse(rawMarkdown);

      expect(categories.length, 1);
      expect(categories[0].sections.length, 1);
      expect(categories[0].sections[0].markdown, contains('# This is NOT a category header'));
    });

    test('extracts correct icons for various keywords', () {
      expect(CheatsheetParser.parse('# Strategy\n## API Testing')[0].icon, Symbols.strategy);
      expect(CheatsheetParser.parse('# Strategy\n## API Testing')[0].sections[0].icon, Symbols.api);
      
      final sqlCat = CheatsheetParser.parse('# Tech\n## SQL Queries');
      expect(sqlCat[0].sections[0].icon, Symbols.database);

      final automationCat = CheatsheetParser.parse('# Tech\n## Automation');
      expect(automationCat[0].sections[0].icon, Symbols.smart_toy);
    });

    test('handles empty or malformed markdown gracefully', () {
      expect(CheatsheetParser.parse(''), isEmpty);
      expect(CheatsheetParser.parse('Just some text'), isEmpty);
    });
  });
}

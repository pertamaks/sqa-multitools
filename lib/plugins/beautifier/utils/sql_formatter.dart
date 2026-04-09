class SqlFormatter {
  static String format(String sql, {int indentWidth = 2}) {
    final tokens = _tokenize(sql);
    if (tokens.isEmpty) return '';

    final buffer = StringBuffer();
    int indentLevel = 0;
    int clauseLevelIndent = 0;
    bool isFirstInStatement = true;

    // Keywords logic
    final majorClauses = {
      'SELECT',
      'FROM',
      'WHERE',
      'GROUP BY',
      'ORDER BY',
      'HAVING',
      'LIMIT',
      'INSERT INTO',
      'VALUES',
      'UPDATE',
      'SET',
      'DELETE FROM',
      'CREATE TABLE',
      'JOIN',
      'LEFT JOIN',
      'RIGHT JOIN',
      'INNER JOIN',
    };

    final subClauses = {'AND', 'OR', 'ON'};

    String? currentClause;

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final rawValue = token.value.toUpperCase();
      final next = (i + 1 < tokens.length) ? tokens[i + 1] : null;

      // Helper to add space if needed
      void writeWithSpace(String val, {bool forceNoSpace = false}) {
        buffer.write(val);
        if (forceNoSpace) return;
        if (next == null) return;
        final nVal = next.value;
        if (nVal == ',' || nVal == ';' || nVal == '(' || nVal == ')') return;
        buffer.write(' ');
      }

      // 1. Handle Semicolon (Statement End)
      if (token.type == _TokenType.punctuation && token.value == ';') {
        buffer.write(';');
        buffer.writeln();
        buffer.writeln(); // Double space between statements
        indentLevel = 0;
        clauseLevelIndent = 0;
        isFirstInStatement = true;
        currentClause = null;
        continue;
      }

      // 2. Handle Parentheses (Indentation)
      if (token.type == _TokenType.punctuation && token.value == '(') {
        if (indentLevel == 0 &&
            (currentClause == 'VALUES' || currentClause == 'CREATE TABLE')) {
          buffer.writeln();
          buffer.write(' ' * indentWidth * (indentLevel + clauseLevelIndent));
        }
        buffer.write('(');
        indentLevel++;
        if (indentLevel == 1 && currentClause == 'CREATE TABLE') {
          buffer.writeln();
          buffer.write(' ' * indentWidth * indentLevel);
        }
        continue;
      }

      if (token.type == _TokenType.punctuation && token.value == ')') {
        indentLevel = (indentLevel - 1).clamp(0, 10);
        if (indentLevel == 0 && currentClause == 'CREATE TABLE') {
          buffer.writeln();
          buffer.write(' ' * indentWidth * (indentLevel + clauseLevelIndent));
        }
        writeWithSpace(')');
        continue;
      }

      // 3. Handle Commas (New Lines in specific contexts)
      if (token.type == _TokenType.punctuation && token.value == ',') {
        buffer.write(',');
        bool shouldSplit = false;
        if (currentClause == 'SELECT' && indentLevel == 0) shouldSplit = true;
        if (currentClause == 'CREATE TABLE' && indentLevel == 1) {
          shouldSplit = true;
        }
        if (currentClause == 'VALUES' && indentLevel == 0) shouldSplit = true;

        if (shouldSplit) {
          buffer.writeln();
          buffer.write(' ' * indentWidth * (indentLevel + clauseLevelIndent));
        } else {
          buffer.write(' ');
        }
        continue;
      }

      // 4. Handle Keywords
      if (token.type == _TokenType.keyword) {
        if (majorClauses.contains(rawValue)) {
          if (!isFirstInStatement) {
            buffer.writeln();
          }
          currentClause = rawValue;
          buffer.writeln(rawValue);
          clauseLevelIndent = 1; // Content under clause is indented
          isFirstInStatement = false;
          buffer.write(' ' * indentWidth * (indentLevel + clauseLevelIndent));
          continue;
        }

        if (subClauses.contains(rawValue)) {
          buffer.writeln();
          buffer.write(' ' * indentWidth * (indentLevel + clauseLevelIndent));
          buffer.write('  '); // Extra nudge for sub-keywords
          writeWithSpace(rawValue);
          continue;
        }

        // Generic keyword
        writeWithSpace(rawValue);
        continue;
      }

      // 5. Default: Identifiers, Strings, etc.
      writeWithSpace(token.value, forceNoSpace: token.value == '(');
    }

    return _cleanup(buffer.toString(), indentWidth);
  }

  static List<_Token> _tokenize(String sql) {
    // Regex covers: Strings, Decimals/hex, Keywords/Identifiers, Punctuation/Operators
    final regex = RegExp(
      r"('(?:''|[^'])*')|" // 1: String literals
      r"(\b(?:SELECT|FROM|WHERE|GROUP BY|ORDER BY|HAVING|LIMIT|INSERT INTO|VALUES|UPDATE|SET|DELETE FROM|CREATE TABLE|JOIN|LEFT JOIN|RIGHT JOIN|INNER JOIN|AND|OR|ON|AS|IN|IS|NULL|NOT|INT|VARCHAR|DECIMAL|PRIMARY KEY|PRIMARY|KEY|REFERENCES|DEFAULT|SERIAL|DATE|CURRENT_DATE|DESC|SUM|COUNT)\b)|" // 2: Keywords
      r"(\b[a-zA-Z_][a-zA-Z0-9_]*\b)|" // 3: Identifiers
      r"(\d+(?:\.\d*)?)|" // 4: Numbers
      r"([(),;])|" // 5: Punctuation
      r"([<>!=]=?|[-+*/%])|" // 6: Operators
      r"(\s+)", // 7: Whitespace
      caseSensitive: false,
      multiLine: true,
    );

    final List<_Token> tokens = [];
    final Iterable<RegExpMatch> matches = regex.allMatches(sql);

    for (final m in matches) {
      if (m.group(1) != null) {
        tokens.add(_Token(_TokenType.string, m.group(1)!));
      } else if (m.group(2) != null) {
        tokens.add(_Token(_TokenType.keyword, m.group(2)!));
      } else if (m.group(3) != null) {
        tokens.add(_Token(_TokenType.identifier, m.group(3)!));
      } else if (m.group(4) != null) {
        tokens.add(_Token(_TokenType.number, m.group(4)!));
      } else if (m.group(5) != null) {
        tokens.add(_Token(_TokenType.punctuation, m.group(5)!));
      } else if (m.group(6) != null) {
        tokens.add(_Token(_TokenType.operator, m.group(6)!));
      }
    }

    return tokens;
  }

  static String _cleanup(String sql, int indentWidth) {
    // Final pass to trim lines and handle excessive spacing
    return sql
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.isNotEmpty)
        .join('\n')
        .trim();
  }
}

enum _TokenType { keyword, identifier, string, number, punctuation, operator }

class _Token {
  final _TokenType type;
  final String value;
  _Token(this.type, this.value);
}

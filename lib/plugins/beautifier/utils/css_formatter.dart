class CssFormatter {
  static String format(String css, {int indentWidth = 2}) {
    final tokens = _tokenize(css);
    final buffer = StringBuffer();
    int depth = 0;
    int parenDepth = 0;

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final prev = i > 0 ? tokens[i - 1] : null;
      final next = i < tokens.length - 1 ? tokens[i + 1] : null;

      if (token.type == _TokenType.comment) {
        if (buffer.isNotEmpty && !buffer.toString().endsWith('\n')) {
          buffer.write(' ');
        }
        buffer.writeln(token.value);
        if (next != null) buffer.write(' ' * depth * indentWidth);
        continue;
      }

      if (token.value == '{') {
        _removeTrailingSpace(buffer);
        buffer.write(' {');
        buffer.writeln();
        depth++;
        buffer.write(' ' * depth * indentWidth);
      } else if (token.value == '}') {
        // Ensure last property has semicolon
        final prevContent = buffer.toString().trimRight();
        if (depth > 0 &&
            prevContent.isNotEmpty &&
            !prevContent.endsWith(';') &&
            !prevContent.endsWith('{') &&
            !prevContent.endsWith('}')) {
          _removeTrailingSpace(buffer);
          buffer.write(';');
        }

        depth--;
        _trimTrailingSpace(buffer);
        if (!buffer.toString().endsWith('\n')) buffer.writeln();
        buffer.write(' ' * depth * indentWidth);
        buffer.write('}');
        if (next != null) {
          buffer.writeln();
          buffer.write(' ' * depth * indentWidth);
          // Add extra newline between top-level rules for better readability
          if (depth == 0) {
            buffer.writeln();
          }
        }
      } else if (token.value == '(') {
        if (prev != null && prev.value.startsWith('@')) {
          buffer.write(' ');
        }
        buffer.write('(');
        parenDepth++;
      } else if (token.value == ')') {
        parenDepth--;
        buffer.write(')');
      } else if (token.value == ';') {
        _removeTrailingSpace(buffer);
        buffer.write(';');
        if (next != null && next.value != '}') {
          buffer.writeln();
          buffer.write(' ' * depth * indentWidth);
        }
      } else if (token.value == ':') {
        _removeTrailingSpace(buffer);
        // Colons in declarations or media query features should have spaces
        bool isProperty = (depth > 0 || parenDepth > 0);

        // Pseudo-classes heuristic: colon followed by word then '{' or another selector char
        if (next != null && next.value == '{') isProperty = false;
        if (i + 2 < tokens.length && tokens[i + 2].value == '{') isProperty = false;

        if (isProperty) {
          buffer.write(': ');
        } else {
          buffer.write(':');
        }
      } else if (token.value == ',') {
        _removeTrailingSpace(buffer);
        buffer.write(', ');
      } else {
        // Selector or Value
        if (prev != null && _needsSpaceBetween(prev, token)) {
          if (!buffer.toString().endsWith(' ') &&
              !buffer.toString().endsWith('\n')) {
            buffer.write(' ');
          }
        }
        buffer.write(token.value);
      }
    }

    return buffer.toString().trim();
  }

  static void _removeTrailingSpace(StringBuffer buffer) {
    String content = buffer.toString();
    if (content.endsWith(' ')) {
      final trimmed = content.substring(0, content.length - 1);
      buffer.clear();
      buffer.write(trimmed);
    }
  }

  static void _trimTrailingSpace(StringBuffer buffer) {
    String content = buffer.toString();
    String trimmed = content.trimRight();
    buffer.clear();
    buffer.write(trimmed);
  }

  static bool _needsSpaceBetween(_Token prev, _Token current) {
    // Space before {
    if (current.value == '{') return true;
    
    // Avoid space after dot, hash, etc. in selectors
    if (prev.value == '.' || prev.value == '#' || prev.value == '[' || prev.value == '(' || prev.value == '@') return false;
    if (current.value == '.' || current.value == '#' || current.value == '[' || current.value == ']' || current.value == ')' || current.value == '(') return false;
    
    // Space around combinators
    if (current.value == '>' || current.value == '+' || current.value == '~') return true;
    if (prev.value == '>' || prev.value == '+' || prev.value == '~') return true;

    // Word/Keyword/String spacing (e.g. margin: 0 0 10px)
    if (prev.type == _TokenType.word && current.type == _TokenType.word) return true;
    if (prev.type == _TokenType.string || current.type == _TokenType.string) return true;
    
    return false;
  }

  static List<_Token> _tokenize(String css) {
    final tokens = <_Token>[];
    int i = 0;

    while (i < css.length) {
      final char = css[i];

      // Skip whitespace
      if (RegExp(r'\s').hasMatch(char)) {
        i++;
        continue;
      }

      // Strings (including quotes)
      if (char == "'" || char == '"') {
        final start = i;
        final quote = char;
        i++;
        while (i < css.length) {
          if (jsEscape(css, i)) {
            i += 2;
          } else if (css[i] == quote) {
            i++;
            break;
          } else {
            i++;
          }
        }
        tokens.add(_Token(_TokenType.string, css.substring(start, i)));
        continue;
      }

      // Comments /* */
      if (char == '/' && i + 1 < css.length && css[i + 1] == '*') {
        final start = i;
        i += 2;
        while (i + 1 < css.length && !(css[i] == '*' && css[i + 1] == '/')) {
          i++;
        }
        i += 2;
        tokens.add(_Token(_TokenType.comment, css.substring(start, i)));
        continue;
      }

      // Suffix combinators and other punctuation
      if ('{}()[].,;:>+~'.contains(char)) {
        tokens.add(_Token(_TokenType.punctuation, char));
        i++;
        continue;
      }

      // Identifiers/Words/Numbers (including dashes, underscores, @, #, and .)
      final start = i;
      // . and # are only part of word if they start the token (for numbers or selectors)
      if (char == '.' || char == '#' || char == '@') {
        i++;
      }
      
      while (i < css.length && RegExp(r'[a-zA-Z0-9\-_%.]').hasMatch(css[i])) {
        // Only one dot allowed (for numbers), but in selectors multiple dots are separate
        // This is a simple lexer, so we just consume until we hit punctuation or whitespace
        i++;
      }
      
      if (i > start) {
        tokens.add(_Token(_TokenType.word, css.substring(start, i)));
        continue;
      }

    }

    return tokens;
  }

  static bool jsEscape(String s, int i) => i + 1 < s.length && s[i] == '\\';
}

enum _TokenType { word, punctuation, comment, string }

class _Token {
  final _TokenType type;
  final String value;
  _Token(this.type, this.value);
}

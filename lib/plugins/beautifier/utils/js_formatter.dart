class JsFormatter {
  static String format(String js, {int indentWidth = 2}) {
    final tokens = _tokenize(js);
    final buffer = StringBuffer();
    int depth = 0;
    bool inFor = false;
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
        if (prev != null &&
            prev.value != ' ' &&
            !buffer.toString().endsWith(' ') &&
            !buffer.toString().endsWith('\n')) {
          buffer.write(' ');
        }
        buffer.writeln('{');
        depth++;
        buffer.write(' ' * depth * indentWidth);
      } else if (token.value == '}') {
        depth--;
        _trimTrailingSpace(buffer);
        if (!buffer.toString().endsWith('\n')) buffer.writeln();
        buffer.write(' ' * depth * indentWidth);
        buffer.write('}');
        if (next != null &&
            next.value != ';' &&
            next.value != ',' &&
            next.value != ')' &&
            next.value != ']' &&
            next.value != '.') {
          buffer.writeln();
          buffer.write(' ' * depth * indentWidth);
        }
      } else if (token.value == ';') {
        _removeTrailingSpace(buffer);
        buffer.write(';');
        if (!inFor) {
          buffer.writeln();
          if (next != null && next.value != '}') {
            buffer.write(' ' * depth * indentWidth);
          }
        } else {
          buffer.write(' ');
        }
      } else if (token.value == ',') {
        _removeTrailingSpace(buffer);
        buffer.write(',');
        if (depth > 0 && parenDepth == 0 && !inFor) {
          buffer.writeln();
          buffer.write(' ' * depth * indentWidth);
        } else {
          buffer.write(' ');
        }
      } else if (token.value == 'for') {
        buffer.write('for ');
        inFor = true;
      } else if (token.value == '(') {
        if (prev != null) {
           final keywords = {'if', 'for', 'while', 'switch', 'catch', 'function'};
           if (!keywords.contains(prev.value)) {
             _removeTrailingSpace(buffer);
           }
        }
        parenDepth++;
        buffer.write('(');
      } else if (token.value == ')') {
        parenDepth--;
        if (parenDepth == 0) inFor = false;
        _removeTrailingSpace(buffer);
        buffer.write(')');
      } else if (token.value == ':') {
        _removeTrailingSpace(buffer);
        buffer.write(': ');
      } else if (token.value == '++' || token.value == '--') {
         _removeTrailingSpace(buffer);
         buffer.write(token.value);
      } else {
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
    if (current.value == '.' || prev.value == '.') return false;
    if ('{}()[].,;:?!'.contains(current.value)) return false;
    if ('{}()[].,;:!'.contains(prev.value)) return false;
    if (current.value == '++' || current.value == '--') return false;

    final keywords = {
      'const', 'let', 'var', 'function', 'class', 'static', 'return',
      'if', 'else', 'while', 'do', 'import', 'export', 'from', 'as',
      'new', 'throw', 'case', 'yield', 'await', 'async'
    };

    if (keywords.contains(prev.value)) return true;
    if (_isOperator(prev.value) || _isOperator(current.value)) return true;
    if (prev.type == _TokenType.word && current.type == _TokenType.word) return true;

    return false;
  }

  static bool _isOperator(String val) {
    return const [
      '=', '=>', '+', '-', '*', '/', '>', '<', '>=', '<=', '==', '===', '!=',
      '!==', '&&', '||', '?', '...', '+=', '-=', '*=', '/='
    ].contains(val);
  }

  static List<_Token> _tokenize(String js) {
    final tokens = <_Token>[];
    int i = 0;
    while (i < js.length) {
      final char = js[i];
      if (RegExp(r'\s').hasMatch(char)) {
        i++;
        continue;
      }
      if (char == "'" || char == '"' || char == '`') {
        final start = i;
        final quote = char;
        i++;
        while (i < js.length) {
          if (js[i] == '\\') {
            i += 2;
          } else if (js[i] == quote) {
            i++;
            break;
          } else {
            i++;
          }
        }
        tokens.add(_Token(_TokenType.string, js.substring(start, i)));
        continue;
      }
      if (char == '/' && i + 1 < js.length) {
        if (js[i + 1] == '/') {
          final start = i;
          while (i < js.length && js[i] != '\n') {
            i++;
          }
          tokens.add(_Token(_TokenType.comment, js.substring(start, i)));
          continue;
        } else if (js[i + 1] == '*') {
          final start = i;
          i += 2;
          while (i + 1 < js.length && !(js[i] == '*' && js[i + 1] == '/')) {
            i++;
          }
          i += 2;
          tokens.add(_Token(_TokenType.comment, js.substring(start, i)));
          continue;
        }
      }
      final next2 = i + 2 < js.length ? js.substring(i, i + 3) : '';
      if (['===', '!==', '...'].contains(next2)) {
        tokens.add(_Token(_TokenType.operator, next2));
        i += 3;
        continue;
      }
      final next1 = i + 1 < js.length ? js.substring(i, i + 2) : '';
      if (['++', '--', '=>', '==', '!=', '>=', '<=', '&&', '||', '+=', '-=', '*=', '/=']
          .contains(next1)) {
        tokens.add(_Token(_TokenType.operator, next1));
        i += 2;
        continue;
      }
      if ('{}()[].,;:?'.contains(char)) {
        tokens.add(_Token(_TokenType.punctuation, char));
        i++;
        continue;
      }
      final start = i;
      while (i < js.length && RegExp(r'[a-zA-Z0-9_$]').hasMatch(js[i])) {
        i++;
      }
      if (i > start) {
        tokens.add(_Token(_TokenType.word, js.substring(start, i)));
        continue;
      }
      tokens.add(_Token(_TokenType.operator, char));
      i++;
    }
    return tokens;
  }
}

enum _TokenType { word, punctuation, operator, string, comment }

class _Token {
  final _TokenType type;
  final String value;
  _Token(this.type, this.value);
}

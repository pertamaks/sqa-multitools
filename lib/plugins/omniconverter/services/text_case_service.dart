class TextCaseService {
  const TextCaseService();

  List<String> _extractWords(String text) {
    if (text.trim().isEmpty) return [];
    // Handles camelCase, PascalCase, snake_case, kebab-case, and spaces
    final exp = RegExp(r'[A-Za-z0-9]+(?=[A-Z][a-z0-9]|\b)|[A-Za-z0-9]+');
    final matches = exp.allMatches(text);
    return matches.map((m) => m.group(0)!).toList();
  }

  String toCamelCase(String text) {
    final words = _extractWords(text);
    if (words.isEmpty) return '';
    final buffer = StringBuffer(words.first.toLowerCase());
    for (var i = 1; i < words.length; i++) {
      final w = words[i].toLowerCase();
      if (w.isNotEmpty) {
        buffer.write(w[0].toUpperCase() + w.substring(1));
      }
    }
    return buffer.toString();
  }

  String toPascalCase(String text) {
    final words = _extractWords(text);
    if (words.isEmpty) return '';
    final buffer = StringBuffer();
    for (final w in words) {
      final lower = w.toLowerCase();
      if (lower.isNotEmpty) {
        buffer.write(lower[0].toUpperCase() + lower.substring(1));
      }
    }
    return buffer.toString();
  }

  String toSnakeCase(String text) {
    final words = _extractWords(text);
    return words.map((w) => w.toLowerCase()).join('_');
  }

  String toKebabCase(String text) {
    final words = _extractWords(text);
    return words.map((w) => w.toLowerCase()).join('-');
  }

  String toConstantCase(String text) {
    final words = _extractWords(text);
    return words.map((w) => w.toUpperCase()).join('_');
  }

  String toTitleCase(String text) {
    final words = _extractWords(text);
    return words
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '')
        .join(' ');
  }

  String cleanDuplicateLines(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    final seen = <String>{};
    final result = <String>[];
    for (final line in lines) {
      if (seen.add(line)) {
        result.add(line);
      }
    }
    return result.join('\n');
  }

  String sortLines(String text, {bool ascending = true}) {
    final lines = text.split(RegExp(r'\r?\n'));
    lines.sort((a, b) => ascending ? a.compareTo(b) : b.compareTo(a));
    return lines.join('\n');
  }

  String trimLines(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    return lines.map((l) => l.trim()).join('\n');
  }
}

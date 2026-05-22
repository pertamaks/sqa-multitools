class VariantResolver {
  static List<String> _splitIntoWords(String text) {
    final clean = text
        .replaceAllMapped(
          RegExp(r'([a-z0-9])([A-Z])'),
          (m) => '${m.group(1)} ${m.group(2)}',
        )
        .replaceAllMapped(
          RegExp(r'([A-Z])([A-Z][a-z])'),
          (m) => '${m.group(1)} ${m.group(2)}',
        )
        .replaceAll(RegExp(r'[-_\s]+'), ' ')
        .trim();
    if (clean.isEmpty) return [text];
    return clean.split(' ');
  }

  static String _capitalize(String word) {
    if (word.isEmpty) return '';
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }

  static Map<String, String> generateVariants(
    String original,
    String replacement,
  ) {
    if (original.isEmpty || replacement.isEmpty) return {};

    final origWords = _splitIntoWords(original);
    final repWords = _splitIntoWords(replacement);

    String toPascal(List<String> words) => words.map(_capitalize).join();

    String toCamel(List<String> words) {
      if (words.isEmpty) return '';
      return words[0].toLowerCase() + words.skip(1).map(_capitalize).join();
    }

    String toSnake(List<String> words) =>
        words.map((w) => w.toLowerCase()).join('_');

    String toScreamingSnake(List<String> words) =>
        words.map((w) => w.toUpperCase()).join('_');

    String toKebab(List<String> words) =>
        words.map((w) => w.toLowerCase()).join('-');

    String toSpace(List<String> words) =>
        words.map((w) => w.toLowerCase()).join(' ');

    final Map<String, String> variants = {
      original: replacement,
      original.toLowerCase(): replacement.toLowerCase(),
      original.toUpperCase(): replacement.toUpperCase(),
      toPascal(origWords): toPascal(repWords),
      toCamel(origWords): toCamel(repWords),
      toSnake(origWords): toSnake(repWords),
      toScreamingSnake(origWords): toScreamingSnake(repWords),
      toKebab(origWords): toKebab(repWords),
      toSpace(origWords): toSpace(repWords),
    };

    // Filter out entries where key is identical to original or empty
    variants.removeWhere((key, value) => key == original || key.isEmpty);

    return variants;
  }
}

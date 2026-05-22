import '../models/dictionary_entry.dart';

class MatchResult {
  final int start;
  final int end;
  final String matchedText;
  final String replacementText;
  final DictionaryEntry entry;

  MatchResult({
    required this.start,
    required this.end,
    required this.matchedText,
    required this.replacementText,
    required this.entry,
  });
}

class SubstitutionEngine {
  /// Obfuscates the text by replacing all matched dictionary entries and their casing variants.
  /// Employs a single-pass, position-based replacement strategy to prevent nested replacements or partial overrides.
  static String obfuscate(String text, List<DictionaryEntry> entries) {
    if (entries.isEmpty || text.isEmpty) return text;

    final matches = findMatches(text, entries);
    if (matches.isEmpty) return text;

    final buffer = StringBuffer();
    var lastIndex = 0;

    for (final match in matches) {
      buffer.write(text.substring(lastIndex, match.start));
      buffer.write(match.replacementText);
      lastIndex = match.end;
    }
    buffer.write(text.substring(lastIndex));

    return buffer.toString();
  }

  /// De-obfuscates the text by restoring obfuscated placeholders back to their original values.
  /// Employs a single-pass, position-based replacement strategy.
  static String deobfuscate(String text, List<DictionaryEntry> entries) {
    if (entries.isEmpty || text.isEmpty) return text;

    final activeEntries = entries.where((e) => e.enabled).toList();
    final List<_TermMatcher> matchers = [];

    for (final entry in activeEntries) {
      // Base replacement word is case-insensitive fallback
      matchers.add(
        _TermMatcher(
          original: entry.replacement,
          replacement: entry.original,
          entry: entry,
          caseSensitive: false,
        ),
      );

      // Casing variants are matched case-sensitively
      entry.variants.forEach((origVar, repVar) {
        if (repVar != entry.replacement) {
          matchers.add(
            _TermMatcher(
              original: repVar,
              replacement: origVar,
              entry: entry,
              caseSensitive: true,
            ),
          );
        }
      });
    }

    // Sort by length descending, and then by case sensitivity (true first)
    matchers.sort((a, b) {
      final lenComp = b.original.length.compareTo(a.original.length);
      if (lenComp != 0) return lenComp;
      if (a.caseSensitive && !b.caseSensitive) return -1;
      if (!a.caseSensitive && b.caseSensitive) return 1;
      return 0;
    });

    final matchedBytes = List<bool>.filled(text.length, false);
    final List<_DeobfuscateMatch> matches = [];

    for (final matcher in matchers) {
      final escaped = RegExp.escape(matcher.original);
      final startsWithAlphaNum = RegExp(r'^\w').hasMatch(matcher.original);
      final endsWithAlphaNum = RegExp(r'\w$').hasMatch(matcher.original);
      final pattern =
          '${startsWithAlphaNum ? r'\b' : ''}$escaped${endsWithAlphaNum ? r'\b' : ''}';

      final regex = RegExp(pattern, caseSensitive: matcher.caseSensitive);
      for (final match in regex.allMatches(text)) {
        final start = match.start;
        final end = match.end;

        var overlaps = false;
        for (var i = start; i < end; i++) {
          if (matchedBytes[i]) {
            overlaps = true;
            break;
          }
        }

        if (!overlaps) {
          for (var i = start; i < end; i++) {
            matchedBytes[i] = true;
          }
          matches.add(
            _DeobfuscateMatch(
              start: start,
              end: end,
              replacement: matcher.replacement,
            ),
          );
        }
      }
    }

    if (matches.isEmpty) return text;
    matches.sort((a, b) => a.start.compareTo(b.start));

    final buffer = StringBuffer();
    var lastIndex = 0;
    for (final match in matches) {
      buffer.write(text.substring(lastIndex, match.start));
      buffer.write(match.replacement);
      lastIndex = match.end;
    }
    buffer.write(text.substring(lastIndex));
    return buffer.toString();
  }

  /// Finds and maps the positions of all matches (original or casing variants) in the source text.
  /// Collisions and overlaps are avoided by scanning in a sorted longest-match-first sequence.
  static List<MatchResult> findMatches(
    String text,
    List<DictionaryEntry> entries,
  ) {
    if (entries.isEmpty || text.isEmpty) return [];

    final activeEntries = entries.where((e) => e.enabled).toList();
    final List<_TermMatcher> matchers = [];

    for (final entry in activeEntries) {
      matchers.add(
        _TermMatcher(
          original: entry.original,
          replacement: entry.replacement,
          entry: entry,
          caseSensitive: false,
        ),
      );

      entry.variants.forEach((origVar, repVar) {
        if (origVar != entry.original) {
          matchers.add(
            _TermMatcher(
              original: origVar,
              replacement: repVar,
              entry: entry,
              caseSensitive: true,
            ),
          );
        }
      });
    }

    // Sort by length descending, and then by case-sensitivity (true first)
    matchers.sort((a, b) {
      final lenComp = b.original.length.compareTo(a.original.length);
      if (lenComp != 0) return lenComp;
      if (a.caseSensitive && !b.caseSensitive) return -1;
      if (!a.caseSensitive && b.caseSensitive) return 1;
      return 0;
    });

    final List<MatchResult> results = [];
    final matchedBytes = List<bool>.filled(text.length, false);

    for (final matcher in matchers) {
      final escaped = RegExp.escape(matcher.original);
      final startsWithAlphaNum = RegExp(r'^\w').hasMatch(matcher.original);
      final endsWithAlphaNum = RegExp(r'\w$').hasMatch(matcher.original);
      final pattern =
          '${startsWithAlphaNum ? r'\b' : ''}$escaped${endsWithAlphaNum ? r'\b' : ''}';

      final regex = RegExp(pattern, caseSensitive: matcher.caseSensitive);
      for (final match in regex.allMatches(text)) {
        final start = match.start;
        final end = match.end;

        var overlaps = false;
        for (var i = start; i < end; i++) {
          if (matchedBytes[i]) {
            overlaps = true;
            break;
          }
        }

        if (!overlaps) {
          for (var i = start; i < end; i++) {
            matchedBytes[i] = true;
          }
          results.add(
            MatchResult(
              start: start,
              end: end,
              matchedText: match.group(0)!,
              replacementText: transferCasing(
                match.group(0)!,
                matcher.replacement,
              ),
              entry: matcher.entry,
            ),
          );
        }
      }
    }

    results.sort((a, b) => a.start.compareTo(b.start));
    return results;
  }

  /// Transfers the capitalization and character casing from a source word onto a target word.
  /// Handles TitleCase (e.g. Corn -> Dolor), UPPERCASE (e.g. REDIS -> PLUTO), lowercase (e.g. redis -> pluto),
  /// and mixed casing (e.g. deFiure -> inCidunt).
  static String transferCasing(String source, String target) {
    if (source.isEmpty || target.isEmpty) return target;

    // Check if source is all uppercase
    if (source == source.toUpperCase() && source != source.toLowerCase()) {
      return target.toUpperCase();
    }

    // Check if source is all lowercase
    if (source == source.toLowerCase() && source != source.toUpperCase()) {
      return target.toLowerCase();
    }

    // Helper: check if target is camelCased (has uppercase letter at index >= 1)
    final hasBodyUpper = target.substring(1).contains(RegExp(r'[A-Z]'));

    // Check if title case/capitalized (e.g. "Corn")
    final startsWithUpper =
        source[0] == source[0].toUpperCase() &&
        source[0] != source[0].toLowerCase();
    final remainingLower =
        source.substring(1) == source.substring(1).toLowerCase();
    if (startsWithUpper && remainingLower) {
      if (hasBodyUpper) {
        return target[0].toUpperCase() + target.substring(1);
      }
      return target[0].toUpperCase() + target.substring(1).toLowerCase();
    }

    // Mixed casing source (neither all-upper, all-lower, nor TitleCase)
    if (hasBodyUpper) {
      // Keep the target's existing camelCasing/PascalCasing, just match the first letter's casing
      final isFirstUpper =
          source[0] == source[0].toUpperCase() &&
          source[0] != source[0].toLowerCase();
      if (isFirstUpper) {
        return target[0].toUpperCase() + target.substring(1);
      } else {
        return target[0].toLowerCase() + target.substring(1);
      }
    }

    // If target is plain lowercase/word, transfer casing character-by-character
    final buffer = StringBuffer();
    for (var i = 0; i < target.length; i++) {
      if (i < source.length) {
        final sourceChar = source[i];
        final targetChar = target[i];
        if (sourceChar == sourceChar.toUpperCase() &&
            sourceChar != sourceChar.toLowerCase()) {
          buffer.write(targetChar.toUpperCase());
        } else if (sourceChar == sourceChar.toLowerCase() &&
            sourceChar != sourceChar.toUpperCase()) {
          buffer.write(targetChar.toLowerCase());
        } else {
          buffer.write(targetChar);
        }
      } else {
        final sourceChar = source[source.length - 1];
        final targetChar = target[i];
        if (sourceChar == sourceChar.toUpperCase() &&
            sourceChar != sourceChar.toLowerCase()) {
          buffer.write(targetChar.toUpperCase());
        } else {
          buffer.write(targetChar.toLowerCase());
        }
      }
    }
    return buffer.toString();
  }
}

class _TermMatcher {
  final String original;
  final String replacement;
  final DictionaryEntry entry;
  final bool caseSensitive;

  _TermMatcher({
    required this.original,
    required this.replacement,
    required this.entry,
    required this.caseSensitive,
  });
}

class _DeobfuscateMatch {
  final int start;
  final int end;
  final String replacement;

  _DeobfuscateMatch({
    required this.start,
    required this.end,
    required this.replacement,
  });
}

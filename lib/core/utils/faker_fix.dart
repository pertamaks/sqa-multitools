import 'dart:math';

/// A utility to sanitize output from [faker_dart] that might contain
/// unreplaced placeholders in some locales or versions.
class FakerFix {
  static final Random _random = Random();

  /// Replaces common faker placeholders that might be left behind:
  /// - '!' -> Random digit from 2 to 9
  /// - '#' -> Random digit from 0 to 9
  /// - '?' -> Random uppercase letter A-Z
  ///
  /// Set [includeExtension] to false to strip phone extensions like ' x123'.
  static String fix(String? input, {bool includeExtension = true}) {
    if (input == null || input.isEmpty) return '';

    // Step 0: Strip phone extensions if requested
    String result = input;
    if (!includeExtension) {
      // Strips " x123", " x5555", etc.
      result = result.replaceFirst(RegExp(r'\s+x\d+.*$'), '');
    }

    // Step 1: Replace ! (2-9)
    result = result.replaceAllMapped('!', (_) {
      return (2 + _random.nextInt(8)).toString();
    });

    // Step 2: Replace # (0-9)
    result = result.replaceAllMapped('#', (_) {
      return _random.nextInt(10).toString();
    });

    // Step 3: Replace ? (A-Z)
    result = result.replaceAllMapped('?', (_) {
      return String.fromCharCode(65 + _random.nextInt(26));
    });

    // Step 4: Deduplicate redundant patterns like "Name - Name" or "Name / Name"
    // This handles a bug in faker_dart 0.2.3's fake() interpolation engine
    // where it reuses the same value for the same placeholder.
    final duplicatePattern = RegExp(
      r'^(\w+)\s*[-\/]\s*\1(\b.*)$',
      dotAll: true,
    );
    if (duplicatePattern.hasMatch(result)) {
      result = result.replaceFirstMapped(duplicatePattern, (match) {
        return '${match.group(1)}${match.group(2)}';
      });
    }

    return result;
  }
}

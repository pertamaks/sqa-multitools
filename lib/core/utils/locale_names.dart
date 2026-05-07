/// A utility to map technical locale codes to human-friendly names.
class LocaleNames {
  /// A mapping of common locale codes from the `faker_dart` package
  /// to their user-friendly display names.
  static const Map<String, String> _friendlyNames = {
    // English
    'en': 'English',
    'en_US': 'English (US)',
    'en_GB': 'English (UK)',
    'en_AU': 'English (Australia)',
    'en_CA': 'English (Canada)',
    'en_IE': 'English (Ireland)',
    'en_IND': 'English (India)',
    'en_ZA': 'English (South Africa)',
    'en_BORK': 'Bork (Swedish Chef)',

    // European
    'fr': 'French',
    'fr_FR': 'French (France)',
    'fr_BE': 'French (Belgium)',
    'fr_CA': 'French (Canada)',
    'fr_CH': 'French (Switzerland)',
    'de': 'German',
    'de_DE': 'German (Germany)',
    'de_AT': 'German (Austria)',
    'de_CH': 'German (Switzerland)',
    'it': 'Italian',
    'it_IT': 'Italian (Italy)',
    'es': 'Spanish',
    'es_ES': 'Spanish (Spain)',
    'es_MX': 'Spanish (Mexico)',
    'pt_BR': 'Portuguese (Brazil)',
    'pt_PT': 'Portuguese (Portugal)',
    'nl': 'Dutch',
    'nl_BE': 'Dutch (Belgium)',
    'sv': 'Swedish',
    'pl': 'Polish',
    'ru': 'Russian',

    // Asian
    'id_ID': 'Indonesian',
    'ja': 'Japanese',
    'ko': 'Korean',
    'zh_CN': 'Chinese (Simplified)',
    'zh_TW': 'Chinese (Traditional)',
    'vi': 'Vietnamese',

    // Others
    'tr': 'Turkish',
    'ar': 'Arabic',
    'he': 'Hebrew',
    'fa': 'Persian',
  };

  /// Returns a human-friendly display name for the given locale [code].
  ///
  /// For known codes, it returns a detailed label (e.g. "English (US)").
  /// For unknown codes, it returns a cleaned-up version of the code
  /// (e.g. "az" -> "AZ", "foo_bar" -> "FOO BAR").
  static String getDisplayName(String code) {
    // 1. Check if we have a direct mapping
    if (_friendlyNames.containsKey(code)) {
      return _friendlyNames[code]!;
    }

    // 2. Automated fallback for unknown codes
    // "id_ID" -> "ID ID" -> "ID ID" (Uppercase)
    return code.replaceAll('_', ' ').toUpperCase();
  }
}

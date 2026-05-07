import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/core/utils/locale_names.dart';

void main() {
  group('LocaleNames Tests', () {
    test('returns friendly name for known codes', () {
      expect(LocaleNames.getDisplayName('en_US'), 'English (US)');
      expect(LocaleNames.getDisplayName('id_ID'), 'Indonesian');
      expect(LocaleNames.getDisplayName('ja'), 'Japanese');
      expect(LocaleNames.getDisplayName('en_BORK'), 'Bork (Swedish Chef)');
    });

    test('returns cleaned up uppercase for unknown codes', () {
      expect(LocaleNames.getDisplayName('az'), 'AZ');
      expect(LocaleNames.getDisplayName('foo_bar'), 'FOO BAR');
      expect(LocaleNames.getDisplayName('unknown'), 'UNKNOWN');
    });

    test('handles empty or null-like strings gracefully', () {
      expect(LocaleNames.getDisplayName(''), '');
    });
  });
}

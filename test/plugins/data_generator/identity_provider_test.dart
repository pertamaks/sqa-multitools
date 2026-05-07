import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/data_generator/models/identity_state.dart';
import 'package:sqa_multitools/plugins/data_generator/providers/identity_provider.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('IdentityProvider Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('initial state is correct', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(identityProvider);
      expect(state.resultsMap[IdentityType.email], isNull);
      expect(state.quantity, 1);
      expect(state.includeFormatting, isTrue); // Default should be true
    });

    test('toggle includeFormatting updates state', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(identityProvider.notifier);

      notifier.setIncludeFormatting(false);
      expect(container.read(identityProvider).includeFormatting, isFalse);

      notifier.setIncludeFormatting(true);
      expect(container.read(identityProvider).includeFormatting, isTrue);
    });

    test('setting quantity does not trigger generation (manual)', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(identityProvider.notifier);

      notifier.setQuantity(5);
      final state = container.read(identityProvider);
      expect(state.quantity, 5);
      expect(state.resultsMap[IdentityType.email], isNull);

      notifier.generate();
      expect(
        container.read(identityProvider).resultsMap[IdentityType.email]?.length,
        5,
      );
    });

    test('setting type does not trigger generation (manual)', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(identityProvider.notifier);

      notifier.setType(IdentityType.address);
      final state = container.read(identityProvider);
      expect(state.selectedType, IdentityType.address);
      expect(state.resultsMap[IdentityType.address], isNull);

      notifier.generate();
      expect(
        container
            .read(identityProvider)
            .resultsMap[IdentityType.address]
            ?.length,
        1,
      );
    });

    test('phone numbers do not contain placeholders', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(identityProvider.notifier);

      notifier.setType(IdentityType.phone);
      notifier.setQuantity(50);
      notifier.generate();

      final results =
          container.read(identityProvider).resultsMap[IdentityType.phone] ??
          <String>[];

      for (final String phone in results) {
        expect(phone.contains('!'), isFalse, reason: 'Phone $phone contains !');
        expect(phone.contains('#'), isFalse, reason: 'Phone $phone contains #');
      }
    });

    test('phone extensions can be toggled', () {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(identityProvider.notifier);

      notifier.setType(IdentityType.phone);

      // Test disabled (default)
      notifier.setIncludeExtension(false);
      notifier.generate();
      final results1 =
          container.read(identityProvider).resultsMap[IdentityType.phone] ??
          <String>[];

      for (final String phone in results1) {
        expect(
          phone.contains(' x'),
          isFalse,
          reason: 'Phone $phone should not have extension',
        );
      }

      // Test enabled (generate 100 to be sure we hit one with extension)
      notifier.setQuantity(100);
      notifier.setIncludeExtension(true);
      notifier.generate();

      final results2 =
          container.read(identityProvider).resultsMap[IdentityType.phone] ??
          <String>[];
      final hasExtension = results2.any((String phone) => phone.contains(' x'));
      expect(
        hasExtension,
        isTrue,
        reason: 'At least one phone should have an extension in 100 results',
      );
    });
  });
}

import 'package:faker_dart/faker_dart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/preferences_service.dart';

part 'faker_locale_provider.g.dart';

@Riverpod(keepAlive: true)
class FakerLocale extends _$FakerLocale {
  @override
  FakerLocaleType build() {
    final prefs = ref.watch(preferencesServiceProvider);
    final localeName = prefs.getFakerLocale();
    return FakerLocaleType.values.firstWhere(
      (e) => e.name == localeName,
      orElse: () => FakerLocaleType.en_US,
    );
  }

  Future<void> setLocale(FakerLocaleType locale) async {
    state = locale;
    await ref.read(preferencesServiceProvider).setFakerLocale(locale.name);
  }
}

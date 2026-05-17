import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:faker_dart/faker_dart.dart';
import '../../../core/utils/faker_fix.dart';
import '../../../core/providers/faker_locale_provider.dart';
import '../models/identity_state.dart';

part 'identity_provider.g.dart';

@Riverpod(keepAlive: true)
class Identity extends _$Identity {
  late Faker _faker;

  @override
  IdentityState build() {
    _faker = Faker.instance;
    // Sync with global faker locale
    final globalLocale = ref.watch(fakerLocaleProvider);
    _faker.setLocale(globalLocale);

    return IdentityState(
      resultsMap: <IdentityType, List<List<String>>>{},
      locale: globalLocale,
    );
  }

  void setLocale(FakerLocaleType locale) {
    ref.read(fakerLocaleProvider.notifier).setLocale(locale);
  }

  void setType(IdentityType type) {
    state = state.copyWith(selectedType: type);
  }

  void setQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
  }

  void setCustomDomain(String domain) {
    state = state.copyWith(customDomain: domain);
  }

  void setIncludeFormatting(bool value) {
    state = state.copyWith(includeFormatting: value);
  }

  void setIncludeExtension(bool value) {
    state = state.copyWith(includeExtension: value);
  }

  void clear() {
    state = state.copyWith(
      resultsMap: <IdentityType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: <List<String>>[],
      },
    );
  }

  void generate() {
    final List<String> currentGeneration = [];
    final int count = state.quantity;

    for (int i = 0; i < count; i++) {
      currentGeneration.add(_generateSingle());
    }

    final currentHistory = List<List<String>>.from(state.resultsMap[state.selectedType] ?? []);
    
    // Add to top of history (FIFO)
    final newHistory = [currentGeneration, ...currentHistory];
    
    // Truncate to 10
    if (newHistory.length > 10) {
      newHistory.removeRange(10, newHistory.length);
    }

    state = state.copyWith(
      resultsMap: <IdentityType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: newHistory,
      },
    );
  }

  String _generateSingle() {
    late String result;
    switch (state.selectedType) {
      case IdentityType.email:
        if (state.customDomain.isNotEmpty) {
          final first = _faker.name.firstName().toLowerCase();
          final last = _faker.name.lastName().toLowerCase();
          final domain = state.customDomain.replaceAll('@', '');
          result = '$first.$last@$domain';
        } else {
          result = _faker.internet.email();
        }
        break;
      case IdentityType.address:
        final street = _faker.address.streetAddress();
        final city = _faker.address.city();
        final stateName = _faker.address.state();
        final zip = _faker.address.zipCode();
        result = '$street, $city, $stateName $zip';
        break;
      case IdentityType.phone:
        result = _faker.phoneNumber.phoneNumber();
        break;
      case IdentityType.internet:
        result = _faker.internet.ip();
        break;
      case IdentityType.company:
        final name = _faker.company.companyName();
        final bs = _faker.company.bs();
        result = '$name\n"$bs"';
        break;
      case IdentityType.name:
        result = _faker.name.fullName();
        break;
    }

    return FakerFix.fix(result, includeExtension: state.includeExtension);
  }
  void removeHistory(List<String> session) {
    final currentHistory = List<List<String>>.from(state.resultsMap[state.selectedType] ?? []);
    currentHistory.remove(session);
    state = state.copyWith(
      resultsMap: <IdentityType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: currentHistory,
      },
    );
  }
}

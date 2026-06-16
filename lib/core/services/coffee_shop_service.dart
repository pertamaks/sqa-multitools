import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'preferences_service.dart';
import 'license_service.dart';

part 'coffee_shop_service.g.dart';

@Riverpod(keepAlive: true)
LicenseService licenseService(Ref ref) {
  return LicenseService(ref.watch(preferencesServiceProvider));
}

class CoffeeShopService {
  final PreferencesService _prefs;
  final LicenseService _license;

  CoffeeShopService(this._prefs, this._license);

  int get supporterTier => _prefs.getSupporterTier();
  Future<String?> get supporterEmail => _prefs.getSupporterEmail();

  Future<int?> redeemCode(String email, String code) async {
    final tier = await _license.verifyWithServer(email, code);
    return tier;
  }

  Future<void> resetSupporter() async {
    await _prefs.setSupporterTier(0);
    await _prefs.setSupporterCode('');
    await _prefs.setSupporterEmail('');
    await _prefs.setSupporterSignature('');
  }

  /// Performs a cold-start validation of the stored license.
  Future<int> validateLicense() async {
    return await _license.verifyLocally();
  }
}

@Riverpod(keepAlive: true)
CoffeeShopService coffeeShopService(Ref ref) {
  return CoffeeShopService(
    ref.watch(preferencesServiceProvider),
    ref.watch(licenseServiceProvider),
  );
}

@Riverpod(keepAlive: true)
class SupporterTier extends _$SupporterTier {
  @override
  int build() {
    // Initial state is what's in prefs, but we'll validate it asynchronously
    final service = ref.watch(coffeeShopServiceProvider);

    // Trigger background validation
    _validateLicense();

    return service.supporterTier;
  }

  Future<void> _validateLicense() async {
    final validTier = await ref
        .read(coffeeShopServiceProvider)
        .validateLicense();
    if (state != validTier) {
      state = validTier;
    }
  }

  Future<int?> redeem(String email, String code) async {
    final tier = await ref
        .read(coffeeShopServiceProvider)
        .redeemCode(email, code);
    if (tier != null) {
      state = tier;
    }
    return tier;
  }

  Future<void> reset() async {
    await ref.read(coffeeShopServiceProvider).resetSupporter();
    state = 0;
  }
}

@Riverpod(keepAlive: true)
Future<String?> supporterEmail(Ref ref) {
  return ref.watch(coffeeShopServiceProvider).supporterEmail;
}

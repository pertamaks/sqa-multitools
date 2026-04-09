import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'preferences_service.dart';

class CoffeeCodeValidator {
  static const String salt = 'sqa-coffee';

  static int? getTier(String code) {
    final cleanCode = code.trim().toUpperCase();
    final parts = cleanCode.split('-');

    // Format: PREFIX-XXXX-XXXX-YY (4 parts)
    if (parts.length != 4) return null;

    final prefix = parts[0];
    final hexPart1 = parts[1];
    final hexPart2 = parts[2];
    final checksum = parts[3];

    if (hexPart1.length != 4 || hexPart2.length != 4 || checksum.length != 2) {
      return null;
    }

    final int tier;
    switch (prefix) {
      case 'ESP':
        tier = 1;
        break;
      case 'LAT':
        tier = 2;
        break;
      case 'MOC':
        tier = 3;
        break;
      default:
        return null;
    }

    // Validation: sha256(prefix + hex1 + hex2 + salt).substring(0, 2) == checksum
    final dataToHash = '$prefix$hexPart1$hexPart2$salt';
    final hash = sha256
        .convert(utf8.encode(dataToHash))
        .toString()
        .toUpperCase();
    final expectedChecksum = hash.substring(0, 2);

    if (checksum == expectedChecksum) {
      return tier;
    }

    return null;
  }
}

class CoffeeShopService {
  final PreferencesService _prefs;

  CoffeeShopService(this._prefs);

  int get supporterTier => _prefs.getSupporterTier();

  Future<int?> redeemCode(String code) async {
    final tier = CoffeeCodeValidator.getTier(code);
    if (tier != null) {
      final currentTier = _prefs.getSupporterTier();
      // Only upgrade, don't downgrade if they put an older code
      if (tier > currentTier) {
        await _prefs.setSupporterTier(tier);
        await _prefs.setSupporterCode(code.trim().toUpperCase());
      }
      return tier;
    }
    return null;
  }

  Future<void> resetSupporter() async {
    await _prefs.setSupporterTier(0);
    await _prefs.setSupporterCode('');
  }
}

final coffeeShopServiceProvider = Provider<CoffeeShopService>((ref) {
  return CoffeeShopService(ref.watch(preferencesServiceProvider));
});

class SupporterTierNotifier extends Notifier<int> {
  @override
  int build() {
    return ref.watch(coffeeShopServiceProvider).supporterTier;
  }

  Future<int?> redeem(String code) async {
    final tier = await ref.read(coffeeShopServiceProvider).redeemCode(code);
    if (tier != null) {
      state = ref.read(coffeeShopServiceProvider).supporterTier;
    }
    return tier;
  }

  Future<void> reset() async {
    await ref.read(coffeeShopServiceProvider).resetSupporter();
    state = 0;
  }
}

final supporterTierProvider = NotifierProvider<SupporterTierNotifier, int>(() {
  return SupporterTierNotifier();
});

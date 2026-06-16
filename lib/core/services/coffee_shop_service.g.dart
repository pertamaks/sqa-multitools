// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coffee_shop_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(licenseService)
final licenseServiceProvider = LicenseServiceProvider._();

final class LicenseServiceProvider
    extends $FunctionalProvider<LicenseService, LicenseService, LicenseService>
    with $Provider<LicenseService> {
  LicenseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'licenseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$licenseServiceHash();

  @$internal
  @override
  $ProviderElement<LicenseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LicenseService create(Ref ref) {
    return licenseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LicenseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LicenseService>(value),
    );
  }
}

String _$licenseServiceHash() => r'246672e54c969d6d6f746a36691834e6ed8fc9e0';

@ProviderFor(coffeeShopService)
final coffeeShopServiceProvider = CoffeeShopServiceProvider._();

final class CoffeeShopServiceProvider
    extends
        $FunctionalProvider<
          CoffeeShopService,
          CoffeeShopService,
          CoffeeShopService
        >
    with $Provider<CoffeeShopService> {
  CoffeeShopServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coffeeShopServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coffeeShopServiceHash();

  @$internal
  @override
  $ProviderElement<CoffeeShopService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CoffeeShopService create(Ref ref) {
    return coffeeShopService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoffeeShopService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoffeeShopService>(value),
    );
  }
}

String _$coffeeShopServiceHash() => r'8b034734a4ac050c15a52225ad386799c8a38b1f';

@ProviderFor(SupporterTier)
final supporterTierProvider = SupporterTierProvider._();

final class SupporterTierProvider
    extends $NotifierProvider<SupporterTier, int> {
  SupporterTierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supporterTierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supporterTierHash();

  @$internal
  @override
  SupporterTier create() => SupporterTier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$supporterTierHash() => r'0756f79cea6417f9b8bcee6331efb6b57fd64c51';

abstract class _$SupporterTier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(supporterEmail)
final supporterEmailProvider = SupporterEmailProvider._();

final class SupporterEmailProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  SupporterEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supporterEmailProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supporterEmailHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return supporterEmail(ref);
  }
}

String _$supporterEmailHash() => r'73d5d34a180b31560d7adee914b1486ae92c182f';

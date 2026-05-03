// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(updateService)
final updateServiceProvider = UpdateServiceProvider._();

final class UpdateServiceProvider
    extends $FunctionalProvider<UpdateService, UpdateService, UpdateService>
    with $Provider<UpdateService> {
  UpdateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateServiceHash();

  @$internal
  @override
  $ProviderElement<UpdateService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateService create(Ref ref) {
    return updateService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateService>(value),
    );
  }
}

String _$updateServiceHash() => r'a25cebc301f37cea1fca54537a730de9f56b581f';

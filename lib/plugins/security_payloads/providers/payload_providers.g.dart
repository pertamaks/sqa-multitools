// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payload_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(securityPayloadRaw)
final securityPayloadRawProvider = SecurityPayloadRawProvider._();

final class SecurityPayloadRawProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  SecurityPayloadRawProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securityPayloadRawProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securityPayloadRawHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return securityPayloadRaw(ref);
  }
}

String _$securityPayloadRawHash() =>
    r'4e1db518783fd4e1432eea8cab355f8e8f0aa73c';

@ProviderFor(securityPayloadData)
final securityPayloadDataProvider = SecurityPayloadDataProvider._();

final class SecurityPayloadDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PayloadCategory>>,
          List<PayloadCategory>,
          FutureOr<List<PayloadCategory>>
        >
    with
        $FutureModifier<List<PayloadCategory>>,
        $FutureProvider<List<PayloadCategory>> {
  SecurityPayloadDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securityPayloadDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securityPayloadDataHash();

  @$internal
  @override
  $FutureProviderElement<List<PayloadCategory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PayloadCategory>> create(Ref ref) {
    return securityPayloadData(ref);
  }
}

String _$securityPayloadDataHash() =>
    r'94691ccd7964893c1b98b8c958066f4c17e3070b';

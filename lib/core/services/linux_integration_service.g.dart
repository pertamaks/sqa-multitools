// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linux_integration_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linuxIntegrationService)
final linuxIntegrationServiceProvider = LinuxIntegrationServiceProvider._();

final class LinuxIntegrationServiceProvider
    extends
        $FunctionalProvider<
          LinuxIntegrationService,
          LinuxIntegrationService,
          LinuxIntegrationService
        >
    with $Provider<LinuxIntegrationService> {
  LinuxIntegrationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linuxIntegrationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linuxIntegrationServiceHash();

  @$internal
  @override
  $ProviderElement<LinuxIntegrationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LinuxIntegrationService create(Ref ref) {
    return linuxIntegrationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinuxIntegrationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinuxIntegrationService>(value),
    );
  }
}

String _$linuxIntegrationServiceHash() =>
    r'3646e17252fd29ec083deb76a69dfb1298db615e';

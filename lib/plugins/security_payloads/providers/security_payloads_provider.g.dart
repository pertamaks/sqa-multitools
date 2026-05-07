// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_payloads_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SecurityPayloadsNotifier)
final securityPayloadsProvider = SecurityPayloadsNotifierProvider._();

final class SecurityPayloadsNotifierProvider
    extends $NotifierProvider<SecurityPayloadsNotifier, SecurityPayloadsState> {
  SecurityPayloadsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securityPayloadsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securityPayloadsNotifierHash();

  @$internal
  @override
  SecurityPayloadsNotifier create() => SecurityPayloadsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecurityPayloadsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecurityPayloadsState>(value),
    );
  }
}

String _$securityPayloadsNotifierHash() =>
    r'cd0e923aa049404b3a9a6da801ed2a1d2bd23c30';

abstract class _$SecurityPayloadsNotifier
    extends $Notifier<SecurityPayloadsState> {
  SecurityPayloadsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SecurityPayloadsState, SecurityPayloadsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SecurityPayloadsState, SecurityPayloadsState>,
              SecurityPayloadsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

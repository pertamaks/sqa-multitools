// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Identity)
final identityProvider = IdentityProvider._();

final class IdentityProvider
    extends $NotifierProvider<Identity, IdentityState> {
  IdentityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'identityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$identityHash();

  @$internal
  @override
  Identity create() => Identity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IdentityState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IdentityState>(value),
    );
  }
}

String _$identityHash() => r'25df38fb38d99824d1023715a53f912a4f552c53';

abstract class _$Identity extends $Notifier<IdentityState> {
  IdentityState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<IdentityState, IdentityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IdentityState, IdentityState>,
              IdentityState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

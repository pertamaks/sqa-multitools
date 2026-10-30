// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'omniconverter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OmniConverterNotifier)
final omniConverterProvider = OmniConverterNotifierProvider._();

final class OmniConverterNotifierProvider
    extends $NotifierProvider<OmniConverterNotifier, OmniConverterState> {
  OmniConverterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'omniConverterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$omniConverterNotifierHash();

  @$internal
  @override
  OmniConverterNotifier create() => OmniConverterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OmniConverterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OmniConverterState>(value),
    );
  }
}

String _$omniConverterNotifierHash() =>
    r'b5b5fd32b4f7d514cc72a7e17139400091dcf64b';

abstract class _$OmniConverterNotifier extends $Notifier<OmniConverterState> {
  OmniConverterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OmniConverterState, OmniConverterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OmniConverterState, OmniConverterState>,
              OmniConverterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

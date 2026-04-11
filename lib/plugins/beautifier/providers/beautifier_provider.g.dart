// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beautifier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BeautifierNotifier)
final beautifierProvider = BeautifierNotifierProvider._();

final class BeautifierNotifierProvider
    extends $NotifierProvider<BeautifierNotifier, BeautifierState> {
  BeautifierNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'beautifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$beautifierNotifierHash();

  @$internal
  @override
  BeautifierNotifier create() => BeautifierNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BeautifierState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BeautifierState>(value),
    );
  }
}

String _$beautifierNotifierHash() =>
    r'97e7bcd7b6b13dbd9080261af3a0b60154feb783';

abstract class _$BeautifierNotifier extends $Notifier<BeautifierState> {
  BeautifierState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BeautifierState, BeautifierState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BeautifierState, BeautifierState>,
              BeautifierState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unix_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UnixNotifier)
final unixProvider = UnixNotifierProvider._();

final class UnixNotifierProvider
    extends $NotifierProvider<UnixNotifier, UnixState> {
  UnixNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unixProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unixNotifierHash();

  @$internal
  @override
  UnixNotifier create() => UnixNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnixState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnixState>(value),
    );
  }
}

String _$unixNotifierHash() => r'b7cce0b89ed72c7034893612167726a55645b43e';

abstract class _$UnixNotifier extends $Notifier<UnixState> {
  UnixState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UnixState, UnixState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UnixState, UnixState>,
              UnixState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

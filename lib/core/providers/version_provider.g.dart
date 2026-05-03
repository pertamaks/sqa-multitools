// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'd59213e4ad373f70e211bc6782ace25ca97861a3';

@ProviderFor(UpdateState)
final updateStateProvider = UpdateStateProvider._();

final class UpdateStateProvider
    extends $NotifierProvider<UpdateState, AsyncValue<UpdateInfo?>> {
  UpdateStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateStateHash();

  @$internal
  @override
  UpdateState create() => UpdateState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<UpdateInfo?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<UpdateInfo?>>(value),
    );
  }
}

String _$updateStateHash() => r'1390267512ff3e228a633af89464837225da5b4a';

abstract class _$UpdateState extends $Notifier<AsyncValue<UpdateInfo?>> {
  AsyncValue<UpdateInfo?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UpdateInfo?>, AsyncValue<UpdateInfo?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UpdateInfo?>, AsyncValue<UpdateInfo?>>,
              AsyncValue<UpdateInfo?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

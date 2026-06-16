// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Environments)
final environmentsProvider = EnvironmentsProvider._();

final class EnvironmentsProvider
    extends $NotifierProvider<Environments, List<Environment>> {
  EnvironmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'environmentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$environmentsHash();

  @$internal
  @override
  Environments create() => Environments();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Environment> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Environment>>(value),
    );
  }
}

String _$environmentsHash() => r'9d97ff1ccd6c5231f82b8688eb5bfaa2914c33d6';

abstract class _$Environments extends $Notifier<List<Environment>> {
  List<Environment> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Environment>, List<Environment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Environment>, List<Environment>>,
              List<Environment>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ActiveEnvironmentId)
final activeEnvironmentIdProvider = ActiveEnvironmentIdProvider._();

final class ActiveEnvironmentIdProvider
    extends $NotifierProvider<ActiveEnvironmentId, String> {
  ActiveEnvironmentIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeEnvironmentIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeEnvironmentIdHash();

  @$internal
  @override
  ActiveEnvironmentId create() => ActiveEnvironmentId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$activeEnvironmentIdHash() =>
    r'6b94d29983bcc191d025bcfdbc144e7aada9fc24';

abstract class _$ActiveEnvironmentId extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DevGenerator)
final devGeneratorProvider = DevGeneratorProvider._();

final class DevGeneratorProvider
    extends $NotifierProvider<DevGenerator, DevState> {
  DevGeneratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devGeneratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devGeneratorHash();

  @$internal
  @override
  DevGenerator create() => DevGenerator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DevState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DevState>(value),
    );
  }
}

String _$devGeneratorHash() => r'025d641f52b45100469abcd5ee01e0e3b66766b6';

abstract class _$DevGenerator extends $Notifier<DevState> {
  DevState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DevState, DevState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DevState, DevState>,
              DevState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

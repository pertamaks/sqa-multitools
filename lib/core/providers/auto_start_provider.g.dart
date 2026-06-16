// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_start_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AutoStart)
final autoStartProvider = AutoStartProvider._();

final class AutoStartProvider extends $AsyncNotifierProvider<AutoStart, bool> {
  AutoStartProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'autoStartProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$autoStartHash();

  @$internal
  @override
  AutoStart create() => AutoStart();
}

String _$autoStartHash() => r'a0761e2bfc70e4e7527807f14fe25fde02d445b2';

abstract class _$AutoStart extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

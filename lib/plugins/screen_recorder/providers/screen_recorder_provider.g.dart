// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screen_recorder_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ScreenRecorderNotifier)
final screenRecorderProvider = ScreenRecorderNotifierProvider._();

final class ScreenRecorderNotifierProvider
    extends $NotifierProvider<ScreenRecorderNotifier, ScreenRecorderState> {
  ScreenRecorderNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'screenRecorderProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$screenRecorderNotifierHash();

  @$internal
  @override
  ScreenRecorderNotifier create() => ScreenRecorderNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenRecorderState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenRecorderState>(value),
    );
  }
}

String _$screenRecorderNotifierHash() =>
    r'cf4eab093bfb9ae5082d90e750eda89464f99ed2';

abstract class _$ScreenRecorderNotifier extends $Notifier<ScreenRecorderState> {
  ScreenRecorderState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScreenRecorderState, ScreenRecorderState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScreenRecorderState, ScreenRecorderState>,
              ScreenRecorderState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

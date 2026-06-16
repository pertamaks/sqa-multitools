// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screenshot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IsScreenshotProcessing)
final isScreenshotProcessingProvider = IsScreenshotProcessingProvider._();

final class IsScreenshotProcessingProvider
    extends $NotifierProvider<IsScreenshotProcessing, bool> {
  IsScreenshotProcessingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isScreenshotProcessingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isScreenshotProcessingHash();

  @$internal
  @override
  IsScreenshotProcessing create() => IsScreenshotProcessing();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isScreenshotProcessingHash() =>
    r'0f28aa5bb0f38cb6733c9335344808e2b3e750f3';

abstract class _$IsScreenshotProcessing extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ScreenshotNotifier)
final screenshotProvider = ScreenshotNotifierProvider._();

final class ScreenshotNotifierProvider
    extends $NotifierProvider<ScreenshotNotifier, ScreenshotState> {
  ScreenshotNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'screenshotProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$screenshotNotifierHash();

  @$internal
  @override
  ScreenshotNotifier create() => ScreenshotNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ScreenshotState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ScreenshotState>(value),
    );
  }
}

String _$screenshotNotifierHash() =>
    r'54dc7dd6db3cf156c0f739bc2e4f8604d7a1bedb';

abstract class _$ScreenshotNotifier extends $Notifier<ScreenshotState> {
  ScreenshotState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ScreenshotState, ScreenshotState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ScreenshotState, ScreenshotState>,
              ScreenshotState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

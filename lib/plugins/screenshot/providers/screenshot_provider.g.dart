// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screenshot_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    r'a4155cdff5636c268d965b361d826fee2a442f37';

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

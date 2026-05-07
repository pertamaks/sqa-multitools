// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ffmpeg_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Ffmpeg)
final ffmpegProvider = FfmpegProvider._();

final class FfmpegProvider extends $NotifierProvider<Ffmpeg, FfmpegStatus> {
  FfmpegProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ffmpegProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ffmpegHash();

  @$internal
  @override
  Ffmpeg create() => Ffmpeg();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FfmpegStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FfmpegStatus>(value),
    );
  }
}

String _$ffmpegHash() => r'c8f2c81e84c36436ead48852d9d42d405df5a96f';

abstract class _$Ffmpeg extends $Notifier<FfmpegStatus> {
  FfmpegStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FfmpegStatus, FfmpegStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FfmpegStatus, FfmpegStatus>,
              FfmpegStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

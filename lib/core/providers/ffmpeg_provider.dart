import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../engine/ffmpeg_engine.dart';

part 'ffmpeg_provider.g.dart';

class FfmpegStatus {
  final bool isReady;
  final bool isDownloading;
  final double? downloadProgress;
  final String? error;

  const FfmpegStatus({
    this.isReady = false,
    this.isDownloading = false,
    this.downloadProgress,
    this.error,
  });

  FfmpegStatus copyWith({
    bool? isReady,
    bool? isDownloading,
    double? downloadProgress,
    String? error,
  }) {
    return FfmpegStatus(
      isReady: isReady ?? this.isReady,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      error: error ?? this.error,
    );
  }
}

@Riverpod(keepAlive: true)
class Ffmpeg extends _$Ffmpeg {
  @override
  FfmpegStatus build() {
    _checkStatus();
    return const FfmpegStatus();
  }

  Future<void> _checkStatus() async {
    final available = await FfmpegEngine.isEngineAvailable();
    state = state.copyWith(isReady: available);
  }

  Future<void> download() async {
    if (state.isDownloading) return;

    state = state.copyWith(
      isDownloading: true,
      downloadProgress: 0.0,
      error: null,
    );

    try {
      await FfmpegEngine.downloadEngine((progress) {
        state = state.copyWith(downloadProgress: progress);
      });
      
      state = state.copyWith(
        isReady: true,
        isDownloading: false,
        downloadProgress: null,
      );
    } catch (e) {
      state = state.copyWith(
        isDownloading: false,
        downloadProgress: null,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await _checkStatus();
  }
}

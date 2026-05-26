import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../engine/ffmpeg_engine.dart';

part 'ffmpeg_provider.g.dart';

final ffmpegEngineProvider = Provider<FfmpegEngine>((ref) => FfmpegEngine());

class FfmpegStatus {
  final bool isReady;
  final bool isDownloading;
  final double? downloadProgress;
  final String? error;
  final int? remoteSizeBytes;

  const FfmpegStatus({
    this.isReady = false,
    this.isDownloading = false,
    this.downloadProgress,
    this.error,
    this.remoteSizeBytes,
  });

  String? get formattedRemoteSize {
    if (remoteSizeBytes == null) return null;
    final bytes = remoteSizeBytes!;
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).round()} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  FfmpegStatus copyWith({
    bool? isReady,
    bool? isDownloading,
    double? downloadProgress,
    String? error,
    int? remoteSizeBytes,
  }) {
    return FfmpegStatus(
      isReady: isReady ?? this.isReady,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      error: error ?? this.error,
      remoteSizeBytes: remoteSizeBytes ?? this.remoteSizeBytes,
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
    if (!ref.mounted) return;
    state = state.copyWith(isReady: available);

    if (!available) {
      final size = await FfmpegEngine.fetchRemoteSize();
      if (!ref.mounted) return;
      state = state.copyWith(remoteSizeBytes: size);
    }
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
        if (!ref.mounted) return;
        state = state.copyWith(downloadProgress: progress);
      });

      if (!ref.mounted) return;
      state = state.copyWith(
        isReady: true,
        isDownloading: false,
        downloadProgress: null,
      );
    } catch (e) {
      if (!ref.mounted) return;
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

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:screen_retriever/screen_retriever.dart';
import '../models/capture_mode.dart';
import 'ffmpeg_platform_config.dart';

/// Configuration for a video recording session.
/// Decoupled from plugin-specific states to allow core-level use.
class FfmpegVideoConfig {
  final int framerate;
  final String? resolution;
  final bool showCursor;
  final CaptureMode captureMode;
  final Rect? captureRect;
  final bool microphoneEnabled;
  final String? selectedAudioDevice;

  const FfmpegVideoConfig({
    required this.framerate,
    this.resolution,
    required this.showCursor,
    required this.captureMode,
    this.captureRect,
    this.microphoneEnabled = false,
    this.selectedAudioDevice,
  });
}

class FfmpegEngine {
  static final FfmpegPlatformConfig _config = FfmpegPlatformConfig.current();

  static String get _downloadUrl => _config.downloadUrl;

  static String get _executableName => _config.executableName;

  static Future<File> get _executableFile async {
    final dir = await getApplicationSupportDirectory();
    return File(p.join(dir.path, 'ffmpeg', 'bin', _executableName));
  }

  static String? _resolvedExecutable;

  /// Checks if ffmpeg.exe already exists natively or in the support directory.
  static Future<bool> isEngineAvailable() async {
    if (_resolvedExecutable != null) return true;

    // 1. Check system PATH
    try {
      final result = await Process.run(_executableName, ['-version']);
      if (result.exitCode == 0) {
        _resolvedExecutable = _executableName;
        return true;
      }
    } catch (_) {
      // Not in PATH, fallback to local checked
    }

    // 2. Check local downloaded version
    final file = await _executableFile;
    if (await file.exists()) {
      _resolvedExecutable = file.path;
      return true;
    }

    return false;
  }

  static Future<String?> getExecutablePath() async {
    if (await isEngineAvailable()) {
      return _resolvedExecutable;
    }
    return null;
  }

  /// Downloads and extracts the FFmpeg binary.
  /// If a valid archive already exists on disk (from a previous failed attempt),
  /// the download is skipped and extraction is retried directly.
  static Future<void> downloadEngine(
    void Function(double progress) onProgress,
  ) async {
    final dir = await getApplicationSupportDirectory();
    final archiveFile = File(p.join(dir.path, _config.archiveTempName));
    final ffmpegDir = Directory(p.join(dir.path, 'ffmpeg'));

    // If a valid archive already exists from a prior run, skip the download.
    if (await archiveFile.exists()) {
      try {
        await _validateZipArchive(archiveFile.path, -1);
        onProgress(0.5); // Already downloaded
      } catch (_) {
        // Corrupt or truncated — delete it so we re-download below.
        try {
          await archiveFile.delete();
        } catch (_) {}
      }
    }

    if (!await archiveFile.exists()) {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 30);
      final request = await client.getUrl(Uri.parse(_downloadUrl));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to download FFmpeg: ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      int receivedBytes = 0;
      final sink = archiveFile.openWrite();

      await for (var chunk in response) {
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          onProgress(receivedBytes / contentLength);
        }
        sink.add(chunk);
      }
      await sink.close();

      if (contentLength > 0 && receivedBytes < contentLength) {
        throw Exception(
          'Download incomplete: received $receivedBytes of $contentLength bytes.',
        );
      }

      if (contentLength < 0) {
        onProgress(1.0); // Assume done if length was unknown
      }

      await _validateZipArchive(archiveFile.path, contentLength);
    }

    // Extract archive (format handled by platform config)
    onProgress(-1); // Indeterminate state during extraction

    if (!await ffmpegDir.exists()) {
      await ffmpegDir.create(recursive: true);
    }
    await _config.extractArchive(archiveFile.path, ffmpegDir.path);

    final extractedBins = await ffmpegDir
        .list(recursive: true)
        .where((e) => e is File && e.path.endsWith(_executableName))
        .toList();

    if (extractedBins.isNotEmpty) {
      final actualExe = extractedBins.first as File;
      final targetExe = await _executableFile;
      if (!await targetExe.parent.exists()) {
        await targetExe.parent.create(recursive: true);
      }
      await actualExe.copy(targetExe.path);
      _resolvedExecutable = targetExe.path;
    } else {
      throw Exception('$_executableName not found in downloaded archive.');
    }

    // Success — clean up the archive. On failure it stays for the next attempt.
    if (await archiveFile.exists()) {
      try {
        await archiveFile.delete();
      } catch (e) {
        debugPrint('Warning: Failed to delete temporary archive: $e');
      }
    }
  }

  /// Fetches the remote archive size in bytes without downloading the full file.
  static Future<int?> fetchRemoteSize() async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request = await client.getUrl(Uri.parse(_downloadUrl));
      final response = await request.close().timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) return null;

      final size = response.contentLength;
      response.drain<void>();
      return size > 0 ? size : null;
    } catch (_) {
      return null;
    }
  }

  /// Verifies that a file is a well-formed ZIP archive by checking the local
  /// file header signature at the start and the end-of-central-directory record
  /// near the tail. This catches truncated or corrupt downloads before extraction.
  static Future<void> _validateZipArchive(String path, int expectedSize) async {
    final file = File(path);
    final actualSize = await file.length();

    if (actualSize < 22) {
      throw Exception('Downloaded archive is too small ($actualSize bytes).');
    }

    if (expectedSize > 0 && actualSize < expectedSize) {
      throw Exception(
        'Archive size mismatch: expected $expectedSize, got $actualSize bytes.',
      );
    }

    // Verify ZIP local file header signature (PK\x03\x04)
    final header = await file.openRead(0, 4).toList();
    if (header.isEmpty || header.first.length < 4) {
      throw Exception('Cannot read archive header.');
    }
    final magic = header.first;
    if (magic[0] != 0x50 ||
        magic[1] != 0x4B ||
        magic[2] != 0x03 ||
        magic[3] != 0x04) {
      throw Exception('Downloaded file is not a valid ZIP archive.');
    }

    // Verify end-of-central-directory signature (PK\x05\x06) in the last 64 KB
    final tailStart = actualSize > 65536 ? actualSize - 65536 : 0;
    final tail = await file.openRead(tailStart, actualSize).toList();
    final tailBytes = tail.expand((b) => b).toList();
    bool foundEocd = false;
    for (int i = tailBytes.length - 22; i >= 0; i--) {
      if (tailBytes[i] == 0x50 &&
          tailBytes[i + 1] == 0x4B &&
          tailBytes[i + 2] == 0x05 &&
          tailBytes[i + 3] == 0x06) {
        foundEocd = true;
        break;
      }
    }
    if (!foundEocd) {
      throw Exception(
        'ZIP central directory not found — archive may be truncated.',
      );
    }
  }

  /// Lists available audio input devices using the platform's audio backend.
  static Future<List<String>> listAudioDevices() async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) return [];

    try {
      final result = await Process.run(
        _resolvedExecutable!,
        _config.buildListAudioDevicesArgs(),
      );

      final output = result.stderr as String;
      final lines = output.split('\n');
      final devices = <String>[];
      final deviceRegex = _config.audioDeviceRegex;

      for (final line in lines) {
        final match = deviceRegex.firstMatch(line);
        if (match != null) {
          final deviceName = match.group(1);
          if (deviceName != null) {
            devices.add(deviceName);
          }
        }
      }
      return devices;
    } catch (e) {
      debugPrint('[FfmpegEngine] Failed to list audio devices: $e');
      return [];
    }
  }

  /// Builds the argument list for FFmpeg.
  List<String> buildArguments({
    required FfmpegVideoConfig config,
    required String outputPath,
    required List<Display> displays,
  }) {
    final args = <String>[];
    args.addAll(['-y']);

    // Platform-specific input args
    args.addAll(_config.buildVideoArgs(config: config));

    final filters = <String>[];
    if (config.captureRect != null) {
      final rect = config.captureRect!;

      // 1. Calculate Virtual Desktop logical bounds
      double globalMinX = 0;
      double globalMinY = 0;
      for (final d in displays) {
        final pos = d.visiblePosition ?? Offset.zero;
        if (pos.dx < globalMinX) globalMinX = pos.dx;
        if (pos.dy < globalMinY) globalMinY = pos.dy;
      }

      // 2. Find target display and origin
      Display? targetDisplay;
      double maxOverlap = -1.0;
      for (final d in displays) {
        final dRect = Rect.fromLTWH(
          d.visiblePosition?.dx ?? 0,
          d.visiblePosition?.dy ?? 0,
          d.size.width,
          d.size.height,
        );
        final intersect = dRect.intersect(rect);
        if (intersect.width > 0 && intersect.height > 0) {
          final area = intersect.width * intersect.height;
          if (area > maxOverlap) {
            maxOverlap = area;
            targetDisplay = d;
          }
        }
      }
      targetDisplay ??= displays.first;
      final targetScale = (targetDisplay.scaleFactor ?? 1.0).toDouble();
      final targetOrigin = targetDisplay.visiblePosition ?? Offset.zero;

      // 3. Absolute Physical Offsets
      double absOriginX = 0;
      double absOriginY = 0;
      for (final d in displays) {
        final dPos = d.visiblePosition ?? Offset.zero;
        final dScale = (d.scaleFactor ?? 1.0).toDouble();
        if (dPos.dx < targetOrigin.dx) absOriginX += d.size.width * dScale;
        if (dPos.dy < targetOrigin.dy) absOriginY += d.size.height * dScale;
      }

      int x = (absOriginX + (rect.left - targetOrigin.dx) * targetScale)
          .toInt();
      int y = (absOriginY + (rect.top - targetOrigin.dy) * targetScale).toInt();
      int w = (rect.width * targetScale).toInt();
      int h = (rect.height * targetScale).toInt();
      if (w % 2 != 0) w -= 1;
      if (h % 2 != 0) h -= 1;
      filters.add('crop=$w:$h:$x:$y');
    }

    if (config.resolution == '720p') {
      filters.add('scale=-2:720');
    } else if (config.resolution == '1080p') {
      filters.add('scale=-2:1080');
    } else if (config.resolution == '480p') {
      filters.add('scale=-2:480');
    } else if (config.resolution == '360p') {
      filters.add('scale=-2:360');
    }

    args.addAll(['-i', _config.videoInputName]);

    if (config.microphoneEnabled && config.selectedAudioDevice != null) {
      args.addAll(_config.buildAudioArgs(config.selectedAudioDevice!));
    }

    if (filters.isNotEmpty) {
      args.addAll(['-vf', filters.join(',')]);
    }

    args.addAll([
      '-c:v',
      'libx264',
      '-preset',
      'veryfast',
      '-crf',
      '28',
      '-pix_fmt',
      'yuv420p',
    ]);

    if (config.microphoneEnabled && config.selectedAudioDevice != null) {
      args.addAll(['-c:a', 'aac']);
    }

    args.add(outputPath);
    return args;
  }

  /// Spawns the FFmpeg process
  Future<Process> startRecording({
    required FfmpegVideoConfig config,
    required String savePath,
    required List<Display> displays,
  }) async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) {
      throw Exception('FFmpeg engine is not installed or available on PATH.');
    }

    final args = buildArguments(
      config: config,
      outputPath: savePath,
      displays: displays,
    );
    final process = await Process.start(_resolvedExecutable!, args);

    final logFile = File(p.join(Directory.current.path, 'ffmpeg_log.txt'));
    if (await logFile.exists()) await logFile.delete();

    process.stderr.transform(utf8.decoder).listen((data) {
      logFile.writeAsStringSync(data, mode: FileMode.append);
    });

    return process;
  }

  /// Captures a quick low-res thumbnail of a display region.
  static Future<File?> captureDisplayThumbnail(
    Rect bounds,
    List<Display> displays,
  ) async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) return null;

    final tempDir = await getTemporaryDirectory();
    final outputPath = p.join(
      tempDir.path,
      'sqa_thumb_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );

    Display? targetDisplay;
    double maxOverlap = -1.0;
    for (final d in displays) {
      final dRect = Rect.fromLTWH(
        d.visiblePosition?.dx ?? 0,
        d.visiblePosition?.dy ?? 0,
        d.size.width,
        d.size.height,
      );
      final intersection = dRect.intersect(bounds);
      final area = intersection.width * intersection.height;
      if (area > maxOverlap) {
        maxOverlap = area;
        targetDisplay = d;
      }
    }
    targetDisplay ??= displays.first;
    final ratio = (targetDisplay.scaleFactor ?? 1.0).toDouble();
    final displayOrigin = targetDisplay.visiblePosition ?? Offset.zero;

    double physicalOffsetX = 0;
    double physicalOffsetY = 0;
    for (final d in displays) {
      final dPos = d.visiblePosition ?? Offset.zero;
      if (dPos.dx < displayOrigin.dx) {
        physicalOffsetX += d.size.width * (d.scaleFactor ?? 1.0);
      }
      if (dPos.dy < displayOrigin.dy) {
        physicalOffsetY += d.size.height * (d.scaleFactor ?? 1.0);
      }
    }

    int x = ((bounds.left - displayOrigin.dx) * ratio + physicalOffsetX)
        .toInt();
    int y = ((bounds.top - displayOrigin.dy) * ratio + physicalOffsetY).toInt();
    int w = (bounds.width * ratio).toInt();
    int h = (bounds.height * ratio).toInt();

    if (w % 2 != 0) w -= 1;
    if (h % 2 != 0) h -= 1;

    final args = [
      ..._config.buildVideoArgs(
        config: FfmpegVideoConfig(
          framerate: 1,
          showCursor: false,
          captureMode: CaptureMode.area,
        ),
        x: x,
        y: y,
        w: w,
        h: h,
      ),
      '-i',
      _config.videoInputName,
      '-frames:v',
      '1',
      '-vf',
      'scale=320:-2',
      '-y',
      outputPath,
    ];

    try {
      final result = await Process.run(
        _resolvedExecutable!,
        args,
      ).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0) {
        return File(outputPath);
      }
    } catch (e) {
      debugPrint('[FfmpegEngine] Thumbnail capture failed: $e');
    }
    return null;
  }

  /// Takes a high-resolution screenshot of a display region.
  static Future<File?> takeScreenshot({
    required Rect logicalBounds,
    required List<Display> displays,
    required String format,
    required String savePath,
  }) async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) return null;

    Display? targetDisplay;
    double maxOverlap = -1.0;
    for (final d in displays) {
      final dRect = Rect.fromLTWH(
        d.visiblePosition?.dx ?? 0,
        d.visiblePosition?.dy ?? 0,
        d.size.width,
        d.size.height,
      );
      final intersection = dRect.intersect(logicalBounds);
      final area = intersection.width * intersection.height;
      if (area > maxOverlap) {
        maxOverlap = area;
        targetDisplay = d;
      }
    }
    targetDisplay ??= displays.first;
    final ratio = (targetDisplay.scaleFactor ?? 1.0).toDouble();
    final displayOrigin = targetDisplay.visiblePosition ?? Offset.zero;

    double physicalOffsetX = 0;
    double physicalOffsetY = 0;
    for (final d in displays) {
      final dPos = d.visiblePosition ?? Offset.zero;
      if (dPos.dx < displayOrigin.dx) {
        physicalOffsetX += d.size.width * (d.scaleFactor ?? 1.0);
      }
      if (dPos.dy < displayOrigin.dy) {
        physicalOffsetY += d.size.height * (d.scaleFactor ?? 1.0);
      }
    }

    int x = ((logicalBounds.left - displayOrigin.dx) * ratio + physicalOffsetX)
        .toInt();
    int y = ((logicalBounds.top - displayOrigin.dy) * ratio + physicalOffsetY)
        .toInt();
    int w = (logicalBounds.width * ratio).toInt();
    int h = (logicalBounds.height * ratio).toInt();

    if (w % 2 != 0) w -= 1;
    if (h % 2 != 0) h -= 1;

    final args = [
      ..._config.buildVideoArgs(
        config: FfmpegVideoConfig(
          framerate: 1,
          showCursor: false,
          captureMode: CaptureMode.area,
        ),
        x: x,
        y: y,
        w: w,
        h: h,
      ),
      '-i',
      _config.videoInputName,
      '-frames:v',
      '1',
      '-y',
      savePath,
    ];

    try {
      final result = await Process.run(
        _resolvedExecutable!,
        args,
      ).timeout(const Duration(seconds: 10));

      if (result.exitCode == 0) {
        return File(savePath);
      } else {
        debugPrint('[FfmpegEngine] Screenshot failed: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('[FfmpegEngine] Screenshot exception: $e');
    }
    return null;
  }

  /// Composites a foreground image onto a background image.
  static Future<bool> compositeImages({
    required String backgroundPath,
    required String foregroundPath,
    required String outputPath,
    int? cropX,
    int? cropY,
    int? cropW,
    int? cropH,
  }) async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) return false;

    final filter =
        (cropX != null && cropY != null && cropW != null && cropH != null)
        ? '[1:v]crop=$cropW:$cropH:$cropX:$cropY[fg_cropped];[0:v][fg_cropped]overlay=format=auto'
        : 'overlay=format=auto';

    final args = [
      '-y',
      '-i',
      backgroundPath,
      '-i',
      foregroundPath,
      '-filter_complex',
      filter,
      outputPath,
    ];

    try {
      final result = await Process.run(
        _resolvedExecutable!,
        args,
      ).timeout(const Duration(seconds: 10));

      return result.exitCode == 0;
    } catch (e) {
      debugPrint('[FfmpegEngine] Compositing failed: $e');
      return false;
    }
  }

  /// Converts an image file to another format using FFmpeg.
  static Future<bool> convertImage({
    required String inputPath,
    required String outputPath,
  }) async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) return false;

    final args = ['-y', '-i', inputPath, outputPath];

    try {
      final result = await Process.run(
        _resolvedExecutable!,
        args,
      ).timeout(const Duration(seconds: 15));

      return result.exitCode == 0;
    } catch (e) {
      debugPrint('[FfmpegEngine] Convert image failed: $e');
      return false;
    }
  }
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../models/capture_mode.dart';

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
  static const String _downloadUrl =
      'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip';

  static String get _executableName => Platform.isWindows ? 'ffmpeg.exe' : 'ffmpeg';

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

  /// Downloads and extracts the FFmpeg binary.
  static Future<void> downloadEngine(
    void Function(double progress) onProgress,
  ) async {
    final dir = await getApplicationSupportDirectory();
    final zipFile = File(p.join(dir.path, 'ffmpeg_temp.zip'));
    final ffmpegDir = Directory(p.join(dir.path, 'ffmpeg'));

    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(_downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Failed to download FFmpeg: ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      int receivedBytes = 0;
      final sink = zipFile.openWrite();

      await for (var chunk in response) {
        receivedBytes += chunk.length;
        if (contentLength > 0) {
          onProgress(receivedBytes / contentLength);
        }
        sink.add(chunk);
      }
      await sink.close();

      if (contentLength < 0) {
        onProgress(1.0); // Assume done if length was unknown
      }

      // Extract ZIP
      onProgress(-1); // Indeterminate state during extraction

      // We run extraction in an isolate to avoid freezing the UI since the zip is large.
      await compute(_extractZip, {
        'zipPath': zipFile.path,
        'destPath': ffmpegDir.path,
      });

      // We must optionally move the bin contents up, or just find ffmpeg binary.
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
        throw Exception('ffmpeg.exe not found in downloaded archive.');
      }
    } finally {
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
    }
  }

  static Future<void> _extractZip(Map<String, String> args) async {
    final zipPath = args['zipPath']!;
    final destPath = args['destPath']!;
    extractFileToDisk(zipPath, destPath);
  }

  /// Lists available audio input devices using FFmpeg's dshow.
  static Future<List<String>> listAudioDevices() async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) return [];

    try {
      final result = await Process.run(_resolvedExecutable!, [
        '-f',
        'dshow',
        '-list_devices',
        'true',
        '-i',
        'dummy',
      ]);

      final output = result.stderr as String;
      final lines = output.split('\n');
      final devices = <String>[];
      final deviceRegex = RegExp(r'\[dshow @ .*\] "(.*)" \(audio\)');

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
    args.addAll(['-f', 'gdigrab', '-framerate', '${config.framerate}']);

    if (config.showCursor == false) {
      args.addAll(['-draw_mouse', '0']);
    }

    final filters = <String>[];
    if (config.captureMode == CaptureMode.window ||
        config.captureRect != null) {
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

    args.addAll(['-i', 'desktop']);

    if (config.microphoneEnabled && config.selectedAudioDevice != null) {
      args.addAll(['-f', 'dshow', '-i', 'audio=${config.selectedAudioDevice}']);
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
      '-f',
      'gdigrab',
      '-offset_x',
      '$x',
      '-offset_y',
      '$y',
      '-video_size',
      '${w}x$h',
      '-i',
      'desktop',
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
      '-f',
      'gdigrab',
      '-offset_x',
      '$x',
      '-offset_y',
      '$y',
      '-video_size',
      '${w}x$h',
      '-draw_mouse',
      '0',
      '-i',
      'desktop',
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
}

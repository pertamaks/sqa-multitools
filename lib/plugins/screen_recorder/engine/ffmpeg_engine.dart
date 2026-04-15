import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../models/screen_recorder_state.dart';
import '../models/capture_mode.dart';

class FfmpegEngine {
  static const String _downloadUrl =
      'https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl.zip';

  static Future<File> get _executableFile async {
    final dir = await getApplicationSupportDirectory();
    final ffmpegDir = Directory('${dir.path}\\ffmpeg');
    return File('${ffmpegDir.path}\\bin\\ffmpeg.exe');
  }

  static String? _resolvedExecutable;

  /// Checks if ffmpeg.exe already exists natively or in the support directory.
  static Future<bool> isEngineAvailable() async {
    if (_resolvedExecutable != null) return true;

    // 1. Check system PATH
    try {
      final result = await Process.run('ffmpeg', ['-version']);
      if (result.exitCode == 0) {
        _resolvedExecutable = 'ffmpeg';
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
    final zipFile = File('${dir.path}\\ffmpeg_temp.zip');
    final ffmpegDir = Directory('${dir.path}\\ffmpeg');

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

      // BtbN releases typically contain a root folder like "ffmpeg-master-latest-win64-gpl".
      // We must optionally move the bin contents up, or just find ffmpeg.exe.
      final extractedBins = await ffmpegDir
          .list(recursive: true)
          .where((e) => e is File && e.path.endsWith('ffmpeg.exe'))
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
      // Clean up temp zip and unneeded extracted root if we copied the exe,
      // but to be safe we just delete the zip.
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
    }
  }

  /// Extractor function meant to run inside an Isolate via `compute`.
  static Future<void> _extractZip(Map<String, String> args) async {
    final zipPath = args['zipPath']!;
    final destPath = args['destPath']!;

    extractFileToDisk(zipPath, destPath);
  }

  /// Builds the argument list for FFmpeg.
  List<String> buildArguments(ScreenRecorderState state, String outputPath, List<Display> displays) {
    final args = <String>[];

    // Global flags
    args.addAll(['-y']); // Overwrite outputs

    // Input configuration
    args.addAll(['-f', 'gdigrab', '-framerate', '${state.framerate}']);
    
    // Hide cursor if requested
    if (state.showCursor == false) {
      args.addAll(['-draw_mouse', '0']);
    }

    // Modes
    if (state.captureMode == CaptureMode.window) {
      args.addAll(['-i', 'title="${state.targetWindowName}"']);
    } else if (state.captureRect != null) {
      final rect = state.captureRect!;
      
      // 1. Find the display that primarily contains this capture rect
      Display? targetDisplay;
      double maxOverlap = -1.0;
      
      for (final d in displays) {
        final dRect = Rect.fromLTWH(
          d.visiblePosition?.dx ?? 0,
          d.visiblePosition?.dy ?? 0,
          d.size.width,
          d.size.height,
        );
        final intersection = dRect.intersect(rect);
        final area = intersection.width * intersection.height;
        if (area > maxOverlap) {
          maxOverlap = area;
          targetDisplay = d;
        }
      }

      // 2. Fallback to first display if not found
      targetDisplay ??= displays.first;
      final ratio = (targetDisplay.scaleFactor ?? 1.0).toDouble();
      final displayOrigin = targetDisplay.visiblePosition ?? Offset.zero;

      // 3. Calculate Global Physical Origin for this display
      // On Windows, the virtual desktop bitmap is a collage of physical pixels.
      // We calculate the physical offset by summing physical widths/heights of monitors 
      // that are strictly to the left or above the target monitor.
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

      // 4. Calculate Primary Physical Offset
      // We need to shift everything relative to the Primary monitor's top-left (logical 0,0)
      double primaryPhysicalOffsetX = 0;
      double primaryPhysicalOffsetY = 0;
      for (final d in displays) {
        final dPos = d.visiblePosition ?? Offset.zero;
        if (dPos.dx < 0) {
          primaryPhysicalOffsetX += d.size.width * (d.scaleFactor ?? 1.0);
        }
        if (dPos.dy < 0) {
          primaryPhysicalOffsetY += d.size.height * (d.scaleFactor ?? 1.0);
        }
      }

      // 5. Calculate Final Coordinates
      // Result = (TotalPhysicalFromLeft - PrimaryPhysicalFromLeft)
      int x = (((rect.left - displayOrigin.dx) * ratio + physicalOffsetX) - primaryPhysicalOffsetX).toInt();
      int y = (((rect.top - displayOrigin.dy) * ratio + physicalOffsetY) - primaryPhysicalOffsetY).toInt();
      int width = (rect.width * ratio).toInt();
      int height = (rect.height * ratio).toInt();

      // libx264 (yuv420p) requires even dimensions
      if (width % 2 != 0) width -= 1;
      if (height % 2 != 0) height -= 1;

      args.addAll([
        '-offset_x', '$x',
        '-offset_y', '$y',
        '-video_size', '${width}x$height',
        '-i', 'desktop',
      ]);
    } else {
      // Fallback
      args.addAll(['-i', 'desktop']);
    }

    // Output encoding settings
    args.addAll([
      '-c:v', 'libx264',
      '-preset', 'veryfast',
      '-crf', '28',
      '-pix_fmt', 'yuv420p',
    ]);

    // Scale resolution if needed (1080p / 720p)
    if (state.resolution == '720p') {
      args.addAll(['-vf', 'scale=-2:720']); // Ensures width is divisible by 2
    } else if (state.resolution == '1080p') {
      args.addAll(['-vf', 'scale=-2:1080']);
    }

    // Output path
    args.add(outputPath);

    return args;
  }

  /// Spawns the FFmpeg process
  Future<Process> startRecording(
    ScreenRecorderState state,
    String savePath,
    List<Display> displays,
  ) async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) {
      throw Exception('FFmpeg engine is not installed or available on PATH.');
    }

    final args = buildArguments(state, savePath, displays);
    debugPrint('[ScreenRecorder] FFmpeg Command: $_resolvedExecutable ${args.join(' ')}');

    // Using Process.start
    final process = await Process.start(_resolvedExecutable!, args);

    // Diagnostics: Pipe stderr to a log file in the project root for easier debugging
    final logFile = File('${Directory.current.path}\\ffmpeg_log.txt');
    if (await logFile.exists()) await logFile.delete();

    // We don't await the collection of logs to avoid blocking
    process.stderr.transform(utf8.decoder).listen((data) {
      logFile.writeAsStringSync(data, mode: FileMode.append);
    });

    return process;
  }

  /// Captures a quick low-res thumbnail of a display region.
  static Future<File?> captureDisplayThumbnail(Rect bounds, List<Display> displays) async {
    if (!await isEngineAvailable() || _resolvedExecutable == null) return null;

    final tempDir = await getTemporaryDirectory();
    final outputPath = '${tempDir.path}\\sqa_thumb_${DateTime.now().microsecondsSinceEpoch}.jpg';

    // 1. Find the target display
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

    // 2. Calculate physical origin
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

    // 3. Calculate physical coordinates
    int x = ((bounds.left - displayOrigin.dx) * ratio + physicalOffsetX).toInt();
    int y = ((bounds.top - displayOrigin.dy) * ratio + physicalOffsetY).toInt();
    int w = (bounds.width * ratio).toInt();
    int h = (bounds.height * ratio).toInt();

    // Force even dimensions
    if (w % 2 != 0) w -= 1;
    if (h % 2 != 0) h -= 1;

    final args = [
      '-f', 'gdigrab',
      '-offset_x', '$x',
      '-offset_y', '$y',
      '-video_size', '${w}x$h',
      '-i', 'desktop',
      '-frames:v', '1',
      '-vf', 'scale=320:-2', // Small thumbnail with aspect ratio preserved (even width)
      '-y',
      outputPath,
    ];

    try {
      final result = await Process.run(_resolvedExecutable!, args).timeout(const Duration(seconds: 5));
      if (result.exitCode == 0) {
        return File(outputPath);
      }
    } catch (e) {
      debugPrint('[ScreenRecorder] Thumbnail capture failed: $e');
    }

    return null;
  }
}

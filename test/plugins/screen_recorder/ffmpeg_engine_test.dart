import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:sqa_multitools/core/engine/ffmpeg_engine.dart';
import 'package:sqa_multitools/core/models/capture_mode.dart';

void main() {
  late FfmpegEngine engine;

  /// Helper to create a mock Display
  Display createDisplay({
    required String id,
    required Offset position,
    required Size size,
    double ratio = 1.0,
  }) {
    return Display(
      id: id,
      name: 'Display $id',
      size: size,
      visiblePosition: position,
      scaleFactor: ratio,
    );
  }

  setUp(() {
    engine = FfmpegEngine();
  });

  group('FfmpegEngine buildArguments Tests', () {
    test('Full Screen mode uses captureRect offsets', () {
      const config = FfmpegVideoConfig(
        captureMode: CaptureMode.fullScreen,
        captureRect: Rect.fromLTWH(1920, 0, 1920, 1080),
        framerate: 30,
        showCursor: true,
      );

      final displays = [
        createDisplay(
          id: '1',
          position: Offset.zero,
          size: const Size(1920, 1080),
        ),
        createDisplay(
          id: '2',
          position: const Offset(1920, 0),
          size: const Size(1920, 1080),
        ),
      ];

      final args = engine.buildArguments(
        config: config,
        outputPath: 'output.mp4',
        displays: displays,
      );

      // Verify crop filter for secondary monitor
      expect(args, contains('-vf'));
      final vf = args[args.indexOf('-vf') + 1];
      expect(vf, contains('crop=1920:1080:1920:0'));
    });

    test('Area mode uses captureRect (selectionRect mapped)', () {
      const config = FfmpegVideoConfig(
        captureMode: CaptureMode.area,
        captureRect: Rect.fromLTWH(
          2020,
          100,
          500,
          400,
        ), // Selection on Monitor 2
        framerate: 30,
        showCursor: true,
      );

      final displays = [
        createDisplay(
          id: '1',
          position: Offset.zero,
          size: const Size(1920, 1080),
        ),
        createDisplay(
          id: '2',
          position: const Offset(1920, 0),
          size: const Size(1920, 1080),
        ),
      ];

      final args = engine.buildArguments(
        config: config,
        outputPath: 'output.mp4',
        displays: displays,
      );

      final vf = args[args.indexOf('-vf') + 1];
      // (2020 - 1920) + 1920 (physical offset) = 2020
      expect(vf, contains('crop=500:400:2020:100'));
    });

    test('Ensures even dimensions for libx264', () {
      const config = FfmpegVideoConfig(
        captureMode: CaptureMode.area,
        captureRect: Rect.fromLTWH(10, 10, 333, 221),
        framerate: 30,
        showCursor: true,
      );

      final displays = [
        createDisplay(
          id: '1',
          position: Offset.zero,
          size: const Size(1920, 1080),
        ),
      ];

      final args = engine.buildArguments(
        config: config,
        outputPath: 'output.mp4',
        displays: displays,
      );

      final vf = args[args.indexOf('-vf') + 1];
      expect(vf, contains('crop=332:220'));
    });

    test('DPI Scaling scales coordinates correctly', () {
      const config = FfmpegVideoConfig(
        captureMode: CaptureMode.area,
        captureRect: Rect.fromLTWH(100, 100, 200, 200),
        framerate: 30,
        showCursor: true,
      );

      final displays = [
        createDisplay(
          id: '1',
          position: Offset.zero,
          size: const Size(1920, 1080),
          ratio: 1.5,
        ),
      ];

      final args = engine.buildArguments(
        config: config,
        outputPath: 'output.mp4',
        displays: displays,
      );

      final vf = args[args.indexOf('-vf') + 1];
      expect(vf, contains('crop=300:300:150:150'));
    });

    test('Mixed Scaling - Secondary Monitor Physical Offset', () {
      // Monitor 1: 1920 wide, 150% scaling => 2880 physical width
      // Monitor 2: 1920 wide, 100% scaling => 1920 physical width
      final displays = [
        createDisplay(
          id: '1',
          position: Offset.zero,
          size: const Size(1920, 1080),
          ratio: 1.5,
        ),
        createDisplay(
          id: '2',
          position: const Offset(1920, 0),
          size: const Size(1920, 1080),
          ratio: 1.0,
        ),
      ];

      const config = FfmpegVideoConfig(
        captureMode: CaptureMode.area,
        captureRect: Rect.fromLTWH(
          2000,
          100,
          200,
          200,
        ), // Logical 80px into Monitor 2
        framerate: 30,
        showCursor: true,
      );

      final args = engine.buildArguments(
        config: config,
        outputPath: 'output.mp4',
        displays: displays,
      );

      final vf = args[args.indexOf('-vf') + 1];
      // (2000 - 1920) * 1.0 (local ratio) + 2880 (physical M1 width) = 80 + 2880 = 2960
      expect(vf, contains('crop=200:200:2960:100'));
    });
  });
}

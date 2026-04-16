import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:sqa_multitools/plugins/screen_recorder/engine/ffmpeg_engine.dart';
import 'package:sqa_multitools/plugins/screen_recorder/models/screen_recorder_state.dart';
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
      final state = ScreenRecorderState(
        captureMode: CaptureMode.fullScreen,
        captureRect: const Rect.fromLTWH(1920, 0, 1920, 1080),
        framerate: 30,
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

      final args = engine.buildArguments(state, 'output.mp4', displays);

      expect(args, contains('-offset_x'));
      expect(args[args.indexOf('-offset_x') + 1], '1920');
      expect(args, contains('-offset_y'));
      expect(args[args.indexOf('-offset_y') + 1], '0');
      expect(args, contains('-video_size'));
      expect(args[args.indexOf('-video_size') + 1], '1920x1080');
    });

    test('Area mode uses captureRect (selectionRect mapped)', () {
      final state = ScreenRecorderState(
        captureMode: CaptureMode.area,
        captureRect: const Rect.fromLTWH(
          2020,
          100,
          500,
          400,
        ), // Selection on Monitor 2
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

      final args = engine.buildArguments(state, 'output.mp4', displays);

      // (2020 - 1920) + 1920 (physical offset) = 2020
      expect(args[args.indexOf('-offset_x') + 1], '2020');
      expect(args[args.indexOf('-offset_y') + 1], '100');
    });

    test('Ensures even dimensions for libx264', () {
      final state = ScreenRecorderState(
        captureMode: CaptureMode.area,
        captureRect: const Rect.fromLTWH(10, 10, 333, 221),
      );

      final displays = [
        createDisplay(
          id: '1',
          position: Offset.zero,
          size: const Size(1920, 1080),
        ),
      ];

      final args = engine.buildArguments(state, 'output.mp4', displays);

      expect(args[args.indexOf('-video_size') + 1], '332x220');
    });

    test('Window mode uses title input', () {
      final state = ScreenRecorderState(
        captureMode: CaptureMode.window,
        targetWindowName: 'Notepad',
      );

      final args = engine.buildArguments(state, 'output.mp4', []);

      expect(args, contains('-i'));
      expect(args[args.indexOf('-i') + 1], 'title="Notepad"');
    });

    test('DPI Scaling scales coordinates correctly', () {
      final state = ScreenRecorderState(
        captureMode: CaptureMode.area,
        captureRect: const Rect.fromLTWH(100, 100, 200, 200),
      );

      final displays = [
        createDisplay(
          id: '1',
          position: Offset.zero,
          size: const Size(1920, 1080),
          ratio: 1.5,
        ),
      ];

      final args = engine.buildArguments(state, 'output.mp4', displays);

      expect(args[args.indexOf('-offset_x') + 1], '150');
      expect(args[args.indexOf('-offset_y') + 1], '150');
      expect(args[args.indexOf('-video_size') + 1], '300x300');
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

      final state = ScreenRecorderState(
        captureMode: CaptureMode.area,
        captureRect: const Rect.fromLTWH(
          2000,
          100,
          200,
          200,
        ), // Logical 80px into Monitor 2
      );

      final args = engine.buildArguments(state, 'output.mp4', displays);

      // (2000 - 1920) * 1.0 (local ratio) + 2880 (physical M1 width) = 80 + 2880 = 2960
      expect(args[args.indexOf('-offset_x') + 1], '2960');
      expect(args[args.indexOf('-offset_y') + 1], '100');
    });
  });
}

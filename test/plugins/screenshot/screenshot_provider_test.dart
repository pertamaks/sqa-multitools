import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:sqa_multitools/core/models/capture_mode.dart';
import 'package:sqa_multitools/core/models/screenshot_tool.dart';
import 'package:sqa_multitools/plugins/screenshot/providers/screenshot_provider.dart';

void main() {
  group('ScreenshotNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is correct', () {
      final state = container.read(screenshotProvider);
      expect(state.captureMode, CaptureMode.area);
      expect(state.format, 'PNG');
      expect(state.delaySeconds, 0);
      expect(state.includeCursor, true);
      expect(state.isCapturing, false);
      expect(state.isOverlayVisible, false);
      expect(state.currentTool, ScreenshotTool.pen);
      expect(state.annotationColor, Colors.red);
      expect(state.annotations, isEmpty);
    });

    test('capture() shows overlay', () async {
      final notifier = container.read(screenshotProvider.notifier);
      await notifier.capture();

      final state = container.read(screenshotProvider);
      expect(state.isOverlayVisible, true);
      expect(state.isCapturing, false);
    });

    test('setSelection updates selection rect', () {
      final notifier = container.read(screenshotProvider.notifier);
      const rect = Rect.fromLTWH(0, 0, 100, 100);
      notifier.setSelection(rect);

      final state = container.read(screenshotProvider);
      expect(state.selectionRect, rect);
    });

    test('finalize updates isCapturing and hides overlay', () async {
      final notifier = container.read(screenshotProvider.notifier);
      notifier.startCapture();

      final future = notifier.finalize();
      expect(container.read(screenshotProvider).isCapturing, true);

      await future;

      final state = container.read(screenshotProvider);
      expect(state.isCapturing, false);
      expect(state.isOverlayVisible, false);
    });

    test('stopCapture hides overlay', () {
      final notifier = container.read(screenshotProvider.notifier);
      notifier.startCapture();
      notifier.stopCapture();

      expect(container.read(screenshotProvider).isOverlayVisible, false);
    });
  });
}

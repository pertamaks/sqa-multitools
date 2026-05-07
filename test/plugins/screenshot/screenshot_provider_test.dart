import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/core/providers/ffmpeg_provider.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:sqa_multitools/core/models/screenshot_tool.dart';
import 'package:sqa_multitools/plugins/screenshot/providers/screenshot_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:sqa_multitools/core/window/window_transition_coordinator.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/services.dart';

class MockPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async => './test_docs';
  @override
  Future<String?> getTemporaryPath() async => './test_temp';
}

class MockWindowTransitionCoordinator extends WindowTransitionCoordinator {
  @override
  Future<void> waitForSync({
    bool resize = true,
    bool move = false,
    bool frame = true,
    Size? targetSize,
    Offset? targetOffset,
    Duration timeout = const Duration(milliseconds: 1000),
  }) async {
    return;
  }
}

class MockFfmpeg extends Ffmpeg {
  @override
  FfmpegStatus build() {
    return const FfmpegStatus(isReady: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('ScreenshotNotifier Tests', () {
    late ProviderContainer container;

    setUp(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.leanflutter.plugins/hotkey_manager'),
        (MethodCall call) async => null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.leanflutter.plugins/hotkey_manager_event'),
        (MethodCall call) async => null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.leanflutter.plugins/screen_retriever'),
        (MethodCall call) async {
          if (call.method == 'getAllDisplays') {
            return {
              'displays': [
                {
                  'id': '1',
                  'name': 'Screen 1',
                  'size': {'width': 1920.0, 'height': 1080.0},
                  'scaleFactor': 1.0,
                },
              ],
            };
          }
          return null;
        },
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('window_manager'),
        (MethodCall call) async {
          if (call.method == 'getBounds') {
            return {'x': 0.0, 'y': 0.0, 'width': 800.0, 'height': 600.0};
          }
          if (call.method == 'getSize') {
            return {'width': 800.0, 'height': 600.0};
          }
          if (call.method == 'getPosition') {
            return {'x': 0.0, 'y': 0.0};
          }
          return true;
        },
      );
      SharedPreferences.setMockInitialValues({});
      PathProviderPlatform.instance = MockPathProvider();
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ffmpegProvider.overrideWith(() => MockFfmpeg()),
          windowTransitionProvider.overrideWithValue(
            MockWindowTransitionCoordinator(),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is correct', () {
      final state = container.read(screenshotProvider);
      expect(state.isCapturing, false);
      expect(state.isOverlayVisible, false);
      expect(state.currentTool, ScreenshotTool.pointer);
      expect(state.annotationColor, Colors.red);
      expect(state.annotations, isEmpty);
    });

    test('capture() shows overlay', () async {
      container.listen(screenshotProvider, (_, _) {});
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
      container.listen(screenshotProvider, (_, _) {});
      final notifier = container.read(screenshotProvider.notifier);
      await notifier.startOverlay();
      notifier.setSelection(const Rect.fromLTWH(0, 0, 100, 100));

      final future = notifier.finalize();
      expect(container.read(screenshotProvider).isCapturing, true);

      await future;
      final state = container.read(screenshotProvider);
      expect(state.isCapturing, false);
      expect(state.isOverlayVisible, false);
    });

    test('stopCapture hides overlay', () async {
      container.listen(screenshotProvider, (_, _) {});
      final notifier = container.read(screenshotProvider.notifier);
      await notifier.startOverlay();
      await notifier.stopCapture();

      final state = container.read(screenshotProvider);
      expect(state.isOverlayVisible, false);
    });
  });
}

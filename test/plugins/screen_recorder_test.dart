import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/core/window/window_transition_coordinator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/core/providers/ffmpeg_provider.dart';
import 'package:sqa_multitools/core/models/capture_mode.dart';
import 'package:sqa_multitools/plugins/screen_recorder/providers/screen_recorder_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
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
    // Resolve immediately for tests
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
  group('ScreenRecorderNotifier Tests', () {
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

    test('initial state is correct', () {
      final state = container.read(screenRecorderProvider);

      expect(state.isRecording, false);
      expect(state.captureMode, CaptureMode.fullScreen);
      expect(state.targetWindowName, 'Active Window');
    });

    test('toggleRecording starts and stops recording', () async {
      container.listen(screenRecorderProvider, (_, _) {});
      final notifier = container.read(screenRecorderProvider.notifier);

      // First call enters overlay
      await notifier.toggleRecording();
      expect(container.read(screenRecorderProvider).isOverlayVisible, true);

      // Second call actually starts recording (if already in overlay)
      await notifier.toggleRecording();
      expect(container.read(screenRecorderProvider).isRecording, true);

      await notifier.toggleRecording();
      expect(container.read(screenRecorderProvider).isRecording, false);
    });

    test('setCaptureMode updates state', () {
      final notifier = container.read(screenRecorderProvider.notifier);

      notifier.setCaptureMode(CaptureMode.area);
      expect(
        container.read(screenRecorderProvider).captureMode,
        CaptureMode.area,
      );

      notifier.setCaptureMode(CaptureMode.window);
      expect(
        container.read(screenRecorderProvider).captureMode,
        CaptureMode.window,
      );
    });

    test('setTargetWindow updates state', () {
      final notifier = container.read(screenRecorderProvider.notifier);

      notifier.setTargetWindow('Notepad');
      expect(
        container.read(screenRecorderProvider).targetWindowName,
        'Notepad',
      );
    });
  });
}

// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/screenshot/providers/screenshot_provider.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:sqa_multitools/core/providers/ffmpeg_provider.dart';
import 'package:sqa_multitools/core/window/window_transition_coordinator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:path/path.dart' as p;

class MockPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String path;
  MockPathProvider(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
  @override
  Future<String?> getTemporaryPath() async => '$path/temp';
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
  late Directory testDir;
  late Directory screenshotsDir;

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

    testDir = Directory.systemTemp.createTempSync('sqa_screenshot_test');
    screenshotsDir = Directory(p.join(testDir.path, 'SQA_Screenshots'));
    await screenshotsDir.create(recursive: true);

    PathProviderPlatform.instance = MockPathProvider(testDir.path);
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await testDir.exists()) await testDir.delete(recursive: true);
  });

  test('ScreenshotNotifier - Rename and Validation Logic', () async {
    final prefs = await SharedPreferences.getInstance();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ffmpegProvider.overrideWith(() => MockFfmpeg()),
        windowTransitionProvider.overrideWithValue(
          MockWindowTransitionCoordinator(),
        ),
      ],
    );

    // 1. Setup mock files
    final file1 = File(p.join(screenshotsDir.path, 'SQA_SS_1.png'));
    await file1.writeAsString('dummy content');

    final file2 = File(p.join(screenshotsDir.path, 'SQA_SS_2.png'));
    await file2.writeAsString('dummy content');

    final notifier = container.read(screenshotProvider.notifier);
    container.listen(screenshotProvider, (_, _) {}); // Keep alive
    await notifier.refreshRecentCaptures();

    var state = container.read(screenshotProvider);
    expect(state.recentCaptures.length, 2);

    // 2. Validate rename
    final info1 = state.recentCaptures.firstWhere(
      (i) => i.file.path.contains('SQA_SS_1.png'),
    );
    expect(notifier.validateNewName('SQA_SS_2', info1), isNotNull); // Duplicate
    expect(
      notifier.validateNewName('invalid*name', info1),
      isNotNull,
    ); // Invalid char
    expect(notifier.validateNewName('ValidName', info1), isNull); // Valid

    // 3. Perform rename
    await notifier.renameCapture(info1, 'NewName');

    state = container.read(screenshotProvider);
    expect(
      state.recentCaptures.any((i) => i.file.path.contains('NewName.png')),
      true,
    );
    expect(File('${screenshotsDir.path}\\NewName.png').existsSync(), true);
  });
}

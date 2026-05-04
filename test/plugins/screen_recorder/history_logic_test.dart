// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:sqa_multitools/core/window/window_transition_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/core/providers/ffmpeg_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqa_multitools/plugins/screen_recorder/providers/screen_recorder_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:flutter/services.dart';

class MockPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String testPath;
  MockPathProvider(this.testPath);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return testPath;
  }
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
  late Directory recordingsDir;

  setUpAll(() async {
    const MethodChannel(
      'dev.leanflutter.plugins/hotkey_manager',
    ).setMockMethodCallHandler((MethodCall call) async => null);
    const MethodChannel(
      'dev.leanflutter.plugins/hotkey_manager_event',
    ).setMockMethodCallHandler((MethodCall call) async => null);
    const MethodChannel(
      'dev.leanflutter.plugins/screen_retriever',
    ).setMockMethodCallHandler((MethodCall call) async {
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
    });
    const MethodChannel('window_manager').setMockMethodCallHandler((
      MethodCall call,
    ) async {
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
    });
    SharedPreferences.setMockInitialValues({});
    testDir = Directory.systemTemp.createTempSync('sqa_test');
    PathProviderPlatform.instance = MockPathProvider(testDir.path);

    recordingsDir = Directory('${testDir.path}\\SQA_Recordings');
    if (!await recordingsDir.exists()) {
      await recordingsDir.create(recursive: true);
    }
  });

  tearDownAll(() async {
    if (await testDir.exists()) {
      await testDir.delete(recursive: true);
    }
  });

  test('ScreenRecorderNotifier - history logic listing and sorting', () async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Create dummy files with staggered modification times (BEFORE provider init)
    final file1 = File('${recordingsDir.path}\\SQA_REC_OLD.mp4');
    await file1.writeAsString('old');

    // Ensure file system registers different modification times
    await Future<void>.delayed(const Duration(seconds: 1));

    final file2 = File('${recordingsDir.path}\\SQA_REC_NEW.mp4');
    await file2.writeAsString('new');

    // 2. Initialize provider (this triggers initial build and refresh)
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        ffmpegProvider.overrideWith(() => MockFfmpeg()),
        windowTransitionProvider.overrideWithValue(
          MockWindowTransitionCoordinator(),
        ),
      ],
    );
    container.listen(screenRecorderProvider, (_, _) {}); // Keep alive
    final notifier = container.read(screenRecorderProvider.notifier);

    // 3. Manually trigger and await refresh to ensure we catch the files
    await notifier.refreshRecentRecordings();

    // Check state
    var state = container.read(screenRecorderProvider);

    // Should have 2 recordings
    expect(state.recentRecordings.length, 2);

    // Should be sorted by date descending (NEW first)
    expect(state.recentRecordings[0].file.path, contains('SQA_REC_NEW.mp4'));
    expect(state.recentRecordings[1].file.path, contains('SQA_REC_OLD.mp4'));

    // 3. Test metadata extraction
    expect(state.recentRecordings[0].size, greaterThan(0));
    expect(state.recentRecordings[0].modified, isNotNull);

    // 4. Test deletion
    final firstRecord = state.recentRecordings[0];
    await notifier.deleteRecording(firstRecord);

    state = container.read(screenRecorderProvider);
    expect(state.recentRecordings.length, 1);
    expect(state.recentRecordings[0].file.path, contains('SQA_REC_OLD.mp4'));

    // Verify file is actually gone from disk
    expect(await firstRecord.file.exists(), isFalse);

    // 5. Test renaming
    final remainingRecord = state.recentRecordings[0];
    await notifier.renameRecording(remainingRecord, 'SQA_RENAMED');

    state = container.read(screenRecorderProvider);
    expect(state.recentRecordings.length, 1);
    expect(state.recentRecordings[0].file.path, contains('SQA_RENAMED.mp4'));

    // Verify physical file exists with new name
    final renamedFile = File('${recordingsDir.path}/SQA_RENAMED.mp4');
    expect(await renamedFile.exists(), isTrue);
  });
}

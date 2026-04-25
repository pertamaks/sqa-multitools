// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sqa_multitools/plugins/screen_recorder/providers/screen_recorder_provider.dart';

class MockPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  final String testPath;
  MockPathProvider(this.testPath);

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return testPath;
  }
}

void main() {
  late Directory testDir;
  late Directory recordingsDir;

  setUpAll(() async {
    testDir = Directory.systemTemp.createTempSync('sqa_test');
    PathProviderPlatform.instance = MockPathProvider(testDir.path);

    recordingsDir = Directory('${testDir.path}/SQA_Recordings');
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
    final container = ProviderContainer();
    final notifier = container.read(screenRecorderProvider.notifier);

    // 1. Create dummy files with staggered modification times
    final file1 = File('${recordingsDir.path}/SQA_REC_OLD.mp4');
    await file1.writeAsString('old');

    // Ensure file system registers different modification times
    await Future<void>.delayed(const Duration(seconds: 1));

    final file2 = File('${recordingsDir.path}/SQA_REC_NEW.mp4');
    await file2.writeAsString('new');

    // 2. Trigger refresh
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
  });
}

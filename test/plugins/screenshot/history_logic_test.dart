// ignore_for_file: depend_on_referenced_packages
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/screenshot/providers/screenshot_provider.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async => './test_docs';
  @override
  Future<String?> getTemporaryPath() async => './test_temp';
}

void main() {
  late Directory testDir;
  late Directory screenshotsDir;

  setUp(() async {
    testDir = Directory('./test_docs');
    if (await testDir.exists()) await testDir.delete(recursive: true);
    await testDir.create();
    
    screenshotsDir = Directory('./test_docs/SQA_Screenshots');
    await screenshotsDir.create();

    PathProviderPlatform.instance = MockPathProvider();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    if (await testDir.exists()) await testDir.delete(recursive: true);
    final temp = Directory('./test_temp');
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  test('ScreenshotNotifier - Rename and Validation Logic', () async {
    final prefs = await SharedPreferences.getInstance();
    
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    
    // 1. Setup mock files
    final file1 = File('${screenshotsDir.path}/SQA_SS_1.png');
    await file1.writeAsString('dummy content');
    
    final file2 = File('${screenshotsDir.path}/SQA_SS_2.png');
    await file2.writeAsString('dummy content');

    // 2. Initialize provider
    container.listen(screenshotProvider, (_, _) {});
    final notifier = container.read(screenshotProvider.notifier);

    // Initial refresh
    await notifier.refreshRecentCaptures();
    var state = container.read(screenshotProvider);
    
    expect(state.recentCaptures.length, 2);

    // 3. Test Validation
    final info1 = state.recentCaptures.firstWhere((c) => c.file.path.contains('SQA_SS_1'));
    
    // Empty name
    expect(notifier.validateNewName('', info1), 'Name cannot be empty');
    
    // Invalid characters
    expect(notifier.validateNewName('name?', info1), contains('invalid characters'));
    
    // Duplicate name
    expect(notifier.validateNewName('SQA_SS_2', info1), 'A file with this name already exists');
    
    // Same name (valid, should return null)
    expect(notifier.validateNewName('SQA_SS_1', info1), isNull);
    
    // Valid new name
    expect(notifier.validateNewName('NEW_NAME', info1), isNull);

    // 4. Test Renaming
    await notifier.renameCapture(info1, 'NEW_NAME');
    
    state = container.read(screenshotProvider);
    expect(state.recentCaptures.any((c) => c.file.path.contains('NEW_NAME.png')), isTrue);
    expect(await File('${screenshotsDir.path}/NEW_NAME.png').exists(), isTrue);
    expect(await file1.exists(), isFalse);
  });
}

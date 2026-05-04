import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/core/providers/ffmpeg_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  @override
  Future<String?> getApplicationDocumentsPath() async => './test_docs';
  @override
  Future<String?> getTemporaryPath() async => './test_temp';
}

class MockFfmpeg extends Ffmpeg {
  @override
  FfmpegStatus build() {
    return const FfmpegStatus(isReady: true);
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
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
    PathProviderPlatform.instance = MockPathProvider();
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            ffmpegProvider.overrideWith(() => MockFfmpeg()),
          ],
          child: const SqaMultitoolsApp(),
        ),
      );

      expect(find.byType(SqaMultitoolsApp), findsOneWidget);

      // Wait a bit for Ffmpeg's Process.run to finish
      await Future.delayed(const Duration(milliseconds: 500));

      // Dispose the ProviderScope to clean up any active timers from plugins
      await tester.pumpWidget(Container());
      await tester.pump();
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/core/models/capture_mode.dart';
import 'package:sqa_multitools/plugins/screen_recorder/providers/screen_recorder_provider.dart';

void main() {
  group('ScreenRecorderNotifier Tests', () {
    test('initial state is correct', () {
      final container = ProviderContainer();
      final state = container.read(screenRecorderProvider);

      expect(state.isRecording, false);
      expect(state.captureMode, CaptureMode.fullScreen);
      expect(state.targetWindowName, 'Active Window');
    });

    test('toggleRecording starts and stops recording', () {
      final container = ProviderContainer();
      final notifier = container.read(screenRecorderProvider.notifier);

      notifier.toggleRecording();
      expect(container.read(screenRecorderProvider).isRecording, true);

      notifier.toggleRecording();
      expect(container.read(screenRecorderProvider).isRecording, false);
    });

    test('setCaptureMode updates state', () {
      final container = ProviderContainer();
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
      final container = ProviderContainer();
      final notifier = container.read(screenRecorderProvider.notifier);

      notifier.setTargetWindow('Notepad');
      expect(
        container.read(screenRecorderProvider).targetWindowName,
        'Notepad',
      );
    });
  });
}

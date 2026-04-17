import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../../../core/models/capture_overlay_delegate.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/annotation.dart';
import '../../../core/models/screenshot_tool.dart';
import '../providers/screen_recorder_provider.dart';
import '../models/screen_recorder_state.dart';
import '../../../ui/widgets/sqa_capture_overlay.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_dropdown.dart';

class ScreenRecorderOverlay extends ConsumerWidget {
  const ScreenRecorderOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);

    if (!state.isOverlayVisible) return const SizedBox.shrink();

    return SqaCaptureOverlay(
      delegate: _RecorderDelegate(state, notifier),
      toolbarBuilder: (context) => [
        // Record/Stop button
        SqaFloatingBarButton(
          icon: state.isRecording ? Symbols.stop_circle : Symbols.play_arrow,
          tooltip: state.isRecording ? 'Stop & Save' : 'Start',
          onPressed: () {
            notifier.toggleRecording();
          },
          isPrimary: !state.isRecording,
          color: state.isRecording ? Colors.red : null,
        ),

        if (!state.isRecording)
          SqaFloatingBarButton(
            icon: Symbols.close,
            tooltip: state.countdownSeconds > 0 ? 'Cancel Countdown' : 'Cancel Overlay',
            onPressed: () {
              if (state.countdownSeconds > 0) {
                notifier.cancelCountdown();
              } else {
                notifier.cancelOverlay();
              }
            },
            color: Colors.red,
          ),

        const SqaFloatingBarDivider(),

        // Mic Toggle
        SqaFloatingBarButton(
          icon: state.microphoneEnabled ? Symbols.mic : Symbols.mic_off,
          tooltip: 'Toggle Microphone',
          onPressed: state.isRecording ? null : () => notifier.toggleMicrophone(),
          isSelected: state.microphoneEnabled,
        ),

        // Delay selector (only before recording)
        if (!state.isRecording) ...[
          const SqaFloatingBarDivider(),
          SqaDropdown<int>(
            value: state.delaySeconds,
            onChanged: (val) {
              if (val != null) notifier.setDelay(val);
            },
            items: [0, 2, 5, 10]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text('${e}s'),
                  ),
                )
                .toList(),
          ),
        ],

        const SqaFloatingBarDivider(),

        // Annotation Tools
        ...[
          (ScreenshotTool.pointer, Symbols.near_me, 'Pointer'),
          (ScreenshotTool.pen, Symbols.edit, 'Pen'),
          (ScreenshotTool.marker, Symbols.brush, 'Highlighter'),
          (ScreenshotTool.arrow, Symbols.arrow_outward, 'Arrow'),
          (ScreenshotTool.rectangle, Symbols.rectangle, 'Rectangle'),
          (ScreenshotTool.laser, Symbols.stylus_laser_pointer, 'Laser Pointer'),
        ].map(
          (t) => SqaFloatingBarButton(
            icon: t.$2,
            tooltip: t.$3,
            isSelected: state.currentTool == t.$1,
            onPressed: () => notifier.setTool(t.$1),
          ),
        ),

        const SqaFloatingBarDivider(),

        // Colors
        ...[
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.white,
        ].map(
          (c) => SqaFloatingBarColorPicker(
            color: c,
            isSelected: state.annotationColor == c,
            onTap: () => notifier.setColor(c),
          ),
        ),

        const SqaFloatingBarDivider(),

        // Clear button
        SqaFloatingBarButton(
          icon: Symbols.delete_sweep,
          tooltip: 'Clear Annotations',
          onPressed: () => notifier.clearAnnotations(),
        ),
      ],
    );
  }
}

class _RecorderDelegate implements CaptureOverlayDelegate {
  final ScreenRecorderState _state;
  final ScreenRecorderNotifier _notifier;

  _RecorderDelegate(this._state, this._notifier);

  @override bool get isOverlayVisible => _state.isOverlayVisible;
  @override bool get isTargetingWindow => _state.isTargetingWindow;
  @override CaptureMode get captureMode => _state.captureMode;
  @override Rect? get selectionRect => _state.selectionRect;
  @override Rect? get targetedWindowRect => _state.targetedWindowRect;
  @override String? get targetWindowName => _state.targetWindowName;
  @override List<Annotation> get annotations => _state.annotations;
  @override Color get annotationColor => _state.annotationColor;
  @override ScreenshotTool get currentTool => _state.currentTool;
  @override List<Display> get availableDisplays => _state.availableDisplays;

  @override bool get isRecording => _state.isRecording;
  @override bool get isPaused => _state.isPaused;
  @override int get durationSeconds => _state.durationSeconds;
  @override int get countdownSeconds => _state.countdownSeconds;
  
  @override bool get isCapturing => false;
  @override bool get enableClickFeedback => true;
  @override bool get enableMousePassthrough => true;
  @override Color get clickFeedbackColor => _state.clickFeedbackColor;
  @override Color get rightClickFeedbackColor => _state.rightClickFeedbackColor;

  @override void setSelection(Rect? rect) => _notifier.setSelection(rect);
  @override void addAnnotation(Annotation annotation) => _notifier.addAnnotation(annotation);
  @override void updateLastAnnotation(Annotation annotation) => _notifier.updateLastAnnotation(annotation);
  @override void updateTargetedWindow(Rect? rect, String? name, [int? hwnd]) => _notifier.updateTargetedWindow(rect, name, hwnd);
  @override void confirmTargetWindow(Rect rect, String title) => _notifier.confirmTargetWindow(rect, title);

  @override
  Future<void> setIgnoreMouseEvents(bool ignore) => _notifier.setIgnoreMouseEvents(ignore);

  @override
  Future<void> cancelOverlay() => _notifier.cancelOverlay();
}

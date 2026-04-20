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
import '../../../ui/widgets/sqa_annotation_toolbar.dart';

class ScreenRecorderOverlay extends ConsumerStatefulWidget {
  const ScreenRecorderOverlay({super.key});

  @override
  ConsumerState<ScreenRecorderOverlay> createState() => _ScreenRecorderOverlayState();
}

class _ScreenRecorderOverlayState extends ConsumerState<ScreenRecorderOverlay> {
  final ValueNotifier<List<Annotation>> _annotationsNotifier = ValueNotifier([]);

  @override
  void dispose() {
    _annotationsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Structural properties that should trigger a full rebuild
    final isVisible = ref.watch(screenRecorderProvider.select((s) => s.isOverlayVisible));
    if (!isVisible) return const SizedBox.shrink();

    final isRecording = ref.watch(screenRecorderProvider.select((s) => s.isRecording));
    final currentTool = ref.watch(screenRecorderProvider.select((s) => s.currentTool));
    final annotationColor = ref.watch(screenRecorderProvider.select((s) => s.annotationColor));
    final countdownSeconds = ref.watch(screenRecorderProvider.select((s) => s.countdownSeconds));
    final delaySeconds = ref.watch(screenRecorderProvider.select((s) => s.delaySeconds));
    final microphoneEnabled = ref.watch(screenRecorderProvider.select((s) => s.microphoneEnabled));
    
    // UI structural changes that must trigger a rebuild
    ref.watch(screenRecorderProvider.select((s) => s.durationSeconds));
    ref.watch(screenRecorderProvider.select((s) => s.countdownSeconds));
    ref.watch(screenRecorderProvider.select((s) => s.selectionRect));
    ref.watch(screenRecorderProvider.select((s) => s.targetedWindowRect));
    ref.watch(screenRecorderProvider.select((s) => s.captureMode));
    ref.watch(screenRecorderProvider.select((s) => s.availableDisplays));
    ref.watch(screenRecorderProvider.select((s) => s.annotations));

    // 2. Listen to annotations to update the notifier WITHOUT rebuilding the skeleton
    ref.listen(screenRecorderProvider.select((s) => s.annotations), (prev, next) {
      if (prev != next) {
        _annotationsNotifier.value = next;
      }
    });

    final state = ref.read(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);

    // Initialize with current state if needed
    if (_annotationsNotifier.value != state.annotations) {
      _annotationsNotifier.value = state.annotations;
    }

    return SqaCaptureOverlay(
      delegate: _RecorderDelegate(state, notifier, _annotationsNotifier),
      toolbarBuilder: (context) => [
        // Record/Stop button
        SqaFloatingBarButton(
          icon: isRecording ? Symbols.stop_circle : Symbols.play_arrow,
          tooltip: isRecording ? 'Stop & Save' : 'Start',
          onPressed: () {
            notifier.toggleRecording();
          },
          isPrimary: !isRecording,
          color: isRecording ? Colors.red : null,
        ),

        if (!isRecording)
          SqaFloatingBarButton(
            icon: Symbols.close,
            tooltip: countdownSeconds > 0 ? 'Cancel Countdown' : 'Cancel Overlay',
            onPressed: () {
              if (countdownSeconds > 0) {
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
          icon: microphoneEnabled ? Symbols.mic : Symbols.mic_off,
          tooltip: 'Toggle Microphone',
          onPressed: isRecording ? null : () => notifier.toggleMicrophone(),
          isSelected: microphoneEnabled,
        ),

        // Delay selector (only before recording)
        if (!isRecording) ...[
          const SqaFloatingBarDivider(),
          SqaDropdown<int>(
            value: delaySeconds,
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

        if (isRecording) ...[
          const SqaFloatingBarDivider(),

          // Annotation Tools & Colors
          SqaAnnotationToolbar(
            enabledTools: const [
              ScreenshotTool.pointer,
              ScreenshotTool.pen,
              ScreenshotTool.marker,
              ScreenshotTool.arrow,
              ScreenshotTool.rectangle,
              ScreenshotTool.laser,
            ],
            currentTool: currentTool,
            onToolSelected: notifier.setTool,
            currentColor: annotationColor,
            onColorSelected: notifier.setColor,
            onClear: notifier.clearAnnotations,
          ),
        ],
      ],
    );
  }
}


class _RecorderDelegate implements CaptureOverlayDelegate {
  final ScreenRecorderState _state;
  final ScreenRecorderNotifier _notifier;
  final ValueNotifier<List<Annotation>> _annotationsNotifier;

  _RecorderDelegate(this._state, this._notifier, this._annotationsNotifier);

  @override bool get isOverlayVisible => _state.isOverlayVisible;
  @override bool get isTargetingWindow => _state.isTargetingWindow;
  @override CaptureMode get captureMode => _state.captureMode;
  @override Rect? get selectionRect => _state.selectionRect;
  @override Rect? get targetedWindowRect => _state.targetedWindowRect;
  @override String? get targetWindowName => _state.targetWindowName;
  @override List<Annotation> get annotations => _annotationsNotifier.value;
  @override Listenable? get annotationsChanged => _annotationsNotifier;
  @override Color get annotationColor => _state.annotationColor;
  @override ScreenshotTool get currentTool => _state.currentTool;
  @override Display? get lockedDisplay => _state.lockedDisplay;
  @override List<Display> get availableDisplays => _state.availableDisplays;

  @override void setSelection(Rect? rect, [Display? display]) => _notifier.setSelection(rect, display);
  @override bool get isRecording => _state.isRecording;
  @override bool get isPaused => _state.isPaused;
  @override int get durationSeconds => _state.durationSeconds;
  @override int get countdownSeconds => _state.countdownSeconds;
  @override bool get isCompactLayout => !_state.isRecording;
  
  @override bool get isCapturing => false;
  @override bool get enableClickFeedback => true;
  @override bool get enableMousePassthrough => true;
  @override Color get clickFeedbackColor => _state.clickFeedbackColor;
  @override Color get rightClickFeedbackColor => _state.rightClickFeedbackColor;

  @override void addAnnotation(Annotation annotation) => _notifier.addAnnotation(annotation);
  @override void updateLastAnnotation(Annotation annotation) => _notifier.updateLastAnnotation(annotation);
  @override void updateTargetedWindow(Rect? rect, String? name, [int? hwnd]) => _notifier.updateTargetedWindow(rect, name, hwnd);
  @override void confirmTargetWindow(Rect rect, String title) => _notifier.confirmTargetWindow(rect, title);

  @override
  Future<void> setIgnoreMouseEvents(bool ignore) => _notifier.setIgnoreMouseEvents(ignore);

  @override
  Future<void> cancelOverlay() => _notifier.cancelOverlay();
}

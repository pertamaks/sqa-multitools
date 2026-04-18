import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:screen_retriever/screen_retriever.dart';
import '../../../core/models/capture_overlay_delegate.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/models/annotation.dart';
import '../../../core/models/screenshot_tool.dart';
import '../providers/screenshot_provider.dart';
import '../models/screenshot_state.dart';
import '../../../ui/widgets/sqa_capture_overlay.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';

class ScreenshotOverlay extends ConsumerStatefulWidget {
  const ScreenshotOverlay({super.key});

  @override
  ConsumerState<ScreenshotOverlay> createState() => _ScreenshotOverlayState();
}

class _ScreenshotOverlayState extends ConsumerState<ScreenshotOverlay> {
  final ValueNotifier<List<Annotation>> _annotationsNotifier = ValueNotifier([]);

  @override
  void dispose() {
    _annotationsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Structural properties that should trigger a full rebuild
    final isVisible = ref.watch(screenshotProvider.select((s) => s.isOverlayVisible));
    if (!isVisible) return const SizedBox.shrink();

    final currentTool = ref.watch(screenshotProvider.select((s) => s.currentTool));
    final annotationColor = ref.watch(screenshotProvider.select((s) => s.annotationColor));
    final isCapturing = ref.watch(screenshotProvider.select((s) => s.isCapturing));

    // UI structural changes that must trigger a rebuild
    ref.watch(screenshotProvider.select((s) => s.selectionRect));
    ref.watch(screenshotProvider.select((s) => s.targetedWindowRect));
    ref.watch(screenshotProvider.select((s) => s.captureMode));
    ref.watch(screenshotProvider.select((s) => s.availableDisplays));

    // Listen to annotations to update the notifier WITHOUT rebuilding the skeleton
    ref.listen(screenshotProvider.select((s) => s.annotations), (prev, next) {
      if (prev != next) {
        _annotationsNotifier.value = next;
      }
    });

    final state = ref.read(screenshotProvider);
    final notifier = ref.read(screenshotProvider.notifier);

    // Initialize with current state if needed
    if (_annotationsNotifier.value != state.annotations) {
      _annotationsNotifier.value = state.annotations;
    }

    return SqaCaptureOverlay(
      delegate: _ScreenshotDelegate(state, notifier, _annotationsNotifier),
      toolbarBuilder: (context) => [
        ...[
          (ScreenshotTool.pen, Symbols.edit, 'Pen'),
          (ScreenshotTool.line, Symbols.horizontal_rule, 'Line'),
          (ScreenshotTool.arrow, Symbols.arrow_outward, 'Arrow'),
          (ScreenshotTool.marker, Symbols.brush, 'Highlighter'),
          (ScreenshotTool.rectangle, Symbols.rectangle, 'Rectangle'),
          (ScreenshotTool.text, Symbols.text_fields, 'Text'),
        ].map(
          (t) => SqaFloatingBarButton(
            icon: t.$2,
            tooltip: t.$3,
            isSelected: currentTool == t.$1,
            onPressed: () => notifier.setTool(t.$1),
          ),
        ),
        SqaFloatingBarButton(
          icon: Symbols.delete_sweep,
          tooltip: 'Clear All',
          onPressed: notifier.clearAnnotations,
        ),
        const SqaFloatingBarDivider(),
        ...[
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.white,
        ].map(
          (c) => SqaFloatingBarColorPicker(
            color: c,
            isSelected: annotationColor == c,
            onTap: () => notifier.setColor(c),
          ),
        ),
        const SqaFloatingBarDivider(),
        SqaFloatingBarButton(
          icon: Symbols.content_copy,
          tooltip: 'Copy to Clipboard',
          isLoading: isCapturing,
          onPressed: () => notifier.finalize(shouldCopy: true),
        ),
        SqaFloatingBarButton(
          icon: Symbols.save,
          tooltip: 'Save Screenshot',
          isLoading: isCapturing,
          onPressed: () => notifier.finalize(),
        ),
        SqaFloatingBarButton(
          icon: Symbols.close,
          tooltip: 'Cancel',
          onPressed: () {
            if (!isCapturing) {
              notifier.stopCapture();
            }
          },
          color: Colors.red,
        ),
      ],
    );
  }
}

class _ScreenshotDelegate implements CaptureOverlayDelegate {
  final ScreenshotState _state;
  final ScreenshotNotifier _notifier;
  final ValueNotifier<List<Annotation>> _annotationsNotifier;

  _ScreenshotDelegate(this._state, this._notifier, this._annotationsNotifier);

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
  @override List<Display> get availableDisplays => _state.availableDisplays;
  @override bool get isCapturing => _state.isCapturing;

  @override void setSelection(Rect? rect) => _notifier.setSelection(rect);
  @override void addAnnotation(Annotation annotation) => _notifier.addAnnotation(annotation);
  @override void updateLastAnnotation(Annotation annotation) => _notifier.updateLastAnnotation(annotation);
  @override void updateTargetedWindow(Rect? rect, String? name, [int? hwnd]) => _notifier.updateTargetedWindow(rect, name, hwnd);
  @override void confirmTargetWindow(Rect rect, String title) => _notifier.confirmTargetWindow(rect, title);

  // Defaults for non-recording plugin
  @override bool get isRecording => false;
  @override bool get isPaused => false;
  @override int get durationSeconds => 0;
  @override int get countdownSeconds => 0;
  @override bool get enableClickFeedback => false;
  @override bool get enableMousePassthrough => false;
  @override Color get clickFeedbackColor => Colors.white;
  @override Color get rightClickFeedbackColor => Colors.amber;
  @override Future<void> setIgnoreMouseEvents(bool ignore) async {}
  @override Future<void> cancelOverlay() => _notifier.stopCapture();
}

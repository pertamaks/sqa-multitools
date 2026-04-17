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

class ScreenshotOverlay extends ConsumerWidget {
  const ScreenshotOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenshotProvider);
    final notifier = ref.read(screenshotProvider.notifier);

    if (!state.isOverlayVisible) return const SizedBox.shrink();

    return SqaCaptureOverlay(
      delegate: _ScreenshotDelegate(state, notifier),
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
            isSelected: state.currentTool == t.$1,
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
            isSelected: state.annotationColor == c,
            onTap: () => notifier.setColor(c),
          ),
        ),
        const SqaFloatingBarDivider(),
        SqaFloatingBarButton(
          icon: Symbols.content_copy,
          tooltip: 'Copy to Clipboard',
          isLoading: state.isCapturing,
          onPressed: () => notifier.finalize(shouldCopy: true),
        ),
        SqaFloatingBarButton(
          icon: Symbols.save,
          tooltip: 'Save Screenshot',
          isLoading: state.isCapturing,
          onPressed: () => notifier.finalize(),
        ),
        SqaFloatingBarButton(
          icon: Symbols.close,
          tooltip: 'Cancel',
          onPressed: () {
            if (!state.isCapturing) {
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

  _ScreenshotDelegate(this._state, this._notifier);

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

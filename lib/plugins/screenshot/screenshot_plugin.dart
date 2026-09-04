import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../core/models/sqa_plugin.dart';
import '../../core/models/sqa_coachmark_step.dart';
import 'ui/screenshot_view.dart';
import 'ui/screenshot_settings.dart';

class ScreenshotPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.screenshot';
  @override
  String get name => 'Screenshot';
  @override
  String get description => 'Take partial or full screenshots.';
  @override
  IconData get icon => Symbols.crop;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [
        PermissionRequirement.screenRecording,
      ];

  @override
  List<SqaCoachmarkStep> get coachmarkSteps => [
        SqaCoachmarkStep(
          targetKey: ScreenshotView.captureModeKey,
          title: 'Three Ways to Capture',
          description:
              'Full Screen grabs the whole monitor. Area lets you draw a selection. Long Screenshot scrolls and stitches a tall page into one image.',
          contentAlign: CoachmarkContentAlign.top,
        ),
        SqaCoachmarkStep(
          targetKey: ScreenshotView.captureButtonKey,
          title: 'Mark It Up Instantly',
          description:
              'After capturing, a floating toolbar appears with drawing tools. Draw arrows, boxes, or text directly on the screenshot before saving.',
          contentAlign: CoachmarkContentAlign.top,
        ),
        SqaCoachmarkStep(
          targetKey: ScreenshotView.historyKey,
          title: 'All Captures Are Here',
          description:
              'Every screenshot is listed below. Use the ⋮ menu to open, rename, or delete any capture.',
          contentAlign: CoachmarkContentAlign.top,
          beforeStepAction: (ref) async {
            final context = ScreenshotView.historyKey.currentContext;
            if (context != null) {
              Scrollable.ensureVisible(
                context,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
              );
              await Future<void>.delayed(const Duration(milliseconds: 350));
            }
          },
        ),
      ];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const ScreenshotView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const ScreenshotSettings();
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

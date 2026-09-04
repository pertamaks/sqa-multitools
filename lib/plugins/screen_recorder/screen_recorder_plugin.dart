import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import './ui/screen_recorder_view.dart';
import './ui/screen_recorder_settings.dart';
import '../../core/models/sqa_coachmark_step.dart';

class ScreenRecorderPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.screen_recorder';
  @override
  String get name => 'Screen Recorder';
  @override
  String get description => 'Capture your workflow in high quality.';
  @override
  IconData get icon => Symbols.videocam;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const ScreenRecorderView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const ScreenRecorderSettings();
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}

  @override
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: ScreenRecorderView.captureModeKey,
        title: 'Choose What to Record',
        description:
            'Pick Full Screen to capture everything, or Area to draw a region on your screen. Your last setting is remembered.',
        contentAlign: CoachmarkContentAlign.top,
      ),
      SqaCoachmarkStep(
        targetKey: ScreenRecorderView.recordButtonKey,
        title: 'Hit Record',
        description:
            'Press this to start. A floating control bar will appear on your screen so you can pause or stop without switching back to this window.',
        contentAlign: CoachmarkContentAlign.top,
      ),
      SqaCoachmarkStep(
        targetKey: ScreenRecorderView.historyKey,
        title: 'Your Recordings Are Saved Here',
        description:
            'Find every capture here. Tap the ⋮ menu on any recording to open, rename, or delete it.',
        contentAlign: CoachmarkContentAlign.top,
        beforeStepAction: (ref) async {
          final context = ScreenRecorderView.historyKey.currentContext;
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
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_faker_locale_picker.dart';
import '../../ui/widgets/sqa_design_tokens.dart';
import '../../core/models/sqa_coachmark_step.dart';
import 'ui/curl_requester_view.dart';

class CurlRequesterPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.curl_requester';

  @override
  String get name => 'cURL Requester';

  @override
  @override
  String get description => 'Quickly test and transform cURL commands.';

  @override
  IconData get icon => Symbols.terminal;

  @override
  String? get badge => null;

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const CurlRequesterView();
  }

  @override
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: CurlRequesterView.urlInputKey,
        title: 'The Command Deck',
        description:
            'Paste any raw cURL command here and watch it instantly parse into a structured request. Or build it visually and see the cURL update in real-time.',
        contentAlign: CoachmarkContentAlign.top,
      ),
      SqaCoachmarkStep(
        targetKey: CurlRequesterView.showGridKey,
        title: 'Structured Editing',
        description:
            'Switch to the Grid view to safely edit headers, query parameters, and auth tokens without breaking command syntax. Supports variables like {{TOKEN}}.',
        contentAlign: CoachmarkContentAlign.bottom,
        beforeStepAction: (ref) async {
          // No complex action needed, just point to the grid which is rendered when showReflector=true (but we can just point to the grid container).
          // Actually, we should make sure we are on Tab 0 (Request)
        },
      ),
      SqaCoachmarkStep(
        targetKey: CurlRequesterView.mainTabsKey,
        title: 'History & Saved Requests',
        description:
            'Every request is saved automatically. Access your past transactions, replay them, or save frequent ones for quick access.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
    ];
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SqaTokens.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [SqaFakerLocalePicker()],
      ),
    );
  }

  @override
  Future<void> initialize() async {
    // Pre-load assets if needed
  }

  @override
  Future<void> dispose() async {
    // Clean up
  }

  @override
  List<PermissionRequirement> get requiredPermissions => [];
}

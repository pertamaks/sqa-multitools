import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../core/models/sqa_plugin.dart';
import './ui/beautifier_view.dart';
import './ui/beautifier_settings.dart';
import '../../core/models/sqa_coachmark_step.dart';

class BeautifierPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.beautifier';
  @override
  String get name => 'Beautifier';
  @override
  String get description => 'Format and beautify code for various languages.';
  @override
  IconData get icon => Symbols.code_blocks;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const BeautifierView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const BeautifierSettings();
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}

  @override
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: BeautifierView.languageSelectorKey,
        title: 'Pick Your Language First',
        description:
            'Select the language (JSON, SQL, XML, YAML, Dart, JS, CSS, HTML) before pasting your code. This determines which formatting engine is used.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: BeautifierView.inputFieldKey,
        title: 'Paste Your Messy Code Here',
        description:
            'Paste any raw or minified code into this field. Press Format (or enable Auto-Format) and the beautified result instantly appears.',
        contentAlign: CoachmarkContentAlign.top,
      ),
      SqaCoachmarkStep(
        targetKey: BeautifierView.formatButtonKey,
        title: 'Format and Copy',
        description:
            'Press this button to format the code. The output will pop up in a new window where you can easily copy it with syntax highlighting applied.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
    ];
  }
}

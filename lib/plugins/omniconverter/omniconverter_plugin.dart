import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import '../../core/models/sqa_coachmark_step.dart';
import 'ui/omniconverter_view.dart';
import 'ui/omniconverter_settings.dart';

class OmniConverterPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.omniconverter';

  @override
  String get name => 'OmniConverter';

  @override
  String get description =>
      'All-in-one data transformation: Base64, URL, JSON, YAML, XML, JWT, Hash, and Text Case.';

  @override
  IconData get icon => Symbols.sync_alt;

  @override
  String? get badge => null;

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const OmniConverterView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const OmniConverterSettings();
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: OmniConverterView.categorySelectorKey,
        title: 'Choose Conversion Category',
        description:
            'Select the transformation category you need: Encodings (Base64/URL/HTML/Hex), Formats (JSON ↔ YAML/XML), JWT Token Inspector, Hash Generator, or Text Case.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: OmniConverterView.inputFieldKey,
        title: 'Enter Raw Input Data',
        description:
            'Type or paste raw text, JWT tokens, JSON payloads, or strings here. Character and line counters update in real time.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: OmniConverterView.controlToolbarKey,
        title: 'Direction & Quick Actions',
        description:
            'Use the Swap button to reverse the transformation (e.g., Encode ↔ Decode), or pick your desired target format options.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: OmniConverterView.convertButtonKey,
        title: 'Convert & View Output Modal',
        description:
            'Click this button to transform the input data. The result will pop up in a dedicated modal where you can easily inspect and copy it with line numbers.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
    ];
  }


}

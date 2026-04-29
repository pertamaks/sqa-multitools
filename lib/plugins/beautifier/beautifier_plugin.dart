import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import '../../core/models/sqa_plugin.dart';
import './ui/beautifier_view.dart';
import './ui/beautifier_settings.dart';

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
}

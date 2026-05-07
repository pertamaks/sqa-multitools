import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../core/models/sqa_plugin.dart';
import 'ui/settings_view.dart';

class SettingsPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.settings';
  @override
  String get name => 'Settings';
  @override
  String get description => 'Configure SQA-Multitools.';
  @override
  IconData get icon => Symbols.settings;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const SettingsView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(
      child: Text('Settings Logic Error'),
    ); // Self-referential protection
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

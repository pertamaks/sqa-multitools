import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../core/models/sqa_plugin.dart';
import 'ui/screenshot_view.dart';

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
  String? get badge => 'ALPHA';
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const ScreenshotView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Screenshot Settings'));
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

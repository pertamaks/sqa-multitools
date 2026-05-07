import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import './ui/screen_recorder_view.dart';
import './ui/screen_recorder_settings.dart';

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
}

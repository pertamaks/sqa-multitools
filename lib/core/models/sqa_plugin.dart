import 'package:flutter/material.dart';

enum PermissionRequirement { screenRecording, accessibility, clipboard }

abstract class SqaPlugin {
  /// Unique identifier (e.g., "com.sqa.plugin.timer")
  String get id;

  /// Display name in settings
  String get name;

  /// Short description of what the tool does
  String get description;

  /// Icon displayed on the main toolbar
  IconData get icon;

  /// Optional badge text (e.g., 'BETA', 'PRO')
  String? get badge;

  /// The UI that opens beneath the toolbar when the icon is clicked
  Widget buildPluginWindow(BuildContext context);

  /// The UI injected into the main Settings window
  Widget buildSettingsPanel(BuildContext context);

  /// Called when the app starts.
  Future<void> initialize();

  /// Called when the app closes or plugin is disabled
  Future<void> dispose();

  /// A list of OS capabilities this plugin needs
  List<PermissionRequirement> get requiredPermissions;
}

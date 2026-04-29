import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import './ui/security_payloads_view.dart';

class SecurityPayloadsPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.security_payloads';
  @override
  String get name => 'Security Payloads';
  @override
  String get description => 'Common security testing & fuzzing payloads.';
  @override
  IconData get icon => Symbols.security;

  @override
  String? get badge => null;

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const SecurityPayloadsView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Security Payloads Settings'));
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

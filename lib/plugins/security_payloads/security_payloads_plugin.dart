import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  Future<void> initialize() async {
    try {
      await rootBundle.loadString('assets/security_payload.md');
    } catch (e) {
      debugPrint('Warning: Failed to warm up security payload asset: $e');
    }
  }

  @override
  Future<void> dispose() async {}
}

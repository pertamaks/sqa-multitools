import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'ui/qa_cheatsheet_view.dart';

class QaCheatsheetPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.qa_cheatsheet';

  @override
  String get name => 'QA Cheatsheet';

  @override
  String get description =>
      'Comprehensive quality assurance reference compilation';

  @override
  IconData get icon => Symbols.menu_book;

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const QaCheatsheetView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('QA Cheatsheet Settings'));
  }

  @override
  Future<void> initialize() async {
    // Warm up the cheatsheet asset cache to prevent first-load stutter
    // in the high-fidelity markdown viewer.
    try {
      await rootBundle.loadString('assets/qa_cheatsheet_comp.md');
    } catch (e) {
      debugPrint('Warning: Failed to warm up cheatsheet asset: $e');
    }
  }

  @override
  Future<void> dispose() async {
    // Cleanup if needed
  }

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  String? get badge => null;
}

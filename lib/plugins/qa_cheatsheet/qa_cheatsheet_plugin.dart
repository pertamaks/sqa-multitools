import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import '../../core/models/sqa_coachmark_step.dart';
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
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: QaCheatsheetView.categoryTabsKey,
        title: 'Categorized Knowledge',
        description:
            'Navigate between broad testing domains — Web, Mobile, API, and Security. Each domain contains curated checklists, heuristics, and attack vectors.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: QaCheatsheetView.sectionSwitcherKey,
        title: 'Switch Topics Quickly',
        description:
            'Use these tabs to dive into specific topics within a domain. The content features syntax-highlighted code blocks, tables, and copy buttons for immediate use.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
    ];
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

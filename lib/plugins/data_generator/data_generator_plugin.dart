import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'ui/identity_tab_view.dart';
import 'ui/lorem_tab_view.dart';
import 'ui/glyphs_tab_view.dart';
import 'ui/dev_tab_view.dart';
import 'ui/settings_panel.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';

class DataGeneratorPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.data_generator';
  @override
  String get name => 'Data Generator';
  @override
  String get description => 'Generate mock UUIDs, emails, etc.';
  @override
  IconData get icon => Symbols.wand_stars;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _DataGeneratorView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const DataGeneratorSettingsPanel();
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _DataGeneratorView extends StatelessWidget {
  const _DataGeneratorView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SqaPluginLayout(
        icon: Symbols.wand_stars,
        title: 'Data Generator',
        description: 'Generate mock UUIDs, emails, numbers, and more.',
        tabs: const [
          Tab(icon: Icon(Symbols.person), text: 'Identity'),
          Tab(icon: Icon(Symbols.notes), text: 'Lorem'),
          Tab(icon: Icon(Symbols.glyphs), text: 'Glyphs'),
          Tab(icon: Icon(Symbols.terminal), text: 'Dev'),
        ],
        child: const TabBarView(
          children: [
            IdentityTabView(),
            LoremTabView(),
            GlyphsTabView(),
            DevTabView(),
          ],
        ),
      ),
    );
  }
}

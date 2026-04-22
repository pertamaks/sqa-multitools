import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'providers/md_editor_provider.dart';
import 'models/md_editor_state.dart';
import 'ui/md_list_view.dart';
import 'ui/md_editor_view.dart';

class MdEditorPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.md_editor';

  @override
  String get name => 'MD Editor';

  @override
  String get description => 'A premium Markdown editor for bug reports and dev tickets.';

  @override
  IconData get icon => Symbols.edit_note;

  @override
  String? get badge => 'ALPHA';

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Future<void> initialize() async {
    // TODO: Pre-load documents from storage
  }

  @override
  Future<void> dispose() async {}

  @override
  Widget buildPluginWindow(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(mdEditorProvider);
        
        switch (state.viewMode) {

          case MdEditorViewMode.editor:
            return const MdEditorView();
          case MdEditorViewMode.list:
            return const MdListView();
        }
      },
    );
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('MD Editor Settings'));
  }
}

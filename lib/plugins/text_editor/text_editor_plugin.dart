import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'providers/text_editor_provider.dart';
import 'models/text_editor_state.dart';
import 'ui/text_list_view.dart';
import 'ui/text_editor_view.dart';

class TextEditorPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.text_editor';

  @override
  String get name => 'Text Editor';

  @override
  String get description => 'A premium Text Editor for bug reports and dev tickets.';

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
        final state = ref.watch(textEditorProvider);
        
        switch (state.viewMode) {
          case TextEditorViewMode.editor:
            return const TextEditorView();
          case TextEditorViewMode.list:
            return const TextListView();
        }
      },
    );
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Text Editor Settings'));
  }
}

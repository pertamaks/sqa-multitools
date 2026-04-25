import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'providers/text_editor_provider.dart';
import 'models/text_editor_state.dart';
import 'ui/text_list_view.dart';
import 'ui/text_editor_view.dart';

import 'package:file_selector/file_selector.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_settings_tile.dart';

class TextEditorPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.text_editor';

  @override
  String get name => 'Text Editor';

  @override
  String get description =>
      'A premium Text Editor for bug reports and dev tickets.';

  @override
  IconData get icon => Symbols.edit_note;

  @override
  String? get badge => 'ALPHA';

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Future<void> initialize() async {}

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
    return const _TextEditorSettings();
  }
}

class _TextEditorSettings extends ConsumerWidget {
  const _TextEditorSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(textEditorProvider);
    final notifier = ref.read(textEditorProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'STORAGE CONFIGURATION',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.folder,
                title: 'Save Directory',
                subtitle: state.savePath ?? 'Documents/SQA_Notes (Default)',
                trailing: IconButton(
                  icon: const Icon(Symbols.edit, size: 16),
                  onPressed: () async {
                    final directoryPath = await getDirectoryPath(
                      initialDirectory: state.savePath,
                      confirmButtonText: 'Select Notes Folder',
                    );
                    if (directoryPath != null) {
                      notifier.changeSavePath(directoryPath);
                    }
                  },
                  tooltip: 'Change Save Directory',
                ),
              ),
              const Divider(height: 1),
              SqaSettingsTile(
                icon: Symbols.format_list_numbered,
                title: 'Document Limit',
                subtitle: 'Max documents allowed',
                trailing: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    '${state.maxDocuments}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'providers/text_editor_provider.dart';
import 'models/text_editor_state.dart';
import 'models/text_document.dart';
import 'ui/text_list_view.dart';
import 'ui/text_editor_view.dart';
import '../../core/models/sqa_coachmark_step.dart';

import 'package:file_selector/file_selector.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_hover_icon_button.dart';
import '../../ui/widgets/sqa_design_tokens.dart';

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
  String? get badge => null;

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: TextListView.listKey,
        title: 'Your Documents',
        description:
            'All your saved notes and reports live here. Tap any document to open it. Pin important ones to keep them at the top.',
        contentAlign: CoachmarkContentAlign.top,
      ),
      SqaCoachmarkStep(
        targetKey: TextListView.newDocKey,
        title: 'Start from a Template',
        description:
            'Create a blank note, a structured Bug Report, or a Dev Ticket — pre-filled with the right sections so you never have to format from scratch.',
        contentAlign: CoachmarkContentAlign.top,
        beforeStepAction: (ref) async {
          ref
              .read(textEditorProvider.notifier)
              .setViewMode(TextEditorViewMode.list);
        },
      ),
      SqaCoachmarkStep(
        targetKey: TextEditorView.editorKey,
        title: 'Write Like a Pro',
        description:
            'This is a live Markdown editor — bold, tables, code blocks, and links are styled as you type. Your work is auto-saved and exports to a clean .md file.',
        contentAlign: CoachmarkContentAlign.top,
        beforeStepAction: (ref) async {
          ref.read(textEditorProvider.notifier).createFromTemplate(
            TextTemplateType.empty,
          );
        },
      ),
    ];
  }

  @override
  Widget buildPluginWindow(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(textEditorProvider);

        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        switch (state.viewMode) {
          case TextEditorViewMode.editor:
          case TextEditorViewMode.viewer:
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
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: Text(
            'STORAGE CONFIGURATION',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SqaTokens.fontSizeSmall,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: SqaTokens.spacingXXLarge),
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.folder,
                title: 'Save Directory',
                subtitle: state.savePath ?? 'Documents/SQA_Notes (Default)',
                trailing: SqaHoverIconButton(
                  icon: Symbols.edit,
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
                  iconSize: SqaTokens.spacingLarge,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

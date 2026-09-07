import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'providers/obfuscator_provider.dart';
import 'models/obfuscator_state.dart';
import 'ui/obfuscator_list_view.dart';
import 'ui/obfuscator_view.dart';
import '../../core/models/sqa_coachmark_step.dart';
import 'models/imported_document.dart';

import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_hover_icon_button.dart';
import '../../ui/widgets/sqa_design_tokens.dart';
import 'package:file_selector/file_selector.dart';

class RequirementObfuscatorPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.requirement_obfuscator';

  @override
  String get name => 'Doc Obfuscator';

  @override
  String get description =>
      'Obfuscate and de-obfuscate sensitive terms in documents.';

  @override
  IconData get icon => Symbols.shield_lock;

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
        targetKey: ObfuscatorListView.workspaceSelectorKey,
        title: 'Organize by Project',
        description:
            'Each workspace is an isolated project with its own dictionary. Create separate workspaces for different clients or products to keep substitutions clean.',
        contentAlign: CoachmarkContentAlign.bottom,
        spotlightPadding: const EdgeInsets.fromLTRB(4, 0, 4, 3),
        beforeStepAction: (ref) async {
          final state = ref.read(obfuscatorProvider);
          if (state.viewMode != ObfuscatorViewMode.list) {
            ref.read(obfuscatorProvider.notifier).setViewMode(ObfuscatorViewMode.list);
            while (ref.read(obfuscatorProvider).isLoading) {
              await Future<void>.delayed(const Duration(milliseconds: 50));
            }
          }
          final context = ObfuscatorListView.tabBarKey.currentContext;
          if (context != null && context.mounted) {
            final tabController = DefaultTabController.maybeOf(context);
            if (tabController != null && tabController.index != 0) {
              tabController.animateTo(0);
              await Future<void>.delayed(const Duration(milliseconds: 300));
            }
          }
        },
      ),
      SqaCoachmarkStep(
        targetKey: ObfuscatorDocumentView.editorKey,
        title: 'Paste Your Requirements Here',
        description:
            'Paste your spec or bug report, then toggle the Obfuscate switch. The scanner automatically finds sensitive terms and replaces them with realistic-looking alternatives.',
        contentAlign: CoachmarkContentAlign.top,
        beforeStepAction: (ref) async {
          final notifier = ref.read(obfuscatorProvider.notifier);
          final dummy = ImportedDocument(
            id: 'dummy',
            fileName: 'Example Document',
            content: 'Paste your content here...',
            importedAt: DateTime.now(),
          );
          notifier.viewDocument(dummy);
        },
      ),
      SqaCoachmarkStep(
        targetKey: ObfuscatorListView.dictionaryPanelKey,
        title: 'Review & Manage Substitutions',
        description:
            'Every detected term appears here with its replacement. You can enable, disable, or delete individual entries — or highlight any word in the document to add it manually.',
        contentAlign: CoachmarkContentAlign.top,
        beforeStepAction: (ref) async {
          final state = ref.read(obfuscatorProvider);
          if (state.viewMode != ObfuscatorViewMode.list) {
            ref.read(obfuscatorProvider.notifier).setViewMode(ObfuscatorViewMode.list);
            while (ref.read(obfuscatorProvider).isLoading) {
              await Future<void>.delayed(const Duration(milliseconds: 50));
            }
          }
          if (ref.read(obfuscatorProvider).dictionary.isEmpty &&
              ref.read(obfuscatorProvider).activeWorkspace != null) {
            await ref.read(obfuscatorProvider.notifier).addDictionaryEntry(
              original: 'Acme Corp',
              replacement: 'Company XYZ',
            );
          }
          final context = ObfuscatorListView.tabBarKey.currentContext;
          if (context != null && context.mounted) {
            final tabController = DefaultTabController.maybeOf(context);
            if (tabController != null && tabController.index != 2) {
              tabController.animateTo(2); // Index 2 is Dictionary
              await Future<void>.delayed(const Duration(milliseconds: 300));
            }
          }
        },
      ),
    ];
  }

  @override
  Widget buildPluginWindow(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(obfuscatorProvider);

        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }

        switch (state.viewMode) {
          case ObfuscatorViewMode.viewer:
            return const ObfuscatorDocumentView();
          case ObfuscatorViewMode.list:
            return const ObfuscatorListView();
        }
      },
    );
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const _ObfuscatorSettings();
  }
}

class _ObfuscatorSettings extends ConsumerWidget {
  const _ObfuscatorSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(obfuscatorProvider);
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
                title: 'Storage Directory',
                subtitle:
                    state.savePath ?? 'Documents/SQA_Obfuscator (Default)',
                trailing: SqaHoverIconButton(
                  icon: Symbols.edit,
                  onPressed: () async {
                    final directoryPath = await getDirectoryPath(
                      initialDirectory: state.savePath,
                      confirmButtonText: 'Select Obfuscator Folder',
                    );
                    if (directoryPath != null) {
                      // TODO(Logic): Implement changeSavePath
                    }
                  },
                  tooltip: 'Change Storage Directory',
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

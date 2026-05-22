import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'providers/obfuscator_provider.dart';
import 'models/obfuscator_state.dart';
import 'ui/obfuscator_list_view.dart';
import 'ui/obfuscator_view.dart';

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

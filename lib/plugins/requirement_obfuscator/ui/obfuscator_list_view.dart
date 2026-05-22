import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import 'package:file_selector/file_selector.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_smart_text.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_popup_menu.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../ui/widgets/sqa_dropdown.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../text_editor/ui/widgets/code_block_builder.dart';
import '../../text_editor/ui/widgets/table_block_builder.dart';
import '../../text_editor/ui/widgets/quote_block_builder.dart';
import '../../text_editor/ui/widgets/html_block_builder.dart';
import '../../text_editor/ui/widgets/image_block_builder.dart';
import '../../text_editor/ui/widgets/table_node_loader_parser.dart';
import '../../text_editor/ui/widgets/html_node_loader_parser.dart';
import '../../text_editor/ui/widgets/image_node_encoder_parser.dart';

import '../providers/obfuscator_provider.dart';
import '../models/imported_document.dart';
import '../models/obfuscator_state.dart';
import '../models/dictionary_entry.dart';

/// Document list view for the Obfuscator plugin.
/// Modeled after TextListView — shows imported documents in a list.
class ObfuscatorListView extends ConsumerStatefulWidget {
  const ObfuscatorListView({super.key});

  @override
  ConsumerState<ObfuscatorListView> createState() => _ObfuscatorListViewState();
}

class _ObfuscatorListViewState extends ConsumerState<ObfuscatorListView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(obfuscatorProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(obfuscatorProvider);
    final filteredDocs = ref.watch(filteredObfuscatorDocumentsProvider);
    final filteredDict = ref.watch(filteredObfuscatorDictionaryProvider);
    final notifier = ref.read(obfuscatorProvider.notifier);
    final theme = Theme.of(context);

    if (state.activeWorkspace == null) {
      return SqaPluginLayout(
        icon: Symbols.shield_lock,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Obfuscator',
              style: GoogleFonts.dmSans(
                fontSize: SqaTokens.fontSizeXLarge,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Obfuscate sensitive terms in your documents.',
              style: GoogleFonts.dmSans(
                fontSize: SqaTokens.fontSizeSmall,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        child: SqaPluginScrollableContent(
          child: _buildNoWorkspaceState(context, notifier),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: SqaPluginLayout(
        icon: Symbols.shield_lock,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document Obfuscator',
              style: GoogleFonts.dmSans(
                fontSize: SqaTokens.fontSizeXLarge,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Text(
                  'Workspace: ',
                  style: GoogleFonts.dmSans(
                    fontSize: SqaTokens.fontSizeSmall,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                _buildWorkspaceSelector(context, state, notifier),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SqaHoverIconButton(
              icon: Symbols.refresh,
              onPressed: () => notifier.initialize(),
              tooltip: 'Refresh list',
              iconSize: SqaTokens.spacingXLarge,
            ),
            const SizedBox(width: SqaTokens.spacingXSmall),
            SqaButton(
              label: '',
              tooltip: 'Add Entry',
              icon: Symbols.add,
              onPressed: () => _showAddEntryDialog(context, notifier),
              type: SqaButtonType.primary,
            ),
          ],
        ),
        tabs: const [
          Tab(icon: Icon(Symbols.description), text: 'Documents'),
          Tab(icon: Icon(Symbols.lock_open), text: 'De-obfuscator'),
          Tab(icon: Icon(Symbols.menu_book), text: 'Dictionary'),
        ],
        searchController: _searchController,
        onSearchChanged: (value) => notifier.setSearchQuery(value),
        searchHint: 'Search...',
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Tab 1: Documents
            SqaPluginScrollableContent(
              child: state.documents.isEmpty
                  ? _buildEmptyState(context, notifier)
                  : Column(
                      children: [
                        if (filteredDocs.isEmpty)
                          _buildNoResultsState(context)
                        else
                          ...filteredDocs.map((doc) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: SqaTokens.spacingMedium,
                              ),
                              child: SqaCard(
                                onTap: () => notifier.viewDocument(doc),
                                child: Row(
                                  children: [
                                    _buildFileIcon(context, doc),
                                    const SizedBox(
                                      width: SqaTokens.spacingLarge,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SqaSmartText(
                                            text: doc.fileName,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                          const SizedBox(
                                            height: SqaTokens.spacingXSmall,
                                          ),
                                          Text(
                                            'Imported: ${DateFormat.yMMMd().add_Hm().format(doc.importedAt)}',
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                      .withValues(alpha: 0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildActions(context, notifier, doc),
                                  ],
                                ),
                              ),
                            );
                          }),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: SqaTokens.spacingSmall,
                            bottom: SqaTokens.spacingXLarge,
                          ),
                          child: _buildOpenFolderButton(context, notifier),
                        ),
                      ],
                    ),
            ),
            // Tab 2: De-obfuscator
            const DeobfuscatorTabContent(),
            // Tab 3: Dictionary Manager
            SqaPluginScrollableContent(
              child: _buildDictionaryTab(
                context,
                state,
                filteredDict,
                notifier,
                theme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWorkspaceState(BuildContext context, Obfuscator notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(
          Symbols.workspaces,
          size: 48,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(height: SqaTokens.spacingLarge),
        Text(
          'No workspace selected',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: SqaTokens.spacingSmall),
        Text(
          'Create a workspace to start obfuscating documents.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: SqaTokens.spacingXLarge),
        SqaButton(
          label: 'Create Workspace',
          icon: Symbols.add,
          onPressed: () => _showCreateWorkspaceDialog(context, notifier),
          type: SqaButtonType.tonal,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, Obfuscator notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(
          Symbols.upload_file,
          size: 48,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(height: SqaTokens.spacingLarge),
        Text(
          'No documents imported',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: SqaTokens.spacingSmall),
        Text(
          'Import a Markdown or text file to get started.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: SqaTokens.spacingXLarge),
        _buildImportButton(
          context,
          notifier,
          type: SqaButtonType.tonal,
          showLabel: true,
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
        _buildOpenFolderButton(context, notifier),
      ],
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Column(
        children: [
          Icon(
            Symbols.search_off,
            size: SqaTokens.spacingXXXLarge,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: SqaTokens.spacingLarge),
          Text(
            'No documents match your search',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
          Text(
            'Try adjusting your keywords or clearing the search.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildFileIcon(BuildContext context, ImportedDocument doc) {
    final isMarkdown =
        doc.fileName.endsWith('.md') || doc.fileName.endsWith('.markdown');
    return Container(
      padding: const EdgeInsets.all(SqaTokens.spacingSmall),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: SqaStyles.radiusMedium,
      ),
      child: Icon(
        isMarkdown ? Symbols.markdown : Symbols.description,
        size: SqaTokens.spacingXLarge,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    Obfuscator notifier,
    ImportedDocument doc,
  ) {
    final theme = Theme.of(context);

    return SqaPopupMenu(
      alignmentOffset: const Offset(-100, SqaTokens.spacingSmall),
      tooltip: 'Actions',
      icon: Symbols.more_vert,
      children: [
        SqaPopupMenuItem(
          icon: const Icon(Symbols.visibility),
          label: 'View Document',
          onPressed: () => notifier.viewDocument(doc),
        ),
        SqaPopupMenuItem(
          icon: const Icon(Symbols.content_copy),
          label: 'Copy Content',
          onPressed: () async {
            await notifier.copyContent(doc.content);
            if (!context.mounted) return;
            SqaToast.show(
              context,
              'Content copied to clipboard',
              type: SqaToastType.success,
            );
          },
        ),
        Divider(
          height: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        SqaPopupMenuItem(
          icon: const Icon(Symbols.delete),
          label: 'Remove',
          isDestructive: true,
          onPressed: () async {
            final confirm = await SqaModal.showConfirm(
              context,
              title: 'Remove Document',
              message:
                  'Are you sure you want to remove "${doc.fileName}"? This action cannot be undone.',
              confirmLabel: 'Remove',
              confirmColor: theme.colorScheme.error,
              icon: Symbols.delete_forever,
            );
            if (confirm == true) {
              notifier.deleteDocument(doc.id);
            }
          },
        ),
      ],
    );
  }

  Widget _buildImportButton(
    BuildContext context,
    Obfuscator notifier, {
    SqaButtonType type = SqaButtonType.primary,
    bool showLabel = false,
  }) {
    return SqaButton(
      label: showLabel ? 'Import Document' : '',
      icon: Symbols.upload_file,
      type: type,
      tooltip: 'Import document',
      onPressed: () async {
        const typeGroup = XTypeGroup(
          label: 'Documents',
          extensions: ['md', 'txt', 'json', 'yaml', 'yml'],
        );
        final file = await openFile(acceptedTypeGroups: [typeGroup]);
        if (file != null) {
          await notifier.importDocument(file.path);
        }
      },
    );
  }

  Widget _buildOpenFolderButton(
    BuildContext context,
    Obfuscator notifier, {
    SqaButtonType type = SqaButtonType.tonal,
  }) {
    return SqaButton(
      label: 'Open Storage Folder',
      icon: Symbols.folder_open,
      onPressed: () => notifier.openSaveFolder(),
      type: type,
    );
  }

  Future<void> _showCreateWorkspaceDialog(
    BuildContext context,
    Obfuscator notifier,
  ) async {
    final result = await SqaModal.showPrompt(
      context,
      title: 'Create Workspace',
      message: 'Enter a name for the new workspace:',
      confirmLabel: 'Create',
      icon: Symbols.workspaces,
    );
    if (result != null && result.isNotEmpty) {
      await notifier.createWorkspace(result);
    }
  }

  Widget _buildWorkspaceSelector(
    BuildContext context,
    ObfuscatorState state,
    Obfuscator notifier,
  ) {
    final theme = Theme.of(context);

    return SqaPopupMenu(
      icon: Symbols.workspaces,
      tooltip: 'Switch Workspace',
      alignmentOffset: const Offset(0, SqaTokens.spacingSmall),
      builder: (context, controller, child) {
        return InkWell(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          borderRadius: SqaTokens.borderRadiusSmall,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SqaTokens.spacingXSmall,
              vertical: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.activeWorkspace?.name ?? 'Select Workspace',
                  style: GoogleFonts.dmSans(
                    fontSize: SqaTokens.fontSizeSmall,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Symbols.arrow_drop_down,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
      children: [
        ...state.workspaces.map((workspace) {
          final isSelected = state.activeWorkspace?.id == workspace.id;
          return SqaPopupMenuItem(
            onPressed: () => notifier.selectWorkspace(workspace),
            icon: Icon(
              Symbols.workspaces,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            label: workspace.name,
          );
        }),
        const Divider(height: 1),
        SqaPopupMenuItem(
          onPressed: () => _showCreateWorkspaceDialog(context, notifier),
          icon: Icon(Symbols.add, color: theme.colorScheme.primary),
          label: 'New Workspace',
        ),
      ],
    );
  }

  Widget _buildDictionaryTab(
    BuildContext context,
    ObfuscatorState state,
    List<DictionaryEntry> entries,
    Obfuscator notifier,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: Row(
            children: [
              Text(
                'DICTIONARY RULES',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              SqaHoverIconButton(
                icon: Symbols.delete_sweep,
                onPressed: () async {
                  final confirm = await SqaModal.showConfirm(
                    context,
                    title: 'Clear Dictionary',
                    message:
                        'Are you sure you want to delete all replacement rules in this workspace? This action cannot be undone.',
                    confirmLabel: 'Clear All',
                    confirmColor: theme.colorScheme.error,
                    icon: Symbols.delete_sweep,
                  );
                  if (confirm == true) {
                    await notifier.clearDictionary();
                    if (context.mounted) {
                      SqaToast.show(
                        context,
                        'All dictionary rules cleared successfully',
                        type: SqaToastType.success,
                      );
                    }
                  }
                },
                tooltip: 'Clear All Rules',
                color: theme.colorScheme.error,
                iconSize: SqaTokens.spacingXLarge,
              ),
            ],
          ),
        ),
        if (state.dictionary.isEmpty)
          _buildEmptyDictionaryState(context, notifier)
        else if (entries.isEmpty)
          _buildNoResultsState(context)
        else
          ...entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: SqaTokens.spacingSmall),
              child: SqaCard(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 450;
                    return Row(
                      children: [
                        // Category Icon/Indicator
                        Container(
                          padding: const EdgeInsets.all(SqaTokens.spacingSmall),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              context,
                              entry.category,
                            ).withValues(alpha: 0.1),
                            borderRadius: SqaTokens.borderRadiusMedium,
                          ),
                          child: Icon(
                            _getCategoryIcon(entry.category),
                            color: _getCategoryColor(context, entry.category),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: SqaTokens.spacingMedium),
                        // Terms original -> replacement
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isCompact) ...[
                                Text(
                                  entry.original,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: entry.enabled
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                  ),
                                ),
                                const SizedBox(
                                  height: SqaTokens.spacingXXSmall,
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Symbols.subdirectory_arrow_right,
                                      size: 14,
                                      color: theme.colorScheme.primary
                                          .withValues(
                                            alpha: entry.enabled ? 0.7 : 0.4,
                                          ),
                                    ),
                                    const SizedBox(
                                      width: SqaTokens.spacingXXSmall,
                                    ),
                                    Text(
                                      entry.replacement,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: entry.enabled
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.primary
                                                      .withValues(alpha: 0.5),
                                          ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                Row(
                                  children: [
                                    Text(
                                      entry.original,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: entry.enabled
                                                ? theme.colorScheme.onSurface
                                                : theme.colorScheme.onSurface
                                                      .withValues(alpha: 0.5),
                                          ),
                                    ),
                                    const SizedBox(
                                      width: SqaTokens.spacingSmall,
                                    ),
                                    Icon(
                                      Symbols.arrow_right_alt,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(
                                      width: SqaTokens.spacingSmall,
                                    ),
                                    Text(
                                      entry.replacement,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: entry.enabled
                                                ? theme.colorScheme.primary
                                                : theme.colorScheme.primary
                                                      .withValues(alpha: 0.5),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: SqaTokens.spacingTiny),
                              Text(
                                entry.category.name.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: SqaTokens.spacingSmall),
                        // Enable/Disable toggle (Checkbox icon/button)
                        SqaHoverIconButton(
                          icon: entry.enabled
                              ? Symbols.check_box
                              : Symbols.check_box_outline_blank,
                          onPressed: () =>
                              notifier.toggleDictionaryEntry(entry.id),
                          tooltip: entry.enabled
                              ? 'Disable rule'
                              : 'Enable rule',
                          color: entry.enabled
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                          iconSize: 24,
                        ),
                        const SizedBox(width: SqaTokens.spacingXSmall),
                        // Delete Button
                        SqaHoverIconButton(
                          icon: Symbols.delete,
                          onPressed: () => _showDeleteEntryConfirmation(
                            context,
                            notifier,
                            entry,
                          ),
                          tooltip: 'Delete Rule',
                          color: theme.colorScheme.error,
                          iconSize: 20,
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  IconData _getCategoryIcon(EntryCategory category) {
    switch (category) {
      case EntryCategory.model:
        return Symbols.database;
      case EntryCategory.field:
        return Symbols.key;
      case EntryCategory.endpoint:
        return Symbols.api;
      case EntryCategory.service:
        return Symbols.dns;
      case EntryCategory.config:
        return Symbols.settings;
      case EntryCategory.general:
        return Symbols.abc;
    }
  }

  Color _getCategoryColor(BuildContext context, EntryCategory category) {
    final theme = Theme.of(context);
    switch (category) {
      case EntryCategory.model:
        return Colors.blue;
      case EntryCategory.field:
        return Colors.green;
      case EntryCategory.endpoint:
        return Colors.purple;
      case EntryCategory.service:
        return Colors.orange;
      case EntryCategory.config:
        return Colors.teal;
      case EntryCategory.general:
        return theme.colorScheme.primary;
    }
  }

  void _showAddEntryDialog(BuildContext context, Obfuscator notifier) {
    showDialog<void>(
      context: context,
      builder: (context) => _AddDictionaryEntryDialog(notifier: notifier),
    );
  }

  Future<void> _showDeleteEntryConfirmation(
    BuildContext context,
    Obfuscator notifier,
    DictionaryEntry entry,
  ) async {
    final confirmed = await SqaModal.showDanger(
      context,
      title: 'Delete Rule',
      message:
          'Are you sure you want to delete the rule replacing "${entry.original}" with "${entry.replacement}"?',
      confirmLabel: 'Delete',
    );
    if (confirmed == true) {
      await notifier.deleteDictionaryEntry(entry.id);
    }
  }

  Widget _buildEmptyDictionaryState(BuildContext context, Obfuscator notifier) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.menu_book,
            size: 48,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: SqaTokens.spacingLarge),
          Text('No replacement rules', style: theme.textTheme.titleMedium),
          const SizedBox(height: SqaTokens.spacingSmall),
          Text(
            'Create rules to map and replace sensitive terms across your files.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SqaTokens.spacingXLarge),
          SqaButton(
            label: 'Add First Entry',
            icon: Symbols.add,
            onPressed: () => _showAddEntryDialog(context, notifier),
            type: SqaButtonType.tonal,
          ),
        ],
      ),
    );
  }
}

class _AddDictionaryEntryDialog extends StatefulWidget {
  final Obfuscator notifier;

  const _AddDictionaryEntryDialog({required this.notifier});

  @override
  State<_AddDictionaryEntryDialog> createState() =>
      __AddDictionaryEntryDialogState();
}

class __AddDictionaryEntryDialogState extends State<_AddDictionaryEntryDialog> {
  final _originalController = TextEditingController();
  final _replacementController = TextEditingController();
  EntryCategory _category = EntryCategory.general;

  @override
  void dispose() {
    _originalController.dispose();
    _replacementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SqaModal<void>.custom(
      title: 'Add Dictionary Rule',
      icon: Symbols.menu_book,
      customActions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: SqaTokens.spacingXXSmall),
        FilledButton(
          onPressed: () {
            if (_originalController.text.isNotEmpty &&
                _replacementController.text.isNotEmpty) {
              widget.notifier.addDictionaryEntry(
                original: _originalController.text,
                replacement: _replacementController.text,
                category: _category,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add Rule'),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a new mapping rule to replace sensitive terms in your documents.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SqaTokens.spacingLarge),

          // Original Term
          Text(
            'ORIGINAL TERM',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
          TextField(
            controller: _originalController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Project Hercules, customer_id, etc.',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: SqaTokens.spacingSmall + 4,
                horizontal: SqaTokens.spacingSmall + 4,
              ),
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: SqaTokens.spacingMedium),

          // Replacement Term
          Text(
            'REPLACEMENT TERM',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
          TextField(
            controller: _replacementController,
            decoration: const InputDecoration(
              hintText: 'e.g. Project Orion, alias_id, etc.',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: SqaTokens.spacingSmall + 4,
                horizontal: SqaTokens.spacingSmall + 4,
              ),
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: SqaTokens.spacingMedium),

          // Category Select
          Text(
            'RULE CATEGORY',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
          SqaDropdown<EntryCategory>(
            value: _category,
            items: EntryCategory.values.map((cat) {
              return DropdownMenuItem<EntryCategory>(
                value: cat,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(cat),
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: SqaTokens.spacingSmall),
                    Text(cat.name.toUpperCase()),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _category = val;
                });
              }
            },
            widthInChars: 30,
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(EntryCategory category) {
    switch (category) {
      case EntryCategory.model:
        return Symbols.database;
      case EntryCategory.field:
        return Symbols.key;
      case EntryCategory.endpoint:
        return Symbols.api;
      case EntryCategory.service:
        return Symbols.dns;
      case EntryCategory.config:
        return Symbols.settings;
      case EntryCategory.general:
        return Symbols.abc;
    }
  }
}

class DeobfuscatorTabContent extends ConsumerStatefulWidget {
  const DeobfuscatorTabContent({super.key});

  @override
  ConsumerState<DeobfuscatorTabContent> createState() =>
      _DeobfuscatorTabContentState();
}

class _DeobfuscatorTabContentState
    extends ConsumerState<DeobfuscatorTabContent> {
  EditorState? _editorState;
  EditorScrollController? _editorScrollController;
  final ScrollController _scrollController = ScrollController();
  String? _lastRenderedContent;
  Map<String, BlockComponentBuilder>? _cachedBuilders;
  Brightness? _cachedBrightness;

  @override
  void dispose() {
    _editorState?.dispose();
    _editorScrollController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeEditor(String content) {
    if (content.isEmpty) {
      _editorState?.dispose();
      _editorScrollController?.dispose();
      setState(() {
        _editorState = null;
        _editorScrollController = null;
        _lastRenderedContent = null;
      });
      return;
    }

    final document = markdownToDocument(
      content,
      markdownParsers: [
        const SqaMarkdownCodeBlockParser(),
        const SqaMarkdownTableParser(),
        const SqaMarkdownHtmlParser(),
        const SqaMarkdownImageParser(),
      ],
    );

    if (document.root.children.isEmpty) {
      document.root.children.add(paragraphNode());
    }

    _editorState?.dispose();
    _editorScrollController?.dispose();

    setState(() {
      _editorState = EditorState(document: document);
      _editorState!.editable = false;

      _editorScrollController = EditorScrollController(
        editorState: _editorState!,
        shrinkWrap: true,
        scrollController: _scrollController,
      );
      _lastRenderedContent = content;
    });
  }

  TextSpan _deobfuscatorTextSpanDecorator(
    BuildContext context,
    Node node,
    int index,
    TextInsert text,
    TextSpan before,
    TextSpan after,
    List<DictionaryEntry> dictionary,
  ) {
    final textStr = text.text;
    if (textStr.isEmpty || dictionary.isEmpty) return before;

    final activeEntries = dictionary.where((e) => e.enabled).toList();
    if (activeEntries.isEmpty) return before;

    final Map<String, DictionaryEntry> originalToEntry = {};
    for (final entry in activeEntries) {
      originalToEntry[entry.original.toLowerCase()] = entry;
      for (final v in entry.variants.values) {
        originalToEntry[v.toLowerCase()] = entry;
      }
    }

    final terms = originalToEntry.keys.toList();
    if (terms.isEmpty) return before;

    terms.sort((a, b) => b.length.compareTo(a.length));
    final escapedTerms = terms.map(RegExp.escape).join('|');
    final regex = RegExp('\\b($escapedTerms)\\b', caseSensitive: false);

    final matches = regex.allMatches(textStr).toList();
    if (matches.isEmpty) return before;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final highlightBg = isDark
        ? const Color(0xFF00ADB5).withValues(alpha: 0.28)
        : const Color(0xFF00D1B2).withValues(alpha: 0.18);

    final List<InlineSpan> children = [];
    var lastIdx = 0;

    for (final match in matches) {
      if (match.start > lastIdx) {
        children.add(
          TextSpan(
            text: textStr.substring(lastIdx, match.start),
            style: before.style,
          ),
        );
      }

      final matchedText = match.group(0)!;
      children.add(
        TextSpan(
          text: matchedText,
          style:
              before.style?.copyWith(
                backgroundColor: highlightBg,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: isDark
                    ? const Color(0xFF00ADB5)
                    : const Color(0xFF00D1B2),
              ) ??
              TextStyle(
                backgroundColor: highlightBg,
                fontWeight: FontWeight.bold,
              ),
        ),
      );

      lastIdx = match.end;
    }

    if (lastIdx < textStr.length) {
      children.add(
        TextSpan(text: textStr.substring(lastIdx), style: before.style),
      );
    }

    return TextSpan(style: before.style, children: children);
  }

  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final theme = Theme.of(context);
    final map = <String, BlockComponentBuilder>{
      ...standardBlockComponentBuilderMap,
    };

    map[ParagraphBlockKeys.type] = ParagraphBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
    )..showActions = (_) => false;

    map[HeadingBlockKeys.type] = HeadingBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
      textStyleBuilder: (level) {
        final fontSizes = [
          SqaTokens.fontSizeXXLarge,
          SqaTokens.fontSizeXLarge,
          SqaTokens.fontSizeLarge,
          SqaTokens.spacingLarge,
          SqaTokens.fontSizeSmall + 2,
          SqaTokens.fontSizeSmall + 2,
        ];
        return GoogleFonts.inter(
          fontSize: fontSizes[level - 1],
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );
      },
    )..showActions = (_) => false;

    map[TableBlockKeys.type] = SqaTableBlockComponentBuilder(
      tableStyle: TableStyle(
        borderWidth: 1.0,
        borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        borderHoverColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        addIcon: Icon(
          Symbols.add,
          size: SqaTokens.spacingLarge + SqaTokens.spacingTiny,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
    map[TableCellBlockKeys.type] = SqaTableCellBlockComponentBuilder();

    final codeBlockBuilder = SqaCodeBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
    );
    map['code'] = codeBlockBuilder;
    map['code_block'] = codeBlockBuilder;

    map[QuoteBlockKeys.type] = SqaQuoteBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
    );

    for (final entry in map.entries) {
      entry.value.showActions = (_) => false;
    }

    map['raw_html'] = RawHtmlBlockComponentBuilder();
    map[ImageBlockKeys.type] = SqaImageBlockComponentBuilder();

    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(obfuscatorProvider);
    final notifier = ref.read(obfuscatorProvider.notifier);

    final deobfText = state.deobfuscatedContent ?? '';
    if (deobfText.isNotEmpty && deobfText != _lastRenderedContent) {
      _initializeEditor(deobfText);
    } else if (deobfText.isEmpty && _editorState != null) {
      _initializeEditor('');
    }

    if (_cachedBrightness != theme.brightness) {
      _cachedBrightness = theme.brightness;
      _cachedBuilders = null;
    }

    if (_editorState == null) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.lock_open,
                size: 48,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(height: SqaTokens.spacingLarge),
              Text('De-obfuscator', style: theme.textTheme.titleMedium),
              const SizedBox(height: SqaTokens.spacingSmall),
              Text(
                'Paste your obfuscated text to automatically restore original sensitive terms using the active dictionary.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SqaTokens.spacingXLarge),
              SqaButton(
                label: 'Paste & De-obfuscate',
                icon: Symbols.content_paste,
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  final text = data?.text ?? '';
                  if (text.trim().isEmpty) {
                    if (context.mounted) {
                      SqaToast.show(
                        context,
                        'Clipboard is empty!',
                        type: SqaToastType.warning,
                      );
                    }
                    return;
                  }
                  await notifier.deobfuscateText(text);
                  if (context.mounted) {
                    final resCount = ref
                        .read(obfuscatorProvider)
                        .lastRestoredCount;
                    SqaToast.show(
                      context,
                      'Successfully de-obfuscated: Restored $resCount placeholder terms!',
                      type: SqaToastType.success,
                    );
                  }
                },
                type: SqaButtonType.primary,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SqaTokens.spacingXXLarge,
            vertical: SqaTokens.spacingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.security_update_good,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: SqaTokens.spacingSmall),
                  Text(
                    'Restored ${state.lastRestoredCount} sensitive terms',
                    style: SqaTextStyles.labelBold(
                      context,
                    ).copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
              Row(
                children: [
                  SqaHoverIconButton(
                    icon: Symbols.content_copy,
                    onPressed: () async {
                      await notifier.copyContent(deobfText);
                      if (context.mounted) {
                        SqaToast.show(
                          context,
                          'De-obfuscated content copied to clipboard',
                          type: SqaToastType.success,
                        );
                      }
                    },
                    tooltip: 'Copy De-obfuscated Text',
                    iconSize: 18,
                  ),
                  const SizedBox(width: SqaTokens.spacingMedium),
                  SqaHoverIconButton(
                    icon: Symbols.delete,
                    onPressed: () {
                      notifier.clearDeobfuscatedContent();
                      SqaToast.show(
                        context,
                        'Cleared content',
                        type: SqaToastType.info,
                      );
                    },
                    tooltip: 'Clear',
                    iconSize: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
        Expanded(
          child: SqaFadeWrapper(
            child: Theme(
              data: theme.copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  selectionHandleColor: theme.colorScheme.primary,
                  selectionColor: theme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                  cursorColor: theme.colorScheme.primary,
                ),
              ),
              child: Focus(
                onKeyEvent: (FocusNode node, KeyEvent event) {
                  final isControlPressed =
                      HardwareKeyboard.instance.isControlPressed ||
                      HardwareKeyboard.instance.isMetaPressed;
                  if (isControlPressed) {
                    return KeyEventResult.ignored;
                  }
                  return KeyEventResult.handled;
                },
                child: AppFlowyEditor(
                  key: ValueKey(_editorState.hashCode),
                  editorState: _editorState!,
                  editable: false,
                  autoFocus: false,
                  blockComponentBuilders: _cachedBuilders ??=
                      _buildBlockComponentBuilders(),
                  commandShortcutEvents: const [],
                  editorScrollController: _editorScrollController!,
                  shrinkWrap: true,
                  footer: const SizedBox(
                    height: SqaTokens.scrollClearanceBottom,
                  ),
                  editorStyle: EditorStyle.desktop(
                    padding: const EdgeInsets.symmetric(
                      horizontal:
                          SqaTokens.spacingXXLarge + SqaTokens.spacingLarge,
                      vertical: SqaTokens.spacingMedium,
                    ),
                    maxWidth: 800.0,
                    textScaleFactor: 14.0 / 16.0,
                    cursorColor: theme.colorScheme.primary,
                    selectionColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    textSpanDecorator:
                        (context, node, index, text, before, after) {
                          return _deobfuscatorTextSpanDecorator(
                            context,
                            node,
                            index,
                            text,
                            before,
                            after,
                            state.dictionary,
                          );
                        },
                    textStyleConfiguration: TextStyleConfiguration(
                      text: GoogleFonts.inter(
                        fontSize: 16.0,
                        height: 1.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

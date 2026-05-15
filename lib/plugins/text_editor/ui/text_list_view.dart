import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
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
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../providers/text_editor_provider.dart';
import '../models/text_document.dart';

enum TextListFilter { all, pinned, recent }

class TextListView extends ConsumerStatefulWidget {
  const TextListView({super.key});

  @override
  ConsumerState<TextListView> createState() => _TextListViewState();
}

class _TextListViewState extends ConsumerState<TextListView> {
  TextListFilter _selectedFilter = TextListFilter.all;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(textEditorProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(textEditorProvider);
    var filteredDocs = ref.watch(filteredDocumentsProvider);

    // Apply UI Filter
    if (_selectedFilter == TextListFilter.pinned) {
      filteredDocs = filteredDocs.where((d) => d.isPinned).toList();
    } else if (_selectedFilter == TextListFilter.recent) {
      filteredDocs = List.from(filteredDocs)
        ..sort((a, b) => b.lastModified.compareTo(a.lastModified));
    }

    final notifier = ref.read(textEditorProvider.notifier);
    final theme = Theme.of(context);

    return SqaPluginLayout(
      icon: Symbols.edit_note,
      title: 'Text Editor',
      description: 'Manage and edit your MarkDown documents.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaHoverIconButton(
            icon: Symbols.refresh,
            onPressed: () => notifier.initialize(),
            tooltip: 'Refresh file list',
            iconSize: SqaTokens.spacingXLarge,
          ),
          const SizedBox(width: SqaTokens.spacingXSmall),
          _buildNewDocumentButton(context, notifier),
        ],
      ),
      searchController: _searchController,
      onSearchChanged: (value) => notifier.setSearchQuery(value),
      searchHint: 'Search documents...',
      child: SqaPluginScrollableContent(
        child: state.documents.isEmpty
            ? _buildEmptyState(context, notifier)
            : Column(
                children: [
                  _buildFilterBar(context),
                  const SizedBox(height: SqaTokens.spacingLarge),
                  if (filteredDocs.isEmpty)
                    _buildNoResultsState(context)
                  else
                    ...filteredDocs.map((doc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
                        child: SqaCard(
                          onTap: () => notifier.viewDocument(doc),
                          child: Row(
                            children: [
                              _buildFileIcon(context),
                              const SizedBox(width: SqaTokens.spacingLarge),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SqaSmartText(
                                            text: doc.name,
                                            style: theme.textTheme.titleSmall,
                                          ),
                                        ),
                                        if (doc.isPinned) ...[
                                          const SizedBox(width: SqaTokens.spacingSmall),
                                          Icon(
                                            Symbols.keep,
                                            size: SqaTokens.spacingLarge,
                                            color: theme.colorScheme.primary,
                                            fill: 1,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: SqaTokens.spacingXSmall),
                                    Text(
                                      'Last modified: ${DateFormat.yMMMd().add_Hm().format(doc.lastModified)}',
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
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingXSmall),
      child: SqaSegmentedButton<TextListFilter>(
        stretches: true,
        storageKey: 'text_list_filter',
        segments: const [
          ButtonSegment(value: TextListFilter.all, label: Text('All')),
          ButtonSegment(value: TextListFilter.pinned, label: Text('Pinned')),
          ButtonSegment(value: TextListFilter.recent, label: Text('Recent')),
        ],
        selected: {_selectedFilter},
        onSelectionChanged: (set) {
          setState(() {
            _selectedFilter = set.first;
          });
        },
      ),
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

  Widget _buildEmptyState(BuildContext context, TextEditor notifier) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Icon(
          Symbols.edit_document,
          size: 48,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        const SizedBox(height: SqaTokens.spacingLarge),
        Text(
          'No documents found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: SqaTokens.spacingSmall),
        Text(
          'Create a new document from a template to get started.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: SqaTokens.spacingXLarge),
        _buildNewDocumentButton(context, notifier, type: SqaButtonType.tonal),
        const SizedBox(height: SqaTokens.spacingMedium),
        _buildOpenFolderButton(context, notifier),
      ],
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SqaTokens.spacingSmall),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: SqaStyles.radiusMedium,
      ),
      child: Icon(
        Symbols.description,
        size: SqaTokens.spacingXLarge,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildOpenFolderButton(
    BuildContext context,
    TextEditor notifier, {
    SqaButtonType type = SqaButtonType.tonal,
  }) {
    return SqaButton(
      label: 'Open Saved Folder',
      icon: Symbols.folder_open,
      onPressed: () => notifier.openSaveFolder(),
      type: type,
    );
  }

  Widget _buildActions(
    BuildContext context,
    TextEditor notifier,
    TextDocument doc,
  ) {
    final theme = Theme.of(context);

    return SqaPopupMenu(
      alignmentOffset: const Offset(-100, SqaTokens.spacingSmall),
      tooltip: 'Actions',
      icon: Symbols.more_vert,
      children: [
        SqaPopupMenuItem(
          icon: const Icon(Symbols.edit),
          label: 'Edit Mode',
          onPressed: () => notifier.openEditor(doc),
        ),
        SqaPopupMenuItem(
          icon: Icon(doc.isPinned ? Symbols.keep_off : Symbols.keep),
          label: doc.isPinned ? 'Unpin from Top' : 'Pin to Top',
          onPressed: () => notifier.togglePin(doc.id),
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
          label: 'Delete',
          isDestructive: true,
          onPressed: () async {
            final confirm = await SqaModal.showConfirm(
              context,
              title: 'Delete Document',
              message:
                  'Are you sure you want to delete "${doc.name}"? This action cannot be undone.',
              confirmLabel: 'Delete',
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

  Widget _buildNewDocumentButton(
    BuildContext context,
    TextEditor notifier, {
    SqaButtonType type = SqaButtonType.primary,
  }) {
    final theme = Theme.of(context);
    final bool isTonal = type == SqaButtonType.tonal;
    final String label = isTonal ? 'Create First Document' : '';
    final bool hasIcon = !isTonal || isTonal; // Always show icon now

    // Estimate width based on SqaButton styling
    final double estimatedWidth =
        (label.length * 7.2) + (hasIcon ? 26.0 : 0) + 24.0;
    final double width = estimatedWidth.clamp(isTonal ? 160.0 : 44.0, 240.0);

    return MenuAnchor(
      alignmentOffset: const Offset(0, SqaTokens.spacingSmall),
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(const EdgeInsets.all(SqaTokens.spacingXSmall)),
        elevation: WidgetStateProperty.all(8.0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: SqaStyles.radiusLarge,
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      menuChildren: [
        _buildTemplateItem(
          context,
          notifier,
          TextTemplateType.empty,
          'Empty Canvas',
          Symbols.draft,
          Colors.grey,
          width,
        ),
        _buildTemplateItem(
          context,
          notifier,
          TextTemplateType.bugReport,
          'Bug Report',
          Symbols.bug_report,
          Colors.orange,
          width,
        ),
        _buildTemplateItem(
          context,
          notifier,
          TextTemplateType.devTicket,
          'Dev Ticket',
          Symbols.confirmation_number,
          Colors.blue,
          width,
        ),
      ],
      builder: (context, controller, child) {
        return SqaButton(
          label: label,
          icon: hasIcon ? Symbols.add_notes : null,
          type: type,
          tooltip: 'New document',
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
    );
  }

  Widget _buildTemplateItem(
    BuildContext context,
    TextEditor notifier,
    TextTemplateType type,
    String label,
    IconData icon,
    Color color,
    double width,
  ) {
    final theme = Theme.of(context);

    return MenuItemButton(
      onPressed: () => notifier.createFromTemplate(type),
      style: MenuItemButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: SqaTokens.spacingMedium,
          vertical: SqaTokens.spacingSmall,
        ),
        minimumSize: Size(width - 8, 36), // Account for menu padding
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: SqaTokens.spacingLarge + SqaTokens.spacingTiny, color: color),
          const SizedBox(width: SqaTokens.spacingMedium),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: SqaTokens.fontSizeSmall,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

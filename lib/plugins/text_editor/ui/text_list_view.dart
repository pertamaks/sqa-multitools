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
import '../../../ui/widgets/sqa_search_filter_bar.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(textEditorProvider);
    var filteredDocs = ref.watch(filteredDocumentsProvider);
    
    // Apply UI Filter
    if (_selectedFilter == TextListFilter.pinned) {
      filteredDocs = filteredDocs.where((d) => d.isPinned).toList();
    } else if (_selectedFilter == TextListFilter.recent) {
      filteredDocs = List.from(filteredDocs)..sort((a, b) => b.lastModified.compareTo(a.lastModified));
    }

    final notifier = ref.read(textEditorProvider.notifier);
    final theme = Theme.of(context);

    return SqaPluginLayout(
      icon: Symbols.edit_note,
      title: 'Text Editor',
      description:
          'Manage and edit your text documents. (${state.documents.length}/${state.maxDocuments})',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Symbols.refresh, size: 20),
            onPressed: () => notifier.initialize(),
            tooltip: 'Refresh file list',
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusLarge,
              ),
            ),
          ),
          const SizedBox(width: 4),
          _buildNewDocumentButton(context, notifier),
        ],
      ),
      child: SqaPluginScrollableContent(
        child: state.isLoading
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            : state.documents.isEmpty
            ? _buildEmptyState(context, notifier)
            : Column(
                children: [
                  _buildSearchBar(context),
                  const SizedBox(height: 16),
                  if (filteredDocs.isEmpty)
                    _buildNoResultsState(context)
                  else
                    ...filteredDocs.map((doc) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: SqaCard(
                          onTap: () => notifier.openEditor(doc),
                          child: Row(
                            children: [
                              _buildFileIcon(context),
                              const SizedBox(width: 16),
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
                                          const SizedBox(width: 8),
                                          Icon(
                                            Symbols.keep,
                                            size: 16,
                                            color: theme.colorScheme.primary,
                                            fill: 1,
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
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
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                    child: _buildOpenFolderButton(context, notifier),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final notifier = ref.read(textEditorProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: SqaSearchFilterBar(
        hintText: 'Search documents...',
        onChanged: (value) => notifier.setSearchQuery(value),
        isFilterActive: _selectedFilter != TextListFilter.all,
        filterOptions: Row(
          children: [
            Expanded(
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
            ),
          ],
        ),
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
            size: 48,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No documents match your search',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
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
        const SizedBox(height: 16),
        Text(
          'No documents found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Create a new document from a template to get started.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
        _buildNewDocumentButton(context, notifier, type: SqaButtonType.tonal),
        const SizedBox(height: 12),
        _buildOpenFolderButton(context, notifier),
      ],
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: SqaStyles.radiusMedium,
      ),
      child: Icon(
        Symbols.description,
        size: 20,
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
      alignmentOffset: const Offset(-100, 8),
      tooltip: 'Actions',
      icon: const Icon(Symbols.more_vert, size: 20),
      children: [
        SqaPopupMenuItem(
          icon: const Icon(Symbols.edit),
          label: 'Edit',
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
    final String label = isTonal ? 'Create First Document' : 'New Document';
    final bool hasIcon = !isTonal;

    // Estimate width based on SqaButton styling (12px bold text, icons, and padding)
    // Roughly: chars * 7.2px + icon(18px) + gap(8px) + padding(24px)
    final double estimatedWidth =
        (label.length * 7.2) + (hasIcon ? 26.0 : 0) + 24.0;
    final double width = estimatedWidth.clamp(140.0, 240.0);

    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
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
          icon: hasIcon ? Symbols.add : null,
          type: type,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size(width - 8, 36), // Account for menu padding
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

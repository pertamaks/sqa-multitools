import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../providers/md_editor_provider.dart';
import '../models/md_document.dart';

class MdListView extends ConsumerWidget {
  const MdListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mdEditorProvider);
    final notifier = ref.read(mdEditorProvider.notifier);

    return SqaPluginLayout(
      icon: Symbols.edit_note,
      title: 'MD Editor',
      description: 'Manage your markdown documents.',
      trailing: _buildNewDocumentButton(context, notifier),
      child: SqaPluginScrollableContent(
        child: state.documents.isEmpty
            ? _buildEmptyState(context, notifier)
            : Column(
                children: state.documents.map((doc) {
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
                                Text(
                                  doc.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Last modified: ${DateFormat.yMMMd().add_Hm().format(doc.lastModified)}',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context)
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
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, MdEditor notifier) {
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
        _buildNewDocumentButton(context, notifier, isTonal: true),
      ],
    );
  }

  Widget _buildFileIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: SqaStyles.radiusMedium,
      ),
      child: Icon(
        Symbols.description,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildActions(BuildContext context, MdEditor notifier, MdDocument doc) {
    final theme = Theme.of(context);
    
    return MenuAnchor(
      alignmentOffset: const Offset(-100, 8),
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
        _buildActionItem(
          context,
          'Edit',
          Symbols.edit,
          null,
          () => notifier.openEditor(doc),
        ),
        _buildActionItem(
          context,
          'Copy Content',
          Symbols.content_copy,
          null,
          () {
            // TODO: Implement copy
          },
        ),
        _buildActionItem(
          context,
          'Delete',
          Symbols.delete,
          Colors.red,
          () => notifier.deleteDocument(doc.id),
        ),
      ],
      builder: (context, controller, child) {
        return IconButton(
          icon: const Icon(Symbols.more_vert, size: 20),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          tooltip: 'Actions',
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
          ),
        );
      },
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String label,
    IconData icon,
    Color? color,
    VoidCallback onPressed,
  ) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;
    
    return MenuItemButton(
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(140, 36),
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: effectiveColor),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewDocumentButton(BuildContext context, MdEditor notifier, {bool isTonal = false}) {
    final theme = Theme.of(context);
    final String label = isTonal ? 'Create First Document' : 'New Document';
    final bool hasIcon = !isTonal;

    // Estimate width based on SqaButton styling (12px bold text, icons, and padding)
    // Roughly: chars * 7.2px + icon(18px) + gap(8px) + padding(24px)
    final double estimatedWidth = (label.length * 7.2) + (hasIcon ? 26.0 : 0) + 24.0;
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
          MdTemplateType.empty,
          'Empty Canvas',
          Symbols.draft,
          Colors.grey,
          width,
        ),
        _buildTemplateItem(
          context,
          notifier,
          MdTemplateType.bugReport,
          'Bug Report',
          Symbols.bug_report,
          Colors.orange,
          width,
        ),
        _buildTemplateItem(
          context,
          notifier,
          MdTemplateType.devTicket,
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
          type: isTonal ? SqaButtonType.tonal : SqaButtonType.primary,
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
    MdEditor notifier,
    MdTemplateType type,
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

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/screenshot_state.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';

class CaptureTile extends StatelessWidget {
  final CaptureInfo info;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  final VoidCallback onOpenFolder;
  final void Function(String) onRename;
  final String? Function(String) onValidate;

  const CaptureTile({
    super.key,
    required this.info,
    required this.onDelete,
    required this.onOpen,
    required this.onOpenFolder,
    required this.onRename,
    required this.onValidate,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filename = info.file.uri.pathSegments.last;
    final nameWithoutExt = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;

    return ListTile(
      dense: true,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          info.file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Symbols.image_not_supported,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
      title: Text(
        filename,
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatSize(info.size)} • ${info.modified.hour}:${info.modified.minute.toString().padLeft(2, '0')}',
        style: theme.textTheme.labelSmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Symbols.open_in_new, size: 18),
            onPressed: onOpen,
            tooltip: 'Open',
          ),
          SqaPopupMenu(
            icon: const Icon(Symbols.more_vert, size: 18),
            tooltip: 'Actions',
            children: [
              SqaPopupMenuItem(
                onPressed: () async {
                  final newName = await SqaModal.showPrompt(
                    context,
                    title: 'Rename Capture',
                    message: 'Enter a new name for this screenshot:',
                    initialValue: nameWithoutExt,
                    validator: onValidate,
                  );
                  if (newName != null && newName.isNotEmpty) {
                    onRename(newName);
                  }
                },
                icon: const Icon(Symbols.edit),
                label: 'Rename',
              ),
              SqaPopupMenuItem(
                onPressed: onOpenFolder,
                icon: const Icon(Symbols.folder_open),
                label: 'Open Folder',
              ),
              const Divider(height: 1),
              SqaPopupMenuItem(
                onPressed: () async {
                  final confirm = await SqaModal.showDanger(
                    context,
                    title: 'Delete Capture?',
                    message:
                        'Are you sure you want to permanently delete this file? This action cannot be undone.',
                    confirmLabel: 'Delete',
                    icon: Symbols.delete,
                  );
                  if (confirm == true) {
                    onDelete();
                  }
                },
                icon: const Icon(Symbols.delete),
                label: 'Delete',
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

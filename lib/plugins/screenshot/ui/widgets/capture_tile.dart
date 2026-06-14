import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/screenshot_state.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';

class CaptureTile extends StatefulWidget {
  final CaptureInfo info;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  final VoidCallback onAnnotate;
  final VoidCallback onOpenFolder;
  final void Function(String) onRename;
  final String? Function(String) onValidate;

  const CaptureTile({
    super.key,
    required this.info,
    required this.onDelete,
    required this.onOpen,
    required this.onAnnotate,
    required this.onOpenFolder,
    required this.onRename,
    required this.onValidate,
  });

  @override
  State<CaptureTile> createState() => _CaptureTileState();
}

class _CaptureTileState extends State<CaptureTile> {
  bool _isHovered = false;
  bool _isMenuOpen = false;

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filename = widget.info.file.uri.pathSegments.last;
    final nameWithoutExt = filename.contains('.')
        ? filename.substring(0, filename.lastIndexOf('.'))
        : filename;

    return NotificationListener<SqaMenuOpenNotification>(
      onNotification: (notification) {
        setState(() {
          _isMenuOpen = notification.isOpen;
          if (_isMenuOpen) {
            _isHovered = false;
          }
        });
        return false;
      },
      child: MouseRegion(
        onEnter: (_) {
          if (!_isMenuOpen) setState(() => _isHovered = true);
        },
        onExit: (_) {
          setState(() => _isHovered = false);
        },
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onOpen,
          behavior: HitTestBehavior.opaque,
          child: ValueListenableBuilder<bool>(
            valueListenable: sqaGlobalMenuOpenState,
            builder: (context, isAnyMenuOpen, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: _isHovered && !isAnyMenuOpen
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.04) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(SqaTokens.radiusMedium),
                ),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SqaTokens.spacingLarge,
                vertical: SqaTokens.spacingSmall + 2,
              ),
              child: Row(
                children: [
                  Container(
                    width: SqaTokens.spacingXXLarge,
                    height: SqaTokens.spacingXXLarge,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(SqaTokens.radiusSmall),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.file(
                      widget.info.file,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Symbols.image,
                          size: SqaTokens.spacingLarge,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: SqaTokens.spacingLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filename,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: SqaTokens.spacingXSmall / 2),
                        Text(
                          '${_formatSize(widget.info.size)} • ${DateFormat('dd/MM/yyyy HH:mm').format(widget.info.modified)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SqaHoverIconButton(
                    icon: Symbols.open_in_new,
                    tooltip: 'Open',
                    onPressed: widget.onOpen,
                  ),
                  const SizedBox(width: SqaTokens.spacingXSmall),
                  SqaPopupMenu(
                    icon: Symbols.more_vert,
                    children: [
                      SqaPopupMenuItem(
                        onPressed: widget.onAnnotate,
                        icon: const Icon(Symbols.edit_square),
                        label: 'Annotate',
                      ),
                      const Divider(height: 1),
                      SqaPopupMenuItem(
                        onPressed: () async {
                          final newName = await SqaModal.showPrompt(
                            context,
                            title: 'Rename Capture',
                            message: 'Enter a new name for this capture:',
                            initialValue: nameWithoutExt,
                            confirmLabel: 'Rename',
                            icon: Symbols.edit,
                            validator: widget.onValidate,
                          );
                          if (newName != null && newName != nameWithoutExt) {
                            widget.onRename(newName);
                          }
                        },
                        icon: const Icon(Symbols.edit),
                        label: 'Rename',
                      ),
                      SqaPopupMenuItem(
                        onPressed: widget.onOpenFolder,
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
                            widget.onDelete();
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
            ),
          ),
        ),
      ),
    );
  }
}

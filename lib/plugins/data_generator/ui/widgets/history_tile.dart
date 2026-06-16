import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../ui/widgets/sqa_modal.dart';

class DataHistoryTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final IconData icon;
  final List<Widget>? customActions;

  const DataHistoryTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onDelete,
    this.icon = Symbols.history,
    this.customActions,
  });

  @override
  State<DataHistoryTile> createState() => _DataHistoryTileState();
}

class _DataHistoryTileState extends State<DataHistoryTile> {
  bool _isHovered = false;
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          onTap: widget.onTap,
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
                  borderRadius: SqaStyles.radiusMedium,
                ),
                child: child,
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SqaTokens.spacingLarge,
                vertical: SqaTokens.spacingMedium,
              ),
              child: Row(
                children: [
                  Container(
                    width: SqaTokens.spacingXXLarge,
                    height: SqaTokens.spacingXXLarge,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: SqaStyles.radiusSmall,
                    ),
                    child: Icon(
                      widget.icon,
                      size: SqaTokens.spacingLarge,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: SqaTokens.spacingLarge),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: SqaTokens.spacingXSmall / 2),
                        Text(
                          widget.subtitle,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          strutStyle: const StrutStyle(forceStrutHeight: true),
                        ),
                      ],
                    ),
                  ),
                  ...?widget.customActions,
                  SqaPopupMenu(
                    icon: Symbols.more_vert,
                    children: [
                      SqaPopupMenuItem(
                        label: 'Delete',
                        icon: const Icon(Symbols.delete),
                        isDestructive: true,
                        onPressed: () async {
                          final confirmed = await SqaModal.showDanger(
                            context,
                            title: 'Delete History?',
                            message: 'Are you sure you want to delete this specific generation entry?',
                            confirmLabel: 'Delete',
                          );
                          if (confirmed == true) {
                            widget.onDelete();
                          }
                        },
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

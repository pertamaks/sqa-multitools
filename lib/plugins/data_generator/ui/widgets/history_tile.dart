import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';

class DataHistoryTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: SqaStyles.radiusMedium,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: SqaStyles.radiusSmall,
              ),
              child: Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            if (customActions != null) ...customActions!,
            SqaPopupMenu(
              icon: Symbols.more_vert,
              tooltip: 'Actions',
              children: [
                SqaPopupMenuItem(
                  label: 'Delete',
                  icon: const Icon(Symbols.delete),
                  isDestructive: true,
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

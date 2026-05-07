import 'package:flutter/material.dart';
import 'sqa_styles.dart';

/// A centralized, premium popup menu for SQA-Multitools.
///
/// Reuses the MenuStyle and animation logic from SqaDropdown to ensure
/// visual consistency across the application.
class SqaPopupMenu extends StatelessWidget {
  final Widget icon;
  final List<Widget> children;
  final String? tooltip;
  final Offset alignmentOffset;

  const SqaPopupMenu({
    super.key,
    required this.icon,
    required this.children,
    this.tooltip,
    this.alignmentOffset = const Offset(-8, 4),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuAnchor(
      alignmentOffset: alignmentOffset,
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
      menuChildren: children,
      builder: (context, controller, child) {
        return IconButton(
          icon: icon,
          tooltip: tooltip,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
          ).copyWith(
            overlayColor: SqaStyles.buttonOverlay(context),
          ),
        );
      },
    );
  }
}

/// A standardized item for SqaPopupMenu.
class SqaPopupMenuItem extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final bool isDestructive;

  const SqaPopupMenuItem({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return MenuItemButton(
      onPressed: onPressed,
      style: MenuItemButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        minimumSize: const Size(120, 36),
        shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(size: 18, color: color),
            child: icon,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

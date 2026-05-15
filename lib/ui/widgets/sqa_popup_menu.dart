import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';
import 'sqa_styles.dart';
import 'sqa_hover_icon_button.dart';

/// A centralized, premium popup menu for SQA-Multitools.
///
/// Reuses the MenuStyle and animation logic from SqaDropdown to ensure
/// visual consistency across the application.
class SqaPopupMenu extends StatelessWidget {
  final IconData icon;
  final List<Widget> children;
  final String? tooltip;
  final Offset alignmentOffset;
  final Widget Function(BuildContext, MenuController, Widget?)? builder;

  const SqaPopupMenu({
    super.key,
    required this.icon,
    required this.children,
    this.tooltip,
    this.alignmentOffset = const Offset(-SqaTokens.spacingSmall, SqaTokens.spacingTiny),
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MenuAnchor(
      alignmentOffset: alignmentOffset,
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        padding: WidgetStateProperty.all(const EdgeInsets.all(SqaTokens.spacingXSmall)),
        elevation: WidgetStateProperty.all(SqaTokens.spacingSmall),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: SqaTokens.borderRadiusLarge,
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
      menuChildren: children,
      builder: builder ?? (context, controller, child) {
        return SqaHoverIconButton(
          icon: icon,
          tooltip: tooltip ?? 'Actions',
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
        padding: const EdgeInsets.symmetric(
          horizontal: SqaTokens.spacingSmall + 4,
          vertical: 0,
        ),
        minimumSize: const Size(120, SqaTokens.spacingXXLarge + SqaTokens.spacingSmall),
        shape: RoundedRectangleBorder(borderRadius: SqaTokens.borderRadiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme(
            data: IconThemeData(
              size: SqaTokens.spacingLarge + SqaTokens.spacingXXSmall,
              color: color,
            ),
            child: icon,
          ),
          const SizedBox(width: SqaTokens.spacingSmall + 4),
          Text(
            label,
            style: SqaTextStyles.labelBold(context).copyWith(
              color: color,
              fontSize: SqaTokens.fontSizeTiny,
            ),
          ),
        ],
      ),
    );
  }
}

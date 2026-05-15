import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../ui/widgets/sqa_icon_container.dart';
import 'sqa_hover_icon_button.dart';

class SqaPluginHeader extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String description;
  final Widget? titleWidget;
  final Color? color;
  final Widget? trailing;
  final VoidCallback? onBack;
  final VoidCallback? onIconTap;
  final MouseCursor? iconMouseCursor;

  const SqaPluginHeader({
    super.key,
    this.icon,
    this.title = '',
    this.description = '',
    this.titleWidget,
    this.color,
    this.trailing,
    this.onBack,
    this.onIconTap,
    this.iconMouseCursor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onBack != null) ...[
          SqaHoverIconButton(
            icon: Symbols.arrow_back,
            onPressed: onBack!,
            tooltip: 'Back',
            iconSize: SqaTokens.spacingLarge + SqaTokens.spacingXXSmall,
            padding: SqaTokens.spacingSmall,
          ),
          const SizedBox(width: SqaTokens.spacingSmall),
        ],
        if (icon != null) ...[
          MouseRegion(
            cursor: iconMouseCursor ?? (onIconTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic),
            child: GestureDetector(
              onTap: onIconTap,
              behavior: HitTestBehavior.opaque,
              child: SqaIconContainer(
                icon: icon!,
                color: effectiveColor,
                size: SqaTokens.spacingXXLarge + SqaTokens.spacingSmall,
                iconSize: SqaTokens.spacingLarge + SqaTokens.spacingSmall,
                isCircular: false,
                borderRadius: SqaTokens.borderRadiusLarge,
              ),
            ),
          ),
          const SizedBox(width: SqaTokens.spacingLarge),
        ],
        Expanded(
          child:
              titleWidget ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: effectiveColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
        ),
        if (trailing != null) ...[const SizedBox(width: SqaTokens.spacingMedium), trailing!],
      ],
    );
  }
}

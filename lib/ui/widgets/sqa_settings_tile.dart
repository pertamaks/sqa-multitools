import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

class SqaSettingsTile extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;

  const SqaSettingsTile({
    super.key,
    this.icon,
    this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final Widget content = Padding(
      padding: const EdgeInsets.all(SqaTokens.spacingSmall + 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(SqaTokens.spacingSmall),
              decoration: BoxDecoration(
                color: (iconColor ?? colorScheme.primary).withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: SqaTokens.spacingLarge + SqaTokens.spacingXXSmall,
                color: iconColor ?? colorScheme.primary,
              ),
            ),
            const SizedBox(width: SqaTokens.spacingMedium),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: title,
                  waitDuration: const Duration(milliseconds: 300),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        titleStyle ??
                        theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: SqaTokens.fontSizeTiny,
                        ),
                  ),
                ),
                if (subtitle != null)
                  Tooltip(
                    message: subtitle!,
                    waitDuration: const Duration(milliseconds: 300),
                    child: Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: SqaTokens.fontSizeTiny,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: SqaTokens.spacingSmall + 4), trailing!],
        ],
      ),
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: SqaTokens.borderRadiusLarge,
      mouseCursor: SystemMouseCursors.click,
      child: content,
    );
  }
}

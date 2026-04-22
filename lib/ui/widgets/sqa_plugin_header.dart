import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../ui/widgets/sqa_icon_container.dart';
import 'sqa_styles.dart';

class SqaPluginHeader extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String description;
  final Widget? titleWidget;
  final Color? color;
  final Widget? trailing;
  final VoidCallback? onBack;
  final VoidCallback? onIconTap;

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
          IconButton(
            icon: const Icon(Symbols.arrow_back, size: 20),
            onPressed: onBack,
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusLarge,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (icon != null) ...[
          GestureDetector(
            onTap: onIconTap,
            behavior: HitTestBehavior.opaque,
            child: SqaIconContainer(
              icon: icon!,
              color: effectiveColor,
              size: 40,
              iconSize: 24,
              isCircular: false,
              borderRadius: SqaStyles.radiusLarge,
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: titleWidget ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: effectiveColor,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

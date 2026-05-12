import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../ui/widgets/sqa_icon_container.dart';
import 'sqa_hover_icon_button.dart';
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
            iconSize: 20,
            padding: 8,
          ),
          SizedBox(width: SqaSpacing.small),
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
                size: 40,
                iconSize: 24,
                isCircular: false,
                borderRadius: SqaStyles.radiusLarge,
              ),
            ),
          ),
          SizedBox(width: SqaSpacing.large),
        ],
        Expanded(
          child:
              titleWidget ??
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      title,
                      style: SqaTextStyles.headline(context).copyWith(
                        color: effectiveColor,
                      ),
                    ),
                    Text(
                      description,
                      style: SqaTextStyles.bodySecondary(context).copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
        ),
        if (trailing != null) ...[SizedBox(width: SqaSpacing.medium), trailing!],
      ],
    );
  }
}

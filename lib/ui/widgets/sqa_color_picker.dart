import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

class SqaColorPicker extends StatelessWidget {
  final String? activeColor;
  final void Function(String?) onColorSelected;
  final Widget child;
  final bool isBackground;

  // Ton-sur-ton saturated versions of the table background colors
  static const List<Map<String, String>> textColors = [
    {'name': 'Default', 'hex': ''},
    {'name': 'Dark Cocoa', 'hex': '#5D4037'},
    {'name': 'Deep Navy', 'hex': '#37474F'},
    {'name': 'Terracotta', 'hex': '#BF360C'},
    {'name': 'Forest Green', 'hex': '#2E7D32'},
    {'name': 'Deep Violet', 'hex': '#4527A0'},
    {'name': 'Deep Teal', 'hex': '#00695C'},
  ];

  // Exact colors from Table management menu
  static const List<Map<String, String>> bgColors = [
    {'name': 'None', 'hex': ''},
    {'name': 'Warm Sand', 'hex': '#D7CCC8'},
    {'name': 'Slate', 'hex': '#B0BEC5'},
    {'name': 'Soft Peach', 'hex': '#FFCCBC'},
    {'name': 'Dusty Sage', 'hex': '#C8E6C9'},
    {'name': 'Soft Lilac', 'hex': '#D1C4E9'},
    {'name': 'Pale Teal', 'hex': '#B2DFDB'},
  ];

  const SqaColorPicker({
    super.key,
    this.activeColor,
    required this.onColorSelected,
    required this.child,
    this.isBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = isBackground ? bgColors : textColors;

    return MenuAnchor(
      builder: (context, controller, child) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            behavior: HitTestBehavior.opaque,
            child: AbsorbPointer(child: child),
          ),
        );
      },
      style: MenuStyle(
        backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
        surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
        elevation: WidgetStateProperty.all(8),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: SqaTokens.borderRadiusMedium,
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
        padding: WidgetStateProperty.all(const EdgeInsets.all(SqaTokens.spacingMedium)),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: SqaTokens.spacingSmall, 
            left: SqaTokens.spacingXSmall,
          ),
          child: Text(
            isBackground ? 'Highlight Color' : 'Text Color',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SizedBox(
          width: 160, // 4 items per row
          child: Wrap(
            spacing: SqaTokens.spacingSmall,
            runSpacing: SqaTokens.spacingSmall,
            children: colors.map((color) {
              final isSelected =
                  (color['hex'] == '' && activeColor == null) ||
                  (color['hex'] != '' && activeColor == color['hex']);

              return InkWell(
                onTap: () {
                  onColorSelected(color['hex'] == '' ? null : color['hex']);
                },
                borderRadius: SqaTokens.borderRadiusSmall,
                mouseCursor: SystemMouseCursors.click,
                child: Container(
                  width: SqaTokens.spacingXXLarge,
                  height: SqaTokens.spacingXXLarge,
                  decoration: BoxDecoration(
                    color: color['hex'] == ''
                        ? Colors.transparent
                        : Color(
                            int.parse(color['hex']!.replaceFirst('#', '0xFF')),
                          ),
                    borderRadius: SqaTokens.borderRadiusSmall,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: color['hex'] == ''
                      ? Center(
                          child: Icon(
                            Icons.block,
                            size: SqaTokens.spacingLarge,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
      child: child,
    );
  }
}

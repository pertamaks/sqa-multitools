import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'sqa_styles.dart';

/// A standardized dropdown button for SQA-Multitools.
///
/// Provides a compact, framed button style that is visually consistent with
/// other UI elements like SqaSwitch.
class SqaDropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const SqaDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      height: 28, // Compact height matching the switch visual height
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: SqaStyles.radiusSmall,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          isDense: true,
          icon: Icon(
            Symbols.keyboard_arrow_down,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          // This makes the items in the list smaller
          itemHeight: kMinInteractiveDimension,
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Container(
                alignment: Alignment.centerLeft,
                // Use the item's child widget directly instead of its value's string representation
                child: DefaultTextStyle.merge(
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  child: item.child,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

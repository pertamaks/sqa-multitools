import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'sqa_styles.dart';

/// A standardized dropdown button for SQA-Multitools.
///
/// Provides a compact, framed button style that is visually consistent with
/// other UI elements like SqaSwitch.
class SqaDropdown<T> extends StatefulWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final int? widthInChars;
  final bool enabled;

  const SqaDropdown({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.widthInChars,
    this.enabled = true,
  });

  @override
  State<SqaDropdown<T>> createState() => _SqaDropdownState<T>();
}

class _SqaDropdownState<T> extends State<SqaDropdown<T>>
    with SingleTickerProviderStateMixin {
  final MenuController _menuController = MenuController();
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Estimates the width of a widget tree in pixels for layout budgeting.
  double _estimateWidth(Widget? widget) {
    if (widget == null) return 0.0;

    // Base case: Text width estimation
    if (widget is Text) {
      return (widget.data?.length ?? 0) * 9.5;
    }

    // Handle specific widgets with explicit widths
    if (widget is SizedBox) return widget.width ?? 0.0;
    if (widget is Container) {
      final constraints = widget.constraints;
      if (constraints != null && constraints.hasBoundedWidth) {
        return constraints.maxWidth;
      }
      return _estimateWidth(widget.child);
    }

    // Handle wrappers
    if (widget is Flexible) return _estimateWidth(widget.child);
    if (widget is Expanded) return _estimateWidth(widget.child);
    if (widget is DefaultTextStyle) return _estimateWidth(widget.child);
    if (widget is Padding) {
      return widget.padding.horizontal + _estimateWidth(widget.child);
    }

    // Handle Rows (sum of children)
    if (widget is Row) {
      double total = 0;
      for (final child in widget.children) {
        total += _estimateWidth(child);
      }
      return total;
    }

    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate the automated width based on the longest item
    double estimatedMax = 0;
    if (widget.widthInChars != null) {
      estimatedMax = widget.widthInChars!.toDouble() * 9.5;
    } else {
      for (final item in widget.items) {
        estimatedMax = math.max(estimatedMax, _estimateWidth(item.child));
      }
      if (estimatedMax == 0) estimatedMax = 80.0;
    }

    final double calculatedMax = estimatedMax + 43.0;
    final double maxWidth = calculatedMax.clamp(
      100.0,
      180.0,
    ); // Slightly larger min width

    return MenuAnchor(
      controller: _menuController,
      onOpen: () => _animationController.forward(),
      onClose: () => _animationController.reverse(),
      alignmentOffset: const Offset(0, 4),
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
      menuChildren: widget.items.map((item) {
        final isSelected = item.value == widget.value;

        return MenuItemButton(
          onPressed: () {
            if (widget.onChanged != null) {
              widget.onChanged!(item.value);
            }
          },
          style: MenuItemButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            minimumSize: Size(maxWidth - 8, 36),
            shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
            backgroundColor: isSelected
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
                : null,
          ),
          child: DefaultTextStyle.merge(
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 11, // Unified to 11px
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            child: item.child,
          ),
        );
      }).toList(),
      builder: (context, controller, child) {
        final isShowing = controller.isOpen;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.enabled
                ? () {
                    if (isShowing) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  }
                : null,
            borderRadius: SqaStyles.radiusSmall,
            overlayColor: SqaStyles.buttonOverlay(context),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                height: 32,
                decoration: BoxDecoration(
                  color: isShowing
                      ? colorScheme.primary.withValues(alpha: 0.1)
                      : colorScheme.surfaceContainerHighest.withValues(
                          alpha: widget.enabled ? 0.4 : 0.2,
                        ),
                  borderRadius: SqaStyles.radiusSmall,
                  border: Border.all(
                    color: isShowing
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.outlineVariant.withValues(
                            alpha: widget.enabled ? 0.5 : 0.2,
                          ),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: widget.items
                            .firstWhere((item) => item.value == widget.value)
                            .child,
                      ),
                    ),
                    const SizedBox(width: 4),
                    RotationTransition(
                      turns: _rotateAnimation,
                      child: Icon(
                        Symbols.keyboard_arrow_down,
                        size: 16,
                        color: isShowing
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

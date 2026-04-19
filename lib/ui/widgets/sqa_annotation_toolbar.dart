import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../core/models/screenshot_tool.dart';
import 'sqa_floating_bar.dart';

/// A centralized toolbar for annotation tools and color selection.
/// Used by both Screen Recorder and Screenshot plugins.
class SqaAnnotationToolbar extends StatelessWidget {
  /// The list of tools to display in this instance.
  final List<ScreenshotTool> enabledTools;

  /// The currently selected tool.
  final ScreenshotTool currentTool;

  /// Callback when a tool is selected.
  final ValueChanged<ScreenshotTool> onToolSelected;

  /// The currently selected color.
  final Color currentColor;

  /// Callback when a color is selected.
  final ValueChanged<Color> onColorSelected;

  /// Callback to clear all annotations.
  final VoidCallback onClear;

  /// Optional list of colors to display.
  final List<Color> availableColors;

  const SqaAnnotationToolbar({
    super.key,
    required this.enabledTools,
    required this.currentTool,
    required this.onToolSelected,
    required this.currentColor,
    required this.onColorSelected,
    required this.onClear,
    this.availableColors = const [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.white,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tools Section
        ...enabledTools.map((tool) {
          final info = _getToolInfo(tool);
          return SqaFloatingBarButton(
            icon: info.icon,
            tooltip: info.label,
            isSelected: currentTool == tool,
            onPressed: () => onToolSelected(tool),
          );
        }),

        const SqaFloatingBarDivider(),

        // Colors Section
        ...availableColors.map(
          (c) => SqaFloatingBarColorPicker(
            color: c,
            isSelected: currentColor == c,
            onTap: () => onColorSelected(c),
          ),
        ),

        const SqaFloatingBarDivider(),

        // Clear Action
        SqaFloatingBarButton(
          icon: Symbols.delete_sweep,
          tooltip: 'Clear All',
          onPressed: onClear,
        ),
      ],
    );
  }

  ({IconData icon, String label}) _getToolInfo(ScreenshotTool tool) {
    return switch (tool) {
      ScreenshotTool.pointer => (icon: Symbols.near_me, label: 'Pointer'),
      ScreenshotTool.pen => (icon: Symbols.edit, label: 'Pen'),
      ScreenshotTool.line => (icon: Symbols.horizontal_rule, label: 'Line'),
      ScreenshotTool.arrow => (icon: Symbols.arrow_outward, label: 'Arrow'),
      ScreenshotTool.marker => (icon: Symbols.brush, label: 'Highlighter'),
      ScreenshotTool.rectangle => (icon: Symbols.rectangle, label: 'Rectangle'),
      ScreenshotTool.text => (icon: Symbols.text_fields, label: 'Text'),
      ScreenshotTool.laser => (icon: Symbols.stylus_laser_pointer, label: 'Laser Pointer'),
    };
  }
}

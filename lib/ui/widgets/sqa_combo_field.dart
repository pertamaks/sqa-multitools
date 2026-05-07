import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'sqa_field.dart';
import 'sqa_popup_menu.dart';

/// A hybrid input field that allows both direct text entry and selection from a dropdown.
/// 
/// Perfect for Faker-style inputs where the user can type a custom value or pick a generator.
class SqaComboField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final TextEditingController? controller;
  final bool isMonospace;
  final bool readOnly;
  final double fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final bool showCopyButton;
  final bool isTransparent;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  
  /// The list of items to show in the dropdown picker.
  final List<SqaPopupMenuItem> items;
  
  /// Tooltip for the dropdown chevron.
  final String pickerTooltip;
  
  /// Icon for the dropdown chevron.
  final IconData pickerIcon;

  const SqaComboField({
    super.key,
    required this.label,
    required this.items,
    this.initialValue,
    this.controller,
    this.isMonospace = false,
    this.readOnly = false,
    this.fontSize = 13.0,
    this.fontWeight,
    this.color,
    this.showCopyButton = false,
    this.isTransparent = false,
    this.hintText,
    this.onChanged,
    this.pickerTooltip = 'Select Option',
    this.pickerIcon = Symbols.expand_more,
  });

  @override
  Widget build(BuildContext context) {
    return SqaField(
      label: label,
      initialValue: initialValue,
      controller: controller,
      isMonospace: isMonospace,
      readOnly: readOnly,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      showCopyButton: showCopyButton,
      isTransparent: isTransparent,
      hintText: hintText,
      onChanged: onChanged,
      trailing: items.isEmpty 
        ? null 
        : SqaPopupMenu(
            icon: Icon(
              pickerIcon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: pickerTooltip,
            children: items,
          ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../ui/widgets/sqa_dropdown.dart';

class CountDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;

  const CountDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SqaDropdown<int>(
      value: value,
      items: [1, 5, 10, 20, 50]
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }
}

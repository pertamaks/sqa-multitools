import 'package:flutter/material.dart';

/// A standardized switch toggle for SQA-Multitools.
///
/// Uses a default scale of 0.6 to provide a more compact and premium feel
/// consistent with the Settings menu.
class SqaSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double scale;

  const SqaSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.scale = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    // We use Transform.scale to maintain consistency with the established
    // design in the settings plugin.
    return SizedBox(
      height: 36, // Match standard toolbar button height
      child: Transform.scale(
        scale: scale,
        child: Switch(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

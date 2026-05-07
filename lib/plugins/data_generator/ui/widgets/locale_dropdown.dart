import 'package:flutter/material.dart';
import 'package:faker_dart/faker_dart.dart';
import '../../../../core/utils/locale_names.dart';
import '../../../../ui/widgets/sqa_dropdown.dart';

class LocaleDropdown extends StatelessWidget {
  final FakerLocaleType value;
  final ValueChanged<FakerLocaleType?> onChanged;

  const LocaleDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  String _formatName(FakerLocaleType locale) {
    return LocaleNames.getDisplayName(locale.name);
  }

  @override
  Widget build(BuildContext context) {
    // Sort locales by name for better UX
    final sortedLocales = FakerLocaleType.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return SqaDropdown<FakerLocaleType>(
      value: value,
      items: sortedLocales.map((locale) {
        return DropdownMenuItem<FakerLocaleType>(
          value: locale,
          child: Text(
            _formatName(locale),
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

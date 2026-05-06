import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:faker_dart/faker_dart.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/providers/faker_locale_provider.dart';
import 'sqa_dropdown.dart';
import 'sqa_settings_tile.dart';

class SqaFakerLocalePicker extends ConsumerWidget {
  const SqaFakerLocalePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(fakerLocaleProvider);

    return SqaSettingsTile(
      title: 'Data Generation Locale',
      subtitle: 'Affects names, addresses, and phone number formats.',
      icon: Symbols.language,
      trailing: SizedBox(
        width: 160,
        child: SqaDropdown<FakerLocaleType>(
          value: currentLocale,
          items: FakerLocaleType.values.map((locale) {
            return DropdownMenuItem<FakerLocaleType>(
              value: locale,
              child: Text(_getDisplayLabel(locale)),
            );
          }).toList(),
          onChanged: (newLocale) {
            if (newLocale != null) {
              ref.read(fakerLocaleProvider.notifier).setLocale(newLocale);
            }
          },
        ),
      ),
    );
  }

  String _getDisplayLabel(FakerLocaleType locale) {
    // Map locale names to more readable formats if needed, or just capitalize
    final name = locale.name.replaceAll('_', '-').toUpperCase();
    return name;
  }
}

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/providers/hotkey_provider.dart';
import '../../../core/services/preferences_service.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_dependency_card.dart';
import '../../../ui/widgets/sqa_dropdown.dart';
import '../../../ui/widgets/sqa_hotkey_field.dart';
import '../../../ui/widgets/sqa_settings_tile.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../providers/screenshot_provider.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';

class ScreenshotSettings extends ConsumerWidget {
  const ScreenshotSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenshotProvider);
    final notifier = ref.read(screenshotProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SqaDependencyCard(pluginName: 'Screenshot'),
        // --- SECTION: CAPTURE ---
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: Text(
            'CAPTURE CONFIGURATION',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SqaTokens.fontSizeSmall,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: SqaTokens.spacingXXLarge),
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.image,
                title: 'Format',
                subtitle: 'Selection image file format',
                trailing: SqaDropdown<String>(
                  value: state.format,
                  onChanged: (val) => notifier.setFormat(val!),
                  items: ['PNG', 'JPG', 'WEBP']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // --- SECTION: FILES ---
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: Text(
            'SYSTEM & FILES',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: SqaTokens.fontSizeSmall,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: SqaTokens.spacingXXLarge),
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.folder,
                title: 'Save Directory',
                subtitle: state.saveDirectory ?? 'Documents/SQA_Screenshots',
                trailing: SqaHoverIconButton(
                  icon: Symbols.edit,
                  onPressed: () async {
                    final directoryPath = await getDirectoryPath(
                      initialDirectory: state.saveDirectory,
                      confirmButtonText: 'Select Save Folder',
                    );
                    if (directoryPath != null) {
                      notifier.setSaveDirectory(directoryPath);
                    }
                  },
                  tooltip: 'Change Save Directory',
                  iconSize: SqaTokens.spacingLarge,
                ),
              ),
            ],
          ),
        ),

        // --- SECTION: HOTKEYS ---
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HOTKEYS',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: SqaTokens.fontSizeSmall,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Note: Global hotkeys must include at least one modifier key (Ctrl, Alt, or Shift).',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        SqaCard(
          padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingLarge, vertical: SqaTokens.spacingSmall),
          child: Column(
            children: [
              SqaHotkeyField(
                label: 'Full Screen Capture',
                value: ref.watch(hotkeySettingsProvider).ssFullscreen,
                onSave: (info) {
                  final error = ref
                      .read(hotkeySettingsProvider.notifier)
                      .updateHotkey(PreferencesService.keyHotkeySsFullscreen, info);
                  if (error != null) {
                    SqaToast.show(context, error, type: SqaToastType.error);
                  } else {
                    SqaToast.show(context, 'Full Screen hotkey updated!', type: SqaToastType.success);
                  }
                },
              ),
              const Divider(height: 1, indent: 0),
              SqaHotkeyField(
                label: 'Area Capture',
                value: ref.watch(hotkeySettingsProvider).ssArea,
                onSave: (info) {
                  final error = ref
                      .read(hotkeySettingsProvider.notifier)
                      .updateHotkey(PreferencesService.keyHotkeySsArea, info);
                  if (error != null) {
                    SqaToast.show(context, error, type: SqaToastType.error);
                  } else {
                    SqaToast.show(context, 'Area hotkey updated!', type: SqaToastType.success);
                  }
                },
              ),
              const Divider(height: 1, indent: 0),
              SqaHotkeyField(
                label: 'Long Screenshot',
                value: ref.watch(hotkeySettingsProvider).ssLong,
                onSave: (info) {
                  final error = ref
                      .read(hotkeySettingsProvider.notifier)
                      .updateHotkey(PreferencesService.keyHotkeySsLong, info);
                  if (error != null) {
                    SqaToast.show(context, error, type: SqaToastType.error);
                  } else {
                    SqaToast.show(context, 'Long Screenshot hotkey updated!', type: SqaToastType.success);
                  }
                },
              ),
              const Divider(height: 1, indent: 0),
              SqaHotkeyField(
                label: 'General Capture',
                value: ref.watch(hotkeySettingsProvider).screenshotToggle,
                onSave: (info) {
                  final error = ref
                      .read(hotkeySettingsProvider.notifier)
                      .updateHotkey(PreferencesService.keyHotkeyScreenshotToggle, info);
                  if (error != null) {
                    SqaToast.show(context, error, type: SqaToastType.error);
                  } else {
                    SqaToast.show(context, 'General screenshot hotkey updated!', type: SqaToastType.success);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

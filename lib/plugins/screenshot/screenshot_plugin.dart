import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:file_selector/file_selector.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_dropdown.dart';
import '../../ui/widgets/sqa_hotkey_field.dart';
import '../../ui/widgets/sqa_toast.dart';
import '../../core/services/preferences_service.dart';
import '../../core/providers/hotkey_provider.dart';
import 'providers/screenshot_provider.dart';
import 'ui/screenshot_view.dart';

class ScreenshotPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.screenshot';
  @override
  String get name => 'Screenshot';
  @override
  String get description => 'Take partial or full screenshots.';
  @override
  IconData get icon => Symbols.crop;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const ScreenshotView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const _ScreenshotSettings();
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _ScreenshotSettings extends ConsumerWidget {
  const _ScreenshotSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenshotProvider);
    final notifier = ref.read(screenshotProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- SECTION: CAPTURE ---
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'CAPTURE CONFIGURATION',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 24),
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
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'SYSTEM & FILES',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.folder,
                title: 'Save Directory',
                subtitle: state.saveDirectory ?? 'Documents/SQA_Screenshots',
                trailing: IconButton(
                  icon: const Icon(Symbols.edit, size: 16),
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
                ),
              ),
            ],
          ),
        ),

        // --- SECTION: HOTKEYS ---
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'HOTKEYS',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.0,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SqaCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SqaHotkeyField(
            label: 'Start Capture',
            value: ref.watch(hotkeySettingsProvider).screenshotToggle,
            onSave: (info) {
              final error = ref
                  .read(hotkeySettingsProvider.notifier)
                  .updateHotkey(PreferencesService.keyHotkeyScreenshotToggle, info);
              if (error != null) {
                SqaToast.show(context, error, type: SqaToastType.error);
              } else {
                SqaToast.show(context, 'Screenshot hotkey updated!', type: SqaToastType.success);
              }
            },
          ),
        ),
      ],
    );
  }
}

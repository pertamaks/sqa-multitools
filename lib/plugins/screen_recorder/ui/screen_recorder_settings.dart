import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:file_selector/file_selector.dart';
import '../providers/screen_recorder_provider.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_settings_tile.dart';
import '../../../../ui/widgets/sqa_switch.dart';
import '../../../../ui/widgets/sqa_dropdown.dart';
import '../../../../ui/widgets/sqa_dependency_card.dart';
import '../../../../ui/widgets/sqa_hotkey_field.dart';
import '../../../../ui/widgets/sqa_toast.dart';
import '../../../../core/providers/ffmpeg_provider.dart';
import '../../../../core/providers/hotkey_provider.dart';
import '../../../../core/services/preferences_service.dart';

class ScreenRecorderSettings extends ConsumerWidget {
  const ScreenRecorderSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SqaDependencyCard(pluginName: 'Screen Recorder'),

        // --- SECTION: AUDIO ---
        _buildSectionHeader(theme, 'AUDIO CONFIGURATION'),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.mic,
                title: 'Capture Microphone',
                subtitle: 'Record voice input during session',
                trailing: SqaSwitch(
                  value: state.microphoneEnabled,
                  onChanged: (v) => notifier.setMicrophone(v),
                ),
              ),
              if (ref.watch(ffmpegProvider).isReady &&
                  state.microphoneEnabled) ...[
                const Divider(height: 1, indent: 56),
                SqaSettingsTile(
                  icon: Symbols.settings_input_component,
                  title: 'Microphone Device',
                  subtitle: 'Select active input source',
                  trailing: SqaDropdown<String?>(
                    value: state.selectedAudioDevice,
                    onChanged: (val) => notifier.setSelectedAudioDevice(val),
                    items: state.availableAudioDevices.isEmpty
                        ? <DropdownMenuItem<String?>>[
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('No devices found'),
                            ),
                          ]
                        : state.availableAudioDevices
                              .map<DropdownMenuItem<String?>>(
                                (e) => DropdownMenuItem<String?>(
                                  value: e,
                                  child: Text(
                                    e,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),

        // --- SECTION: VISUALS ---
        _buildSectionHeader(theme, 'VISUAL FEEDBACK'),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.near_me,
                title: 'Show Cursor',
                subtitle: 'Highlight mouse clicks and movement',
                trailing: SqaSwitch(
                  value: state.showCursor,
                  onChanged: (bool v) => notifier.setShowCursor(v),
                ),
              ),
              const Divider(height: 1, indent: 56),
              // Left Click Color
              SqaSettingsTile(
                icon: Symbols.left_click,
                title: 'Left Click Color',
                subtitle: 'Color for primary click ripples',
                trailing: SqaDropdown<Color>(
                  value: state.clickFeedbackColor,
                  onChanged: (Color? val) =>
                      notifier.setClickFeedbackColor(val!),
                  items: _buildColorItems(),
                ),
              ),
              const Divider(height: 1, indent: 56),
              // Right Click Color
              SqaSettingsTile(
                icon: Symbols.right_click,
                title: 'Right Click Color',
                subtitle: 'Color for secondary click ripples',
                trailing: SqaDropdown<Color>(
                  value: state.rightClickFeedbackColor,
                  onChanged: (Color? val) =>
                      notifier.setRightClickFeedbackColor(val!),
                  items: _buildColorItems(),
                ),
              ),
            ],
          ),
        ),

        // --- SECTION: RECORDING ---
        _buildSectionHeader(theme, 'RECORDING SETUP'),
        SqaCard(
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.photo_size_select_large,
                title: 'Resolution',
                subtitle: 'Target video dimensions',
                trailing: SqaDropdown<String>(
                  value: state.resolution,
                  onChanged: (String? val) => notifier.setResolution(val!),
                  items: ['1080p', '720p', '480p', '360p']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
              const Divider(height: 1, indent: 56),
              SqaSettingsTile(
                icon: Symbols.speed,
                title: 'Framerate',
                subtitle: 'Smoothness of the recording',
                trailing: SqaDropdown<int>(
                  value: state.framerate,
                  onChanged: (int? val) => notifier.setFramerate(val!),
                  items: [60, 30, 15, 10]
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e, child: Text('${e}fps')),
                      )
                      .toList(),
                ),
              ),
              const Divider(height: 1, indent: 56),
              SqaSettingsTile(
                icon: Symbols.schedule,
                title: 'Start Delay',
                subtitle: 'Wait duration before capture',
                trailing: SqaDropdown<int>(
                  value: state.delaySeconds,
                  onChanged: (int? val) => notifier.setDelay(val!),
                  items: [0, 2, 5, 10]
                      .map(
                        (e) => DropdownMenuItem(value: e, child: Text('${e}s')),
                      )
                      .toList(),
                ),
              ),
              const Divider(height: 1, indent: 56),
              SqaSettingsTile(
                icon: Symbols.movie_filter,
                title: 'Export Format',
                subtitle: 'Video container type',
                trailing: SqaDropdown<String>(
                  value: state.format,
                  onChanged: (String? val) => notifier.setFormat(val!),
                  items: ['MP4', 'MKV']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        // --- SECTION: FILES ---
        _buildSectionHeader(theme, 'SYSTEM & FILES'),
        SqaCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              SqaSettingsTile(
                icon: Symbols.folder,
                title: 'Save Directory',
                subtitle: state.saveDirectory ?? 'Default Videos Directory',
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
          padding: const EdgeInsets.only(top: 24, bottom: 12),
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
          child: Column(
            children: [
              SqaHotkeyField(
                label: 'Start / Stop Recording',
                value: ref.watch(hotkeySettingsProvider).recordToggle,
                onSave: (info) {
                  final error = ref
                      .read(hotkeySettingsProvider.notifier)
                      .updateHotkey(
                        PreferencesService.keyHotkeyRecordToggle,
                        info,
                      );
                  if (error != null) {
                    SqaToast.show(context, error, type: SqaToastType.error);
                  } else {
                    SqaToast.show(
                      context,
                      'Recorder hotkey updated!',
                      type: SqaToastType.success,
                    );
                  }
                },
              ),
              const Divider(height: 1, indent: 0),
              SqaHotkeyField(
                label: 'Quick Area Record',
                value: ref.watch(hotkeySettingsProvider).areaRecordToggle,
                onSave: (info) {
                  final error = ref
                      .read(hotkeySettingsProvider.notifier)
                      .updateHotkey(
                        PreferencesService.keyHotkeyAreaRecord,
                        info,
                      );
                  if (error != null) {
                    SqaToast.show(context, error, type: SqaToastType.error);
                  } else {
                    SqaToast.show(
                      context,
                      'Quick Area hotkey updated!',
                      type: SqaToastType.success,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 1.0,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  List<DropdownMenuItem<Color>> _buildColorItems() {
    return [
          (Colors.white, 'White'),
          (Colors.yellow, 'Yellow'),
          (Colors.amber, 'Amber'),
          (Colors.cyan, 'Cyan'),
          (Colors.pink, 'Pink'),
          (Colors.limeAccent, 'Lime'),
        ]
        .map(
          (e) => DropdownMenuItem(
            value: e.$1,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: e.$1,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(child: Text(e.$2, overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        )
        .toList();
  }
}

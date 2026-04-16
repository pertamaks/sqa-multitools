import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:file_selector/file_selector.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_icon_container.dart';
import '../../ui/widgets/sqa_segmented_button.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_switch.dart';
import '../../ui/widgets/sqa_dropdown.dart';
import '../../ui/widgets/sqa_modal.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_button.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../core/models/capture_mode.dart';
import '../../core/providers/plugin_provider.dart';
import '../../core/providers/hotkey_provider.dart';
import '../../core/services/preferences_service.dart';
import '../../ui/widgets/sqa_hotkey_field.dart';
import '../../ui/widgets/sqa_toast.dart';
import 'providers/screen_recorder_provider.dart';
import 'models/screen_recorder_state.dart';

class ScreenRecorderPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.screen_recorder';
  @override
  String get name => 'Screen Recorder';
  @override
  String get description => 'Capture your workflow in high quality.';
  @override
  IconData get icon => Symbols.videocam;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _ScreenRecorderView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const _ScreenRecorderSettings();
  }

  @override
  Future<void> initialize() async {
    // Force a monitor refresh on init
    // notifier is not available here easily since it's an interface,
    // but the provider will do it on _checkEngine or we can leave it to the first load.
  }
  @override
  Future<void> dispose() async {}
}

class _ScreenRecorderSettings extends ConsumerWidget {
  const _ScreenRecorderSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!state.engineReady)
          SqaCard(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            backgroundColor: theme.colorScheme.errorContainer.withValues(
              alpha: 0.1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Symbols.warning,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Missing Dependencies',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The recording engine (FFmpeg) is not installed. Technical settings are hidden until resolved.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SqaButton.tonal(
                  onPressed: () => notifier.installEngine(),
                  icon: Symbols.download,
                  label: 'Download Engine',
                ),
              ],
            ),
          ),

        // --- SECTION: AUDIO ---
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'AUDIO CONFIGURATION',
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
                icon: Symbols.mic,
                title: 'Capture Microphone',
                subtitle: 'Record voice input during session',
                trailing: SqaSwitch(
                  value: state.microphoneEnabled,
                  onChanged: (v) => notifier.setMicrophone(v),
                ),
              ),
              if (state.engineReady && state.microphoneEnabled) ...[
                const Divider(height: 1, indent: 56),
                SqaSettingsTile(
                  icon: Symbols.settings_input_component,
                  title: 'Microphone Device',
                  subtitle: 'Select active input source',
                  trailing: SqaDropdown<String?>(
                    value: state.selectedAudioDevice,
                    onChanged: (val) => notifier.setSelectedAudioDevice(val),
                    items:
                        state.availableAudioDevices.isEmpty
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
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'VISUAL FEEDBACK',
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
                  onChanged: (Color? val) => notifier.setClickFeedbackColor(val!),
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
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'RECORDING SETUP',
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
                icon: Symbols.photo_size_select_large,
                title: 'Resolution',
                subtitle: 'Target video dimensions',
                trailing: SqaDropdown<String>(
                  value: state.resolution,
                  onChanged: (String? val) => notifier.setResolution(val!),
                  items:
                      ['1080p', '720p', '480p', '360p']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
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
                  items:
                      [60, 30, 15, 10]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('${e}fps'),
                            ),
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
                  items:
                      [0, 2, 5, 10]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('${e}s'),
                            ),
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
                  items:
                      ['MP4', 'MKV']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
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
          child: SqaHotkeyField(
            label: 'Start / Stop Recording',
            value: ref.watch(hotkeySettingsProvider).recordToggle,
            onSave: (info) {
              final error =
                  ref
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
        ),
      ],
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
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(e.$2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        )
        .toList();
  }
}

class _ScreenRecorderView extends ConsumerStatefulWidget {
  const _ScreenRecorderView();

  @override
  ConsumerState<_ScreenRecorderView> createState() =>
      _ScreenRecorderViewState();
}

class _ScreenRecorderViewState extends ConsumerState<_ScreenRecorderView> {
  @override
  void initState() {
    super.initState();
    // Register hotkeys when the user enters the screen recorder tool
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(screenRecorderProvider.notifier).registerGlobalHotkeys();
      }
    });
  }

  void _handleStart(BuildContext context) async {
    final state = ref.read(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);

    if (state.engineDownloadProgress != null) {
      // Already downloading
      return;
    }

    if (!state.engineReady) {
      // ... (Engine download logic remains the same)
      final shouldDownload = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Download Engine Required'),
          content: const Text(
            'The Screen Recorder requires a lightweight video encoding engine (FFmpeg, ~30MB) to function.\n\n'
            'Do you want to download and install it now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Download'),
            ),
          ],
        ),
      );

      if (shouldDownload == true) {
        try {
          await notifier.installEngine();
          // After engine is ready, continue to monitor selection
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
          }
          return;
        }
      } else {
        return;
      }
    }

    // Seamless Entry: Skip monitor picker for all modes.
    if (state.captureMode == CaptureMode.window) {
      notifier.setTargetingWindow(true);
    }
    notifier.startOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    final theme = Theme.of(context);

    return SqaPluginLayout(
      icon: Symbols.videocam,
      title: 'Screen Recorder',
      description: 'Record your screen, camera, and audio inputs.',
      // Mini download progress on the top icon if downloading
      trailing: state.engineDownloadProgress != null
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                value: state.engineDownloadProgress! >= 0
                    ? state.engineDownloadProgress
                    : null,
                strokeWidth: 2,
              ),
            )
          : null,
      child: SqaPluginScrollableContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hub Header: Session Configuration Summary
            SqaCard(
              padding: const EdgeInsets.all(24.0),
              backgroundColor: state.isOverlayVisible
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                  : null,
              child: Column(
                children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isOverlayVisible
                            ? 'OVERLAY ACTIVE'
                            : 'READY TO RECORD',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Config Summary Row
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ConfigSnippet(
                            icon: switch (state.captureMode) {
                              CaptureMode.fullScreen => Symbols.fullscreen,
                              CaptureMode.area => Symbols.crop_free,
                              CaptureMode.window => Symbols.window,
                            },
                            label: switch (state.captureMode) {
                              CaptureMode.fullScreen => 'Full Screen',
                              CaptureMode.area => 'Select Area',
                              CaptureMode.window => 'Select Window',
                            },
                          ),
                          const SizedBox(height: 8),
                          _ConfigSnippet(
                            icon:
                                state.microphoneEnabled
                                    ? Symbols.mic
                                    : Symbols.mic_off,
                            label:
                                state.microphoneEnabled
                                    ? (state.selectedAudioDevice ?? 'Mic On')
                                    : 'No Audio',
                          ),
                          const SizedBox(height: 8),
                          _ConfigSnippet(
                            icon: Symbols.photo_size_select_large,
                            label:
                                '${state.resolution} @ ${state.framerate}fps',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tune (Settings) Button
                Tooltip(
                  message: 'Recording Settings',
                  child: SqaIconContainer(
                    icon: Symbols.tune,
                    color: theme.colorScheme.primary,
                    backgroundColor: Colors.transparent,
                    size: 32,
                    iconSize: 18,
                    onTap: () {
                      ref
                          .read(navigationServiceProvider)
                          .jumpToPluginSettings(ScreenRecorderPlugin().id);
                    },
                  ),
                ),
              ],
            ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SqaButton.primary(
                          onPressed: state.isOverlayVisible
                              ? () => notifier.cancelOverlay()
                              : () => _handleStart(context),
                          icon: state.isOverlayVisible
                              ? Symbols.close
                              : Symbols.play_arrow,
                          label: state.engineDownloadProgress != null
                              ? 'Downloading Engine...'
                              : (state.isOverlayVisible
                                    ? 'Cancel Overlay'
                                    : 'Enter Overlay'),
                          color: state.isOverlayVisible
                              ? theme.colorScheme.error
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      SqaButton.tonal(
                        onPressed: () => notifier.openSaveDirectory(),
                        icon: Symbols.folder_open,
                        label: 'Folder',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Capture Mode Selection
            Text(
              'CAPTURE MODE',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SqaSegmentedButton<CaptureMode>(
              segments: const [
                ButtonSegment(
                  value: CaptureMode.fullScreen,
                  icon: Icon(Symbols.fullscreen, size: 18),
                  label: Text('Full Screen'),
                ),
                ButtonSegment(
                  value: CaptureMode.area,
                  icon: Icon(Symbols.crop_free, size: 18),
                  label: Text('Area'),
                ),
                ButtonSegment(
                  value: CaptureMode.window,
                  icon: Icon(Symbols.window, size: 18),
                  label: Text('Window'),
                ),
              ],
              selected: {state.captureMode},
              onSelectionChanged: (Set<CaptureMode> set) =>
                  notifier.setCaptureMode(set.first),
            ),

            const SizedBox(height: 32),

            // Recent Recordings List
            if (state.recentRecordings.isNotEmpty) ...[
              Text(
                'RECENT RECORDINGS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SqaCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ...state.recentRecordings.map((RecordingInfo info) {
                      final isLast = state.recentRecordings.last == info;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RecentRecordingTile(
                            info: info,
                            onDelete: () async {
                              final confirm = await SqaModal.showConfirm(
                                context,
                                title: 'Delete Recording?',
                                message:
                                    'Are you sure you want to permanently delete this file?',
                                confirmLabel: 'Delete',
                                confirmColor: theme.colorScheme.error,
                                icon: Symbols.delete,
                              );
                              if (confirm == true) {
                                notifier.deleteRecording(info);
                              }
                            },
                            onOpen: () => Process.start(
                              'explorer.exe',
                              [info.file.path],
                            ),
                          ),
                          if (!isLast) const Divider(height: 1, indent: 56),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConfigSnippet extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ConfigSnippet({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _RecentRecordingTile extends StatelessWidget {
  final RecordingInfo info;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const _RecentRecordingTile({
    required this.info,
    required this.onDelete,
    required this.onOpen,
  });

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filename = info.file.uri.pathSegments.last;

    return ListTile(
      dense: true,
      leading: SqaIconContainer(
        icon: Symbols.movie,
        color: theme.colorScheme.primary,
        size: 32,
        iconSize: 16,
      ),
      title: Text(
        filename,
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${_formatSize(info.size)} • ${info.modified.hour}:${info.modified.minute.toString().padLeft(2, '0')}',
        style: theme.textTheme.labelSmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Symbols.play_arrow, size: 18),
            onPressed: onOpen,
            tooltip: 'Play',
          ),
          IconButton(
            icon: const Icon(Symbols.delete, size: 18),
            onPressed: onDelete,
            tooltip: 'Delete',
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}

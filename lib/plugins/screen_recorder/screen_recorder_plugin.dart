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
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_button.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../core/models/capture_mode.dart';
import 'providers/screen_recorder_provider.dart';

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
  String? get badge => 'ALPHA';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SqaSettingsTile(
          icon: Symbols.folder,
          title: 'Save Path',
          subtitle: state.saveDirectory ?? 'Default Videos Directory',
          onTap: () async {
            final directoryPath = await getDirectoryPath(
              initialDirectory: state.saveDirectory,
              confirmButtonText: 'Select Save Folder',
            );
            if (directoryPath != null) {
              notifier.setSaveDirectory(directoryPath);
            }
          },
          trailing: const Icon(Symbols.edit, size: 16),
        ),
      ],
    );
  }
}

class _ScreenRecorderView extends ConsumerStatefulWidget {
  const _ScreenRecorderView();

  @override
  ConsumerState<_ScreenRecorderView> createState() => _ScreenRecorderViewState();
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
            // Primary Recording Card
            SqaCard(
              padding: const EdgeInsets.all(24.0),
              backgroundColor: state.isOverlayVisible
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
                  : null,
              borderSide: state.isOverlayVisible
                  ? BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : null,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                          const SizedBox(height: 8),
                          Text(
                            '00:00',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SqaIconContainer(
                        icon: Symbols.videocam,
                        color: theme.colorScheme.primary,
                        size: 56,
                        iconSize: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SqaButton.tonal(
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
                                    : 'Start Overlay'),
                          color: state.isOverlayVisible
                              ? theme.colorScheme.error
                              : null,
                        ),
                      ),
                      if (!state.isOverlayVisible) ...[
                        const SizedBox(width: 12),
                        SqaButton.tonal(
                          onPressed: () => notifier.openSaveDirectory(),
                          icon: Symbols.folder_open,
                          label: 'Folder',
                        ),
                      ],
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
              onSelectionChanged: (Set<CaptureMode> set) => notifier.setCaptureMode(set.first),
            ),

            const SizedBox(height: 32),

            Text(
              'RECORDING SETTINGS',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Consolidated Settings List
            SqaCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SqaSettingsTile(
                    icon: Symbols.mic,
                    title: 'Microphone',
                    subtitle: 'Capture voice input',
                    trailing: SqaSwitch(
                      value: state.microphoneEnabled,
                      onChanged: (bool v) => notifier.setMicrophone(v),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
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
                  SqaSettingsTile(
                    icon: Symbols.photo_size_select_large,
                    title: 'Resolution',
                    subtitle: 'Target recording quality',
                    trailing: SqaDropdown<String>(
                      value: state.resolution,
                      onChanged: (String? val) => notifier.setResolution(val!),
                      items: ['1080p', '720p']
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
                    subtitle: 'Target frames per second',
                    trailing: SqaDropdown<int>(
                      value: state.framerate,
                      onChanged: (int? val) => notifier.setFramerate(val!),
                      items: [60, 30]
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
                    title: 'Delay',
                    subtitle: 'Timer before recording starts',
                    trailing: SqaDropdown<int>(
                      value: state.delaySeconds,
                      onChanged: (int? val) => notifier.setDelay(val!),
                      items: [0, 2, 5, 10]
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text('${e}s'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
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
import 'models/capture_mode.dart';
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
    return const Center(child: Text('Screen Recorder Settings'));
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _ScreenRecorderView extends ConsumerWidget {
  const _ScreenRecorderView();

  String _formatDuration(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return h == '00' ? '$m:$s' : '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    final theme = Theme.of(context);

    return SqaPluginLayout(
      icon: Symbols.videocam,
      title: 'Screen Recorder',
      description: 'Record your screen, camera, and audio inputs.',
      child: SqaPluginScrollableContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary Recording Card
            SqaCard(
              padding: const EdgeInsets.all(24.0),
              backgroundColor: state.isRecording
                  ? theme.colorScheme.errorContainer.withValues(alpha: 0.1)
                  : null,
              borderSide: state.isRecording
                  ? BorderSide(
                      color: theme.colorScheme.error.withValues(alpha: 0.3),
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
                            state.isRecording
                                ? (state.isPaused
                                      ? 'RECORDING PAUSED'
                                      : 'RECORDING...')
                                : 'READY TO RECORD',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: state.isRecording
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDuration(state.durationSeconds),
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      SqaIconContainer(
                        icon: state.isRecording
                            ? Symbols.fiber_manual_record
                            : Symbols.videocam,
                        color: state.isRecording
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
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
                          onPressed: () => notifier.toggleRecording(),
                          icon: state.isRecording
                              ? Symbols.stop
                              : Symbols.play_arrow,
                          label: state.isRecording
                              ? 'Stop Recording'
                              : 'Start Recording',
                          color: state.isRecording
                              ? theme.colorScheme.error
                              : null,
                        ),
                      ),
                      if (state.isRecording) ...[
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: () => notifier.togglePause(),
                          icon: Icon(
                            state.isPaused ? Symbols.play_arrow : Symbols.pause,
                          ),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            minimumSize: const Size(48, 48),
                          ),
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
              onSelectionChanged: (set) => notifier.setCaptureMode(set.first),
            ),

            if (state.captureMode == CaptureMode.window) ...[
              const SizedBox(height: 16),
              SqaCard(
                padding: EdgeInsets.zero,
                child: SqaSettingsTile(
                  icon: Symbols.desktop_windows,
                  title: 'Target Window',
                  subtitle: state.targetWindowName,
                  trailing: const Icon(Symbols.expand_more, size: 20),
                  onTap: () {
                    if (state.targetWindowName == 'Visual Studio Code') {
                      notifier.setTargetWindow('Google Chrome');
                    } else {
                      notifier.setTargetWindow('Visual Studio Code');
                    }
                  },
                ),
              ),
            ],

            if (state.captureMode == CaptureMode.area) ...[
              const SizedBox(height: 16),
              SqaCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Symbols.info, size: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'A transparent overlay will appear to select the capture area.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    SqaButton.tonal(
                      onPressed: () => notifier.startAreaSelection(),
                      label: 'Define Area',
                      width: 110,
                    ),
                  ],
                ),
              ),
            ],

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
                    subtitle: 'Capture voice and external audio',
                    trailing: SqaSwitch(
                      value: state.microphoneEnabled,
                      onChanged: (v) => notifier.setMicrophone(v),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  SqaSettingsTile(
                    icon: Symbols.volume_up,
                    title: 'System Audio',
                    subtitle: 'Capture application sounds',
                    trailing: SqaSwitch(
                      value: state.systemAudioEnabled,
                      onChanged: (v) => notifier.setSystemAudio(v),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  SqaSettingsTile(
                    icon: Symbols.near_me,
                    title: 'Show Cursor',
                    subtitle: 'Highlight mouse clicks and movement',
                    trailing: SqaSwitch(
                      value: state.showCursor,
                      onChanged: (v) => notifier.setShowCursor(v),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  SqaSettingsTile(
                    icon: Symbols.photo_size_select_large,
                    title: 'Resolution',
                    subtitle: 'Target recording quality',
                    trailing: SqaDropdown<String>(
                      value: state.resolution,
                      onChanged: (val) => notifier.setResolution(val!),
                      items: ['1080p', '720p']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  SqaSettingsTile(
                    icon: Symbols.movie,
                    title: 'Format',
                    subtitle: 'Output video file format',
                    trailing: SqaDropdown<String>(
                      value: state.format,
                      onChanged: (val) => notifier.setFormat(val!),
                      items: ['MP4', 'MKV']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
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
                      onChanged: (val) => notifier.setDelay(val!),
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

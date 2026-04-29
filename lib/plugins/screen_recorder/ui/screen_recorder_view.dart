import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/screen_recorder_provider.dart';
import '../models/screen_recorder_state.dart';
import '../screen_recorder_plugin.dart';
import './widgets/config_snippet.dart';
import './widgets/recording_tile.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_icon_container.dart';
import '../../../../ui/widgets/sqa_segmented_button.dart';
import '../../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../../core/models/capture_mode.dart';
import '../../../../core/providers/plugin_provider.dart';
import '../../../../core/providers/ffmpeg_provider.dart';

class ScreenRecorderView extends ConsumerStatefulWidget {
  const ScreenRecorderView({super.key});

  @override
  ConsumerState<ScreenRecorderView> createState() => _ScreenRecorderViewState();
}

class _ScreenRecorderViewState extends ConsumerState<ScreenRecorderView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(screenRecorderProvider.notifier).registerGlobalHotkeys();
      }
    });
  }

  void _handleStart(BuildContext context) async {
    final state = ref.read(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    final engineStatus = ref.read(ffmpegProvider);

    if (engineStatus.isDownloading) return;

    if (!engineStatus.isReady) {
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
          await ref.read(ffmpegProvider.notifier).download();
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

    if (state.captureMode == CaptureMode.window) {
      notifier.setTargetingWindow(true);
    }
    notifier.startOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    final ffmpegStatus = ref.watch(ffmpegProvider);
    final theme = Theme.of(context);

    return SqaPluginLayout(
      icon: Symbols.videocam,
      title: 'Screen Recorder',
      description: 'Record your screen, camera, and audio inputs.',
      trailing: ffmpegStatus.isDownloading
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                value:
                    ffmpegStatus.downloadProgress != null &&
                        ffmpegStatus.downloadProgress! >= 0
                    ? ffmpegStatus.downloadProgress
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ConfigSnippet(
                                  icon: switch (state.captureMode) {
                                    CaptureMode.fullScreen =>
                                      Symbols.fullscreen,
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
                                ConfigSnippet(
                                  icon: state.microphoneEnabled
                                      ? Symbols.mic
                                      : Symbols.mic_off,
                                  label: state.microphoneEnabled
                                      ? (state.selectedAudioDevice ?? 'Mic On')
                                      : 'No Audio',
                                ),
                                const SizedBox(height: 8),
                                ConfigSnippet(
                                  icon: Symbols.photo_size_select_large,
                                  label:
                                      '${state.resolution} @ ${state.framerate}fps',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
                                .jumpToPluginSettings(
                                  ScreenRecorderPlugin().id,
                                );
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
                          label: ffmpegStatus.isDownloading
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
            const SizedBox(height: 8),
            Text(
              switch (state.captureMode) {
                CaptureMode.fullScreen =>
                  'Captures the entire primary monitor including taskbars.',
                CaptureMode.area =>
                  'Allows you to draw a custom rectangle on the screen for selective capture.',
                CaptureMode.window =>
                  'Automatically locks onto a specific application window.',
              },
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
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
                          RecordingTile(
                            info: info,
                            onDelete: () => notifier.deleteRecording(info),
                            onRename: (newName) =>
                                notifier.renameRecording(info, newName),
                            onValidate: (name) =>
                                notifier.validateNewName(name, info),
                            onOpen: () =>
                                Process.start('explorer.exe', [info.file.path]),
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

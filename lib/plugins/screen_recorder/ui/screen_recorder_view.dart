import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/window/window_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'dart:convert';
import 'package:path/path.dart' as p;
import '../providers/screen_recorder_provider.dart';
import '../models/screen_recorder_state.dart';
import '../screen_recorder_plugin.dart';
import './widgets/config_snippet.dart';
import './widgets/recording_tile.dart';
import '../../../../ui/widgets/sqa_history_list.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_segmented_button.dart';
import '../../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../core/models/capture_mode.dart';
import '../../../../core/providers/plugin_provider.dart';
import '../../../../core/providers/ffmpeg_provider.dart';
import '../../../../core/providers/hotkey_provider.dart';
import '../../../../core/utils/platform_utils.dart';
import 'package:screen_retriever/screen_retriever.dart';

class ScreenRecorderView extends ConsumerStatefulWidget {
  const ScreenRecorderView({super.key});

  @override
  ConsumerState<ScreenRecorderView> createState() => _ScreenRecorderViewState();
}

class _ScreenRecorderViewState extends ConsumerState<ScreenRecorderView> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  final GlobalKey _historyListKey = GlobalKey();

  List<Display> _displays = [];
  Display? _selectedDisplay;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(screenRecorderProvider).searchQuery,
    );
    _scrollController = ScrollController();
    if (Platform.isLinux) {
      _loadDisplays();
    }
  }

  Future<void> _loadDisplays() async {
    final displays = await screenRetriever.getAllDisplays();
    final primary = await screenRetriever.getPrimaryDisplay();
    if (mounted) {
      setState(() {
        _displays = displays;
        if (displays.isNotEmpty) {
          _selectedDisplay = displays.firstWhere(
            (d) => d.id == primary.id,
            orElse: () => displays.first,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleStart(BuildContext context) async {
    final notifier = ref.read(screenRecorderProvider.notifier);
    final engineStatus = ref.read(ffmpegProvider);

    if (engineStatus.isDownloading) return;

    if (!engineStatus.isReady) {
      final shouldDownload = await showDialog<bool>(
        context: context,
        builder: (ctx) => SqaModal<bool>.confirm(
          title: 'Engine Required',
          message:
                            'The Screen Recorder requires a lightweight video encoding engine (FFmpeg${engineStatus.formattedRemoteSize != null ? ', ~${engineStatus.formattedRemoteSize}' : ''}) to function fully.\n\nDo you want to download and install it now?',
          confirmLabel: 'Download',
          cancelLabel: 'Cancel',
          icon: Symbols.download,
        ),
      );

      if (shouldDownload == true) {
        try {
          await ref.read(ffmpegProvider.notifier).download();
        } catch (e) {
          // Errors are now handled globally in MainToolbar
          return;
        }
      } else {
        return;
      }
    }

    if (!mounted) return;

    if (Platform.isLinux) {
      if (ref.read(screenRecorderProvider).isRecording) {
        await notifier.stopWaylandPortal();
        return;
      }
      await notifier.triggerWaylandPortal(_selectedDisplay);
      final currentPlugin = ref.read(activePluginProvider);
      if (currentPlugin != null) {
        ref.read(navigationServiceProvider).togglePlugin(currentPlugin);
      }
      return;
    }

    // Only auto-start if the user hasn't switched away to another plugin
    final currentPlugin = ref.read(activePluginProvider);
    if (currentPlugin?.id != 'com.sqa.screen_recorder') {
      return;
    }

    notifier.startOverlay();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenRecorderProvider);
    final notifier = ref.read(screenRecorderProvider.notifier);
    final ffmpegStatus = ref.watch(ffmpegProvider);
    final hotkeys = ref.watch(hotkeySettingsProvider);
    final theme = Theme.of(context);

    // Auto-scroll to newly added recordings
    ref.listen(screenRecorderProvider.select((s) => s.recentRecordings), (previous, next) {
      if (previous != null && next.isNotEmpty) {
        if (previous.isEmpty || next.first.file.path != previous.first.file.path) {
          Future.delayed(const Duration(milliseconds: 150), () {
            if (!mounted) return;
            final contextToScroll = _historyListKey.currentContext;
            if (contextToScroll != null && contextToScroll.mounted) {
              Scrollable.ensureVisible(
                contextToScroll,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                alignment: 0.0,
              );
            }
          });
        }
      }
    });

    return SqaPluginLayout(
      icon: Symbols.videocam,
      title: 'Screen Recorder',
      description: 'Record your screen, camera, and audio inputs.',
      searchController: _searchController,
      onSearchChanged: (val) =>
          ref.read(screenRecorderProvider.notifier).setSearchQuery(val),
      searchHint: 'Filter recordings...',
      trailing: ffmpegStatus.isDownloading
          ? SizedBox(
              width: SqaTokens.spacingLarge,
              height: SqaTokens.spacingLarge,
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
        controller: _scrollController,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hub Header: Session Configuration Summary
            SqaCard(
              padding: const EdgeInsets.all(SqaTokens.spacingXLarge),
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
                            const SizedBox(height: SqaTokens.spacingMedium),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (Platform.isLinux)
                                  ConfigSnippet(
                                    icon: Symbols.desktop_windows,
                                    label: _displays.length > 1 && _selectedDisplay != null
                                        ? 'Monitor ${_displays.indexOf(_selectedDisplay!) + 1}'
                                        : 'Full Screen',
                                  )
                                else ...[
                                  ConfigSnippet(
                                    icon: switch (state.captureMode) {
                                      CaptureMode.fullScreen =>
                                        Symbols.desktop_windows,
                                      CaptureMode.area => Symbols.crop_free,
                                      CaptureMode.scrolling => Symbols.swipe_down,
                                    },
                                    label: switch (state.captureMode) {
                                      CaptureMode.fullScreen => 'Full Screen',
                                      CaptureMode.area => 'Select Area',
                                      CaptureMode.scrolling => 'Scrolling Area',
                                    },
                                  ),
                                  const SizedBox(height: SqaTokens.spacingSmall),
                                  ConfigSnippet(
                                    icon: state.microphoneEnabled
                                        ? Symbols.mic
                                        : Symbols.mic_off,
                                    label: state.microphoneEnabled
                                        ? (state.selectedAudioDevice ?? 'Mic On')
                                        : 'No Audio',
                                  ),
                                  const SizedBox(height: SqaTokens.spacingSmall),
                                  ConfigSnippet(
                                    icon: Symbols.photo_size_select_large,
                                    label:
                                        '${state.resolution} @ ${state.framerate}fps',
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      SqaHoverIconButton(
                        icon: Symbols.tune,
                        onPressed: () {
                          ref
                              .read(navigationServiceProvider)
                              .jumpToPluginSettings(
                                ScreenRecorderPlugin().id,
                              );
                        },
                        tooltip: 'Recording Settings',
                        iconSize: SqaTokens.spacingLarge + SqaTokens.spacingTiny,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: SqaTokens.spacingXLarge),
                  Row(
                    children: [
                      Expanded(
                        child: SqaButton.primary(
                          onPressed: state.isOverlayVisible
                              ? () => notifier.cancelOverlay()
                              : () => _handleStart(context),
                          icon: state.isRecording
                              ? Symbols.stop
                              : (state.isOverlayVisible
                                  ? Symbols.close
                                  : Symbols.play_arrow),
                          label: ffmpegStatus.isDownloading
                              ? 'Downloading Engine...'
                              : (state.isRecording
                                  ? 'Stop Recording'
                                  : (state.isOverlayVisible
                                      ? 'Cancel Overlay'
                                      : Platform.isLinux
                                          ? 'Start Recording'
                                          : 'Enter Overlay')),
                          color: state.isOverlayVisible || state.isRecording
                              ? theme.colorScheme.error
                              : null,
                        ),
                      ),
                      const SizedBox(width: SqaTokens.spacingMedium),
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

            const SizedBox(height: SqaTokens.spacingXXLarge),

            if (Platform.isLinux && _displays.length > 1) ...[
              // Monitor Selection
              Text(
                'SELECT MONITOR',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SqaTokens.spacingMedium),
              SqaSegmentedButton<int>(
                segments: _displays.map((d) {
                  final index = _displays.indexOf(d);
                  return ButtonSegment<int>(
                    value: index,
                    icon: const Icon(Symbols.monitor, size: SqaTokens.spacingLarge + SqaTokens.spacingTiny),
                    label: Text('Monitor ${index + 1}'),
                    tooltip: '${d.size.width.toInt()}x${d.size.height.toInt()}',
                  );
                }).toList(),
                selected: {_displays.indexOf(_selectedDisplay ?? _displays.first)},
                onSelectionChanged: (Set<int> set) {
                  setState(() {
                    _selectedDisplay = _displays[set.first];
                  });
                },
              ),
              const SizedBox(height: SqaTokens.spacingSmall),
              Text(
                'Select which monitor to record natively.',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: SqaTokens.spacingXXLarge),
            ] else if (!Platform.isLinux) ...[
              // Capture Mode Selection
              Text(
                'CAPTURE MODE',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SqaTokens.spacingMedium),
              SqaSegmentedButton<CaptureMode>(
                segments: [
                  ButtonSegment(
                    value: CaptureMode.fullScreen,
                    icon: const Icon(Symbols.desktop_windows, size: SqaTokens.spacingLarge + SqaTokens.spacingTiny),
                    label: const Text('Full Screen'),
                    tooltip: hotkeys.recFullscreen != null
                        ? 'Full Screen (${hotkeys.recFullscreen})'
                        : 'Full Screen — no hotkey assigned',
                  ),
                  ButtonSegment(
                    value: CaptureMode.area,
                    icon: const Icon(Symbols.crop_free, size: SqaTokens.spacingLarge + SqaTokens.spacingTiny),
                    label: const Text('Select Area'),
                    tooltip: hotkeys.areaRecordToggle != null
                        ? 'Select Area (${hotkeys.areaRecordToggle})'
                        : 'Select Area — no hotkey assigned',
                  ),
                ],
                selected: {state.captureMode == CaptureMode.scrolling ? CaptureMode.area : state.captureMode},
                onSelectionChanged: (Set<CaptureMode> set) =>
                    notifier.setCaptureMode(set.first),
              ),
              const SizedBox(height: SqaTokens.spacingSmall),
              Text(
                switch (state.captureMode) {
                  CaptureMode.fullScreen =>
                    'Captures the entire primary monitor including taskbars.',
                  CaptureMode.area =>
                    'Allows you to draw a custom rectangle on the screen for selective capture.',
                  CaptureMode.scrolling =>
                    'Record a scrollable area to stitch into a single long screenshot.',
                },
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: SqaTokens.spacingXXLarge),
            ],

            SqaHistoryList<RecordingInfo>(
              key: _historyListKey,
              items: state.recentRecordings.where((info) {
                if (state.searchQuery.isEmpty) return true;
                final query = state.searchQuery.toLowerCase();
                final filename = p.basename(info.file.path).toLowerCase();
                return filename.contains(query);
              }).toList(),
              title: 'Recent Recordings',
              emptyLabel: 'No recordings found',
              emptyIcon: Symbols.videocam_off,
              itemBuilder: (context, info, isLast) {
                return RecordingTile(
                  info: info,
                  onDelete: () => notifier.deleteRecording(info),
                  onRename: (newName) =>
                      notifier.renameRecording(info, newName),
                  onValidate: (name) =>
                      notifier.validateNewName(name, info),
                  onOpen: () => PlatformUtils.openPath(info.file.path),
                  onAnnotate: () async {
                    final windows = await WindowController.getAll();
                    WindowController? annotatorWindow;
                    for (final w in windows) {
                      if (w.arguments.contains('"type":"annotator"')) {
                        annotatorWindow = w;
                        break;
                      }
                    }

                    if (annotatorWindow != null) {
                      await annotatorWindow.invokeMethod('setMedia', {
                        'filePath': info.file.path,
                        'format': state.format,
                      });
                      await annotatorWindow.show();
                    } else {
                      annotatorWindow = await WindowController.create(
                        WindowConfiguration(arguments: jsonEncode({
                          'type': 'annotator',
                          'filePath': info.file.path,
                          'format': state.format,
                        })),
                      );
                      await annotatorWindow.show();
                    }
                  },
                  onOpenFolder: () =>
                      notifier.openSaveDirectory(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

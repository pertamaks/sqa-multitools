import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_icon_container.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/providers/plugin_provider.dart';
import '../providers/screenshot_provider.dart';
import '../models/screenshot_state.dart';
import '../screenshot_plugin.dart';
import 'widgets/config_snippet.dart';
import 'widgets/capture_tile.dart';

class ScreenshotView extends ConsumerStatefulWidget {
  const ScreenshotView({super.key});

  @override
  ConsumerState<ScreenshotView> createState() => _ScreenshotViewState();
}

class _ScreenshotViewState extends ConsumerState<ScreenshotView> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(screenshotProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleStart() {
    final notifier = ref.read(screenshotProvider.notifier);
    notifier.capture();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenshotProvider);
    final notifier = ref.read(screenshotProvider.notifier);
    final theme = Theme.of(context);

    return SqaPluginLayout(
      icon: Symbols.crop,
      title: 'Screenshot',
      description: 'Capture a region and draw directly on it.',
      color: theme.colorScheme.primary,
      searchController: _searchController,
      onSearchChanged: (val) =>
          ref.read(screenshotProvider.notifier).setSearchQuery(val),
      searchHint: 'Filter captures...',
      child: SqaFadeWrapper(
        child: SqaPluginScrollableContent(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hub Header
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
                                    : 'READY TO CAPTURE',
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
                                    icon: Symbols.image,
                                    label: 'Format: ${state.format}',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Tooltip(
                          message: 'Screenshot Settings',
                          child: SqaIconContainer(
                            icon: Symbols.tune,
                            color: theme.colorScheme.primary,
                            backgroundColor: Colors.transparent,
                            size: 32,
                            iconSize: 18,
                            onTap: () {
                              ref
                                  .read(navigationServiceProvider)
                                  .jumpToPluginSettings(ScreenshotPlugin().id);
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
                                ? () => notifier.stopCapture()
                                : () => _handleStart(),
                            icon: state.isOverlayVisible
                                ? Symbols.close
                                : Symbols.play_arrow,
                            label: state.isOverlayVisible
                                ? 'Cancel Overlay'
                                : 'Enter Overlay',
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

              // Capture Mode
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

              // Recent Captures List
              if (state.recentCaptures.isNotEmpty) ...[
                Text(
                  'RECENT CAPTURES',
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
                      ...state.recentCaptures
                          .where((info) {
                            if (state.searchQuery.isEmpty) return true;
                            final query = state.searchQuery.toLowerCase();
                            final filename = info.file.path
                                .split('\\')
                                .last
                                .toLowerCase();
                            return filename.contains(query);
                          })
                          .map((CaptureInfo info) {
                            final filteredList = state.recentCaptures.where((
                              info,
                            ) {
                              if (state.searchQuery.isEmpty) return true;
                              final query = state.searchQuery.toLowerCase();
                              final filename = info.file.path
                                  .split('\\')
                                  .last
                                  .toLowerCase();
                              return filename.contains(query);
                            }).toList();
                            final isLast = filteredList.last == info;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CaptureTile(
                                  info: info,
                                  onDelete: () => notifier.deleteCapture(info),
                                  onRename: (newName) =>
                                      notifier.renameCapture(info, newName),
                                  onValidate: (name) =>
                                      notifier.validateNewName(name, info),
                                  onOpen: () => Process.start('explorer.exe', [
                                    info.file.path,
                                  ]),
                                  onOpenFolder: () =>
                                      notifier.openSaveDirectory(),
                                ),
                                if (!isLast)
                                  const Divider(height: 1, indent: 56),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' as p;
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/providers/plugin_provider.dart';
import '../../../core/utils/platform_utils.dart';
import '../providers/screenshot_provider.dart';
import '../models/screenshot_state.dart';
import '../screenshot_plugin.dart';
import '../../screen_recorder/providers/screen_recorder_provider.dart';
import 'widgets/config_snippet.dart';
import 'widgets/capture_tile.dart';
import '../../../ui/widgets/sqa_history_list.dart';

class ScreenshotView extends ConsumerStatefulWidget {
  const ScreenshotView({super.key});

  @override
  ConsumerState<ScreenshotView> createState() => _ScreenshotViewState();
}

class _ScreenshotViewState extends ConsumerState<ScreenshotView> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  final GlobalKey _historyListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(screenshotProvider).searchQuery,
    );
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleStart() {
    final state = ref.read(screenshotProvider);
    if (state.captureMode == CaptureMode.scrolling) {
      ref.read(screenRecorderProvider.notifier).startLongScreenshotSession();
    } else {
      final notifier = ref.read(screenshotProvider.notifier);
      notifier.startMonitorSelection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(screenshotProvider);
    final notifier = ref.read(screenshotProvider.notifier);
    final theme = Theme.of(context);

    // Auto-scroll to newly added captures
    ref.listen(screenshotProvider.select((s) => s.recentCaptures), (previous, next) {
      if (previous != null && next.isNotEmpty) {
        // If a new capture was added (either length increased or newest item changed)
        if (previous.isEmpty || next.first.file.path != previous.first.file.path) {
          // Give the UI a brief moment to layout the new item
          Future.delayed(const Duration(milliseconds: 150), () {
            if (!mounted) return;
            final contextToScroll = _historyListKey.currentContext;
            if (contextToScroll != null) {
              Scrollable.ensureVisible(
                contextToScroll,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                alignment: 0.0, // align top of the widget to top of the viewport
              );
            }
          });
        }
      }
    });

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
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hub Header
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
                                    : 'READY TO CAPTURE',
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
                                  ConfigSnippet(
                                    icon: switch (state.captureMode) {
                                      CaptureMode.fullScreen => Symbols.desktop_windows,
                                      CaptureMode.area => Symbols.crop_free,
                                      CaptureMode.scrolling => Symbols.swipe_down,
                                    },
                                    label: switch (state.captureMode) {
                                      CaptureMode.fullScreen => 'Full Screen',
                                      CaptureMode.area => 'Area Selection',
                                      CaptureMode.scrolling => 'Long SS',
                                    },
                                  ),
                                  const SizedBox(height: SqaTokens.spacingSmall),
                                  ConfigSnippet(
                                    icon: Symbols.image,
                                    label: 'Format: ${state.format}',
                                  ),
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
                                .jumpToPluginSettings(ScreenshotPlugin().id);
                          },
                          tooltip: 'Screenshot Settings',
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

              // Capture Mode
              Text(
                'CAPTURE MODE',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SqaTokens.spacingMedium),
              SqaSegmentedButton<CaptureMode>(
                segments: const [
                  ButtonSegment(
                    value: CaptureMode.fullScreen,
                    icon: Icon(Symbols.fullscreen, size: SqaTokens.spacingLarge + SqaTokens.spacingTiny),
                    label: Text('Full Screen'),
                  ),
                  ButtonSegment(
                    value: CaptureMode.area,
                    icon: Icon(Symbols.crop_free, size: SqaTokens.spacingLarge + SqaTokens.spacingTiny),
                    label: Text('Area'),
                  ),
                  ButtonSegment(
                    value: CaptureMode.scrolling,
                    icon: Icon(Symbols.swipe_down, size: SqaTokens.spacingLarge + SqaTokens.spacingTiny),
                    label: Text('Long SS'),
                  ),
                ],
                selected: {state.captureMode},
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

              SqaHistoryList<CaptureInfo>(
                key: _historyListKey,
                  items: state.recentCaptures.where((info) {
                    if (state.searchQuery.isEmpty) return true;
                    final query = state.searchQuery.toLowerCase();
                    final filename = p.basename(info.file.path).toLowerCase();
                    return filename.contains(query);
                  }).toList(),
                  title: 'Recent Captures',
                  emptyLabel: 'No captures found',
                  emptyIcon: Symbols.image_not_supported,
                  itemBuilder: (context, info, isLast) {
                    return CaptureTile(
                      info: info,
                      onDelete: () => notifier.deleteCapture(info),
                      onRename: (newName) =>
                          notifier.renameCapture(info, newName),
                      onValidate: (name) =>
                          notifier.validateNewName(name, info),
                      onOpen: () => PlatformUtils.openPath(info.file.path),
                      onOpenFolder: () =>
                          notifier.openSaveDirectory(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

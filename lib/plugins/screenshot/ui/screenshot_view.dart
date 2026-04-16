import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_icon_container.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../core/models/capture_mode.dart';
import '../../../core/providers/plugin_provider.dart';
import '../providers/screenshot_provider.dart';
import '../models/screenshot_state.dart';
import '../screenshot_plugin.dart';

class ScreenshotView extends ConsumerStatefulWidget {
  const ScreenshotView({super.key});

  @override
  ConsumerState<ScreenshotView> createState() => _ScreenshotViewState();
}

class _ScreenshotViewState extends ConsumerState<ScreenshotView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(screenshotProvider.notifier).registerGlobalHotkeys();
      }
    });
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
                    ...state.recentCaptures.map((CaptureInfo info) {
                      final isLast = state.recentCaptures.last == info;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RecentCaptureTile(
                            info: info,
                            onDelete: () async {
                              final confirm = await SqaModal.showConfirm(
                                context,
                                title: 'Delete Capture?',
                                message: 'Are you sure you want to permanently delete this file?',
                                confirmLabel: 'Delete',
                                confirmColor: theme.colorScheme.error,
                                icon: Symbols.delete,
                              );
                              if (confirm == true) {
                                notifier.deleteCapture(info);
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

class _RecentCaptureTile extends StatelessWidget {
  final CaptureInfo info;
  final VoidCallback onDelete;
  final VoidCallback onOpen;

  const _RecentCaptureTile({
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
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.file(
          info.file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(
              Symbols.image_not_supported,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
            icon: const Icon(Symbols.open_in_new, size: 18),
            onPressed: onOpen,
            tooltip: 'Open',
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

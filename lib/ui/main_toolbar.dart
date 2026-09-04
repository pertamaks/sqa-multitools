import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/models/sqa_plugin.dart';
import '../core/providers/plugin_provider.dart';
import '../core/services/preferences_service.dart';
import '../core/services/coffee_shop_service.dart';
import 'widgets/sqa_styles.dart';
import 'widgets/sqa_hover_icon_button.dart';
import '../plugins/screenshot/ui/screenshot_overlay.dart';
import '../plugins/screenshot/providers/screenshot_provider.dart';
import '../plugins/screen_recorder/ui/screen_recorder_overlay.dart';
import '../plugins/screen_recorder/providers/screen_recorder_provider.dart';
import 'widgets/sqa_fade_wrapper.dart';
import 'widgets/sqa_bug_squasher.dart';
import 'widgets/sqa_scroll_behavior.dart';
import 'widgets/sqa_inline_tooltip.dart';
import 'widgets/sqa_toast.dart';
import '../plugins/todo/providers/todo_notification_provider.dart';
import '../plugins/todo/providers/todo_provider.dart';
import '../plugins/todo/todo_plugin.dart';
import '../plugins/timer/providers/timer_provider.dart';
import '../core/window/window_utils.dart';
import '../core/window/window_constants.dart';
import '../core/providers/ffmpeg_provider.dart';
import 'widgets/sqa_safe_plugin_builder.dart';
import 'widgets/sqa_coachmark.dart';
import '../core/providers/coachmark_provider.dart';
import '../core/models/sqa_coachmark_step.dart';
import '../plugins/security_payloads/providers/security_payloads_provider.dart';
import 'dart:io';

class MainToolbar extends ConsumerStatefulWidget {
  const MainToolbar({super.key});

  @override
  ConsumerState<MainToolbar> createState() => _MainToolbarState();
}

class _MainToolbarState extends ConsumerState<MainToolbar> with WindowListener {
  late final ScrollController _scrollController;

  // ── Coachmark GlobalKeys ──────────────────────────────────────────────────
  final _pluginBarKey = GlobalKey(debugLabel: 'toolbar.plugin_bar');
  final _settingsIconKey = GlobalKey(debugLabel: 'toolbar.settings');
  final _dragHandleKey = GlobalKey(debugLabel: 'toolbar.drag_handle');
  final _closeButtonKey = GlobalKey(debugLabel: 'toolbar.close');
  SqaCoachmarkController? _toolbarCoachmark;
  SqaCoachmarkController? _pluginCoachmark;

  @override
  void initState() {
    windowManager.addListener(this);
    _scrollController = ScrollController();

    // Auto-open Todo view logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(todoNotificationProvider, (previous, next) async {
        if (next == true) {
          final settings = await ref.read(todoSettingsProvider.future);
          if (settings.autoOpenOnReminder) {
            final current = ref.read(activePluginProvider);
            if (current?.id != 'com.sqa.plugin.todo') {
              ref.read(navigationServiceProvider).jumpToTodo(current?.id ?? '');
            }
          }
        }
      });

      // First-launch toolbar coachmark
      _maybeShowToolbarCoachmark();
    });

    super.initState();
  }

  // ── Coachmark Helpers ─────────────────────────────────────────────────────

  void _maybeShowToolbarCoachmark() {
    final service = ref.read(coachmarkServiceProvider.notifier);
    if (!service.shouldShowToolbarTour()) return;

    // Expand the window by opening Settings so the coachmark has room to draw.
    final settingsPlugin = ref.read(settingsPluginProvider);
    ref.read(navigationServiceProvider).togglePlugin(settingsPlugin, forceOpen: true);

    // Wait for the window animation to complete before showing the overlay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _toolbarCoachmark = SqaCoachmarkController(
        steps: _buildToolbarSteps(),
        onFinish: () {
          ref.read(coachmarkServiceProvider.notifier).markToolbarTourSeen();
        },
        onSkip: () {
          ref.read(coachmarkServiceProvider.notifier).markToolbarTourSeen();
        },
      );
      _toolbarCoachmark!.show(context);
    });
  }

  List<SqaCoachmarkStep> _buildToolbarSteps() {
    return [
      SqaCoachmarkStep(
        targetKey: _pluginBarKey,
        title: 'Welcome to SQA-Multitools',
        description:
            'This bar is your command center. Every icon here is a QA tool — click any one to open it instantly.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: _pluginBarKey,
        title: 'More Tools Are Hidden Here',
        description:
            'Scroll or drag this bar left and right to reveal all your enabled tools. You can also reorder them in Settings → Plugins.',
        contentAlign: CoachmarkContentAlign.bottom,
        beforeStepAction: (ref) async {
          if (_scrollController.hasClients) {
            await _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          }
        },
      ),
      SqaCoachmarkStep(
        targetKey: _settingsIconKey,
        title: 'Settings & Customization',
        description:
            'Open Settings to change the theme, manage which plugins appear in this bar, or unlock supporter features.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: _dragHandleKey,
        title: 'Drag Me Anywhere',
        description:
            'Grab this handle to reposition the toolbar wherever it works best for your workflow. It floats above all other windows.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: _closeButtonKey,
        title: 'Close to Tray',
        description:
            'This hides the toolbar to the system tray without exiting. SQA-Multitools keeps running silently in the background.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
    ];
  }

  void _maybeShowPluginCoachmark(SqaPlugin plugin) {
    final steps = plugin.coachmarkSteps;
    if (steps.isEmpty) return;

    final service = ref.read(coachmarkServiceProvider.notifier);

    // Check if it's a first-time access or a manual trigger from (?)
    final state = ref.read(coachmarkServiceProvider);
    final isManual = state.manualTriggerPluginId == plugin.id;
    final isFirstAccess = service.shouldShowPluginTour(plugin.id);

    if (!isFirstAccess && !isManual) return;

    if (isManual) {
      ref.read(coachmarkServiceProvider.notifier).clearManualTrigger();
    }

    // For Security Payloads: capture whether the disclaimer was showing BEFORE
    // the coachmark hides it. If it was (user hadn't clicked 'I UNDERSTAND'),
    // restore it after the tour completes so they still see the consent prompt.
    final securityDisclaimerWasShowing =
        plugin.id == 'com.sqa.plugin.security_payloads' &&
        ref.read(securityPayloadsProvider).showDisclaimer;

    void restoreDisclaimerIfNeeded() {
      if (securityDisclaimerWasShowing) {
        ref.read(securityPayloadsProvider.notifier).restoreDisclaimer();
      }
    }

    _pluginCoachmark?.dismiss();
    _pluginCoachmark = SqaCoachmarkController(
      steps: steps,
      onFinish: () {
        service.markPluginTourSeen(plugin.id);
        restoreDisclaimerIfNeeded();
      },
      onSkip: () {
        service.markPluginTourSeen(plugin.id);
        restoreDisclaimerIfNeeded();
      },
    );

    // Wait a brief moment for the window to expand before showing the coachmark
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _pluginCoachmark!.show(context);
      }
    });
  }

  @override
  void onWindowFocus() {
    WindowUtils.safeShow();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      WindowUtils.safeHide();
    }
  }

  void _togglePlugin(SqaPlugin plugin) async {
    await ref.read(navigationServiceProvider).togglePlugin(plugin);
  }

  Widget _buildToolbarBar(
    ColorScheme colorScheme,
    List<SqaPlugin> enabledPlugins,
    SqaPlugin? activePlugin,
    SqaPlugin settingsPlugin,
    int supporterTier,
    bool hasTodoReminder,
    bool isTimerRunning,
    bool isLinuxRecording,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onPanStart: (_) => windowManager.startDragging(),
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: WindowConstants.kToolbarWindowHeight,
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              height: WindowConstants.kToolbarWindowHeight,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(SqaStyles.radiusWindow),
                  topRight: const Radius.circular(SqaStyles.radiusWindow),
                  bottomLeft: Radius.circular(
                    activePlugin != null ? 0 : SqaStyles.radiusWindow,
                  ),
                  bottomRight: Radius.circular(
                    activePlugin != null ? 0 : SqaStyles.radiusWindow,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SqaInlineTooltip(
                        scrollController: _scrollController,
                        backgroundColor: colorScheme.surfaceContainerLow,
                        child: SqaFadeWrapper(
                          axis: Axis.horizontal,
                          child: ClipRect(
                            child: ScrollConfiguration(
                              behavior: const SqaMouseDragScrollBehavior(),
                              child: SingleChildScrollView(
                                key: _pluginBarKey,
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: enabledPlugins.asMap().entries.map((
                                    entry,
                                  ) {
                                    final plugin = entry.value;
                                    final isActive =
                                        activePlugin?.id == plugin.id;
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 10.0,
                                      ),
                                      child: ToolIcon(
                                        key: plugin.id == 'com.sqa.plugin.todo' ? TodoPlugin.todoIconKey : null,
                                        icon: plugin.icon,
                                        tooltip: _formatTooltip(
                                          plugin,
                                          plugin.name,
                                        ),
                                        isActive: isActive,
                                        badge: _buildBadgeIcon(
                                          plugin,
                                          hasTodoReminder,
                                          isTimerRunning,
                                        ),
                                        badgeColor: _getBadgeColor(
                                          plugin,
                                          hasTodoReminder,
                                          isTimerRunning,
                                          colorScheme,
                                        ),
                                        onPressed: () => _togglePlugin(plugin),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Drag Handle & Global Download Indicator
                    SizedBox(
                      key: _dragHandleKey,
                      width: 36,
                      height: 48,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Symbols.drag_indicator,
                              size: 20,
                              color: colorScheme.outlineVariant,
                            ),
                            if (ref.watch(ffmpegProvider).isDownloading)
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    if (isLinuxRecording) ...[
                      const SizedBox(width: 4),
                      SqaInlineTooltipTrigger(
                        tooltip: 'Stop Recording',
                        child: SqaHoverIconButton(
                          icon: Symbols.stop_circle,
                          color: colorScheme.error,
                          backgroundColor: colorScheme.errorContainer,
                          onPressed: () async {
                            await ref
                                .read(screenRecorderProvider.notifier)
                                .stopWaylandPortal();
                            final allPlugins = ref.read(
                              availablePluginsProvider,
                            );
                            final screenRecorderPlugin = allPlugins.firstWhere(
                              (p) => p.id == 'com.sqa.screen_recorder',
                            );
                            ref
                                .read(navigationServiceProvider)
                                .togglePlugin(
                                  screenRecorderPlugin,
                                  forceOpen: true,
                                );
                          },
                          tooltip: null,
                          iconSize: 24,
                          padding: 6.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],

                    ToolIcon(
                      key: _settingsIconKey,
                      icon: settingsPlugin.icon,
                      tooltip: settingsPlugin.name,
                      isActive: activePlugin?.id == settingsPlugin.id,
                      badge: supporterTier >= 1
                          ? const Icon(
                              Symbols.coffee,
                              size: 10,
                              color: Colors.white,
                              weight: 700,
                            )
                          : null,
                      onPressed: () => _handleSettingsPress(settingsPlugin),
                    ),
                    const SizedBox(width: 4),

                    if (!Platform.isLinux) ...[
                      // Close to Tray
                      SqaInlineTooltipTrigger(
                        tooltip: 'Close to Tray',
                        child: SqaHoverIconButton(
                          key: _closeButtonKey,
                          icon: Symbols.close,
                          onPressed: () => WindowUtils.safeHide(),
                          tooltip: null,
                          iconSize: 24,
                          padding: 6.0,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget? _buildBadgeIcon(
    SqaPlugin plugin,
    bool hasTodoReminder,
    bool isTimerRunning,
  ) {
    if (plugin.id == 'com.sqa.plugin.todo' && hasTodoReminder) {
      return const SizedBox.shrink();
    }
    if (plugin.id == 'com.sqa.timer' && isTimerRunning) {
      return const SizedBox.shrink();
    }

    if (plugin.badge == 'BETA') {
      return const Icon(
        Symbols.labs,
        size: 10,
        color: Colors.white,
        weight: 700,
      );
    }
    if (plugin.badge == 'ALPHA') {
      return const Icon(
        Symbols.construction,
        size: 10,
        color: Colors.white,
        weight: 700,
      );
    }
    if (plugin.badge != null) {
      return Text(
        plugin.badge!,
        style: const TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      );
    }
    return null;
  }

  Color? _getBadgeColor(
    SqaPlugin plugin,
    bool hasTodoReminder,
    bool isTimerRunning,
    ColorScheme colorScheme,
  ) {
    if (plugin.id == 'com.sqa.plugin.todo' && hasTodoReminder) {
      return colorScheme.primary;
    }
    if (plugin.id == 'com.sqa.timer' && isTimerRunning) {
      return colorScheme.primary;
    }

    if (plugin.badge == 'BETA') return Colors.blue;
    if (plugin.badge == 'ALPHA') return Colors.amber;
    return null;
  }

  String _formatTooltip(SqaPlugin plugin, String text) {
    if (plugin.badge == 'BETA') return '${plugin.name} (Beta)';
    if (plugin.badge == 'ALPHA') return '${plugin.name} (Alpha)';
    return text;
  }

  void _handleSettingsPress(SqaPlugin settingsPlugin) {
    _togglePlugin(settingsPlugin);
  }

  @override
  Widget build(BuildContext context) {
    final activePlugin = ref.watch(activePluginProvider);
    final enabledPlugins = ref.watch(enabledPluginsProvider);
    final settingsPlugin = ref.watch(settingsPluginProvider);
    final supporterTier = ref.watch(supporterTierProvider);
    final hasTodoReminder = ref.watch(todoNotificationProvider);
    final timerState = ref.watch(timerProvider.select((s) => s.isRunning));
    final isTimerRunning = timerState;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen(ffmpegProvider, (previous, next) {
      if (previous != null && previous.isDownloading && !next.isDownloading) {
        if (next.isReady) {
          SqaToast.show(
            context,
            'Engine installed successfully',
            type: SqaToastType.success,
          );
        } else if (next.error != null) {
          SqaToast.show(
            context,
            'Engine download failed: ${next.error}',
            type: SqaToastType.error,
          );
        }
      }
    });

    final isScreenshotVisible = ref.watch(screenshotProvider).isOverlayVisible;
    final recorderState = ref.watch(screenRecorderProvider);
    final isRecorderVisible = recorderState.isOverlayVisible;
    final isStitching = recorderState.isStitching;
    final isOverlayActive = isScreenshotVisible || isRecorderVisible;
    final hasPlugin = activePlugin != null;

    // Listen for manual coachmark triggers
    ref.listen(coachmarkServiceProvider, (previous, next) {
      final triggerId = next.manualTriggerPluginId;
      if (triggerId != null && triggerId != previous?.manualTriggerPluginId) {
        if (activePlugin?.id == triggerId) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _maybeShowPluginCoachmark(activePlugin!);
          });
        }
      }
    });

    // Auto-scroll to active plugin when it changes (Smart Nudge)
    ref.listen(activePluginProvider, (previous, next) {
      if (next != null && _scrollController.hasClients) {
        final index = enabledPlugins.indexWhere((p) => p.id == next.id);
        if (index != -1) {
          final viewportWidth = _scrollController.position.viewportDimension;
          final currentOffset = _scrollController.offset;
          final targetX = index * 46.0; // item width (36) + padding (10)
          final iconWidth = 36.0;
          final maxScroll = _scrollController.position.maxScrollExtent;
          const edgeMargin = 46.0; // Maintain one item width of padding

          double? newOffset;

          if (targetX < currentOffset + edgeMargin) {
            // Nudge from left edge
            newOffset = targetX - edgeMargin;
          } else if (targetX + iconWidth >
              currentOffset + viewportWidth - edgeMargin) {
            // Nudge from right edge
            newOffset = targetX + iconWidth + edgeMargin - viewportWidth;
          }

          if (newOffset != null) {
            _scrollController.animateTo(
              newOffset.clamp(0.0, maxScroll),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        }
      }

      // Plugin first-access coachmark — trigger after plugin panel renders
      if (next != null && previous?.id != next.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeShowPluginCoachmark(next);
        });
      }
    });

    final isLinuxRecording = Platform.isLinux && recorderState.isRecording;

    return ExcludeSemantics(
      child: Scaffold(
        backgroundColor: isOverlayActive
            ? Colors.transparent
            : colorScheme.surfaceContainerLow,
        body: LayoutBuilder(
          builder: (context, constraints) {
            // Clamp the toolbar's allocated height so the Column never exceeds
            // its parent constraint during transient window-resize frames.
            final toolbarSlot = constraints.maxHeight.clamp(
              0.0,
              WindowConstants.kToolbarWindowHeight,
            );

            return Stack(
              children: [
                const SizedBox.expand(),
                ExcludeSemantics(
                  child: Column(
                    children: [
                      if (!isOverlayActive)
                        SizedBox(
                          height: toolbarSlot,
                          child: OverflowBox(
                            maxHeight: WindowConstants.kToolbarWindowHeight,
                            alignment: Alignment.topLeft,
                            child: _buildToolbarBar(
                              colorScheme,
                              enabledPlugins,
                              activePlugin,
                              settingsPlugin,
                              supporterTier,
                              hasTodoReminder,
                              isTimerRunning,
                              isLinuxRecording,
                            ),
                          ),
                        ),
                      if (hasPlugin && !isOverlayActive)
                        Expanded(
                          child: KeyedSubtree(
                            key: ValueKey('plugin_${activePlugin.id}'),
                            child: SqaSafePluginBuilder(
                              pluginId: activePlugin.id,
                              pluginName: activePlugin.name,
                              builder: (context) =>
                                  activePlugin.buildPluginWindow(context),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isOverlayActive &&
                    supporterTier >= 3 &&
                    ref.watch(bugSquashEnabledProvider))
                  ExcludeSemantics(
                    child: SquashTheBugOverlay(key: SquashTheBugOverlay.bugKey),
                  ),
                if (isScreenshotVisible)
                  const Positioned.fill(
                    child: ExcludeSemantics(child: ScreenshotOverlay()),
                  ),
                if (isRecorderVisible)
                  const Positioned.fill(
                    child: ExcludeSemantics(child: ScreenRecorderOverlay()),
                  ),
                if (isStitching)
                  Positioned.fill(
                    child: Container(
                      color: colorScheme.surfaceContainerLow.withValues(
                        alpha: 0.8,
                      ),
                      child: Center(
                        child: hasPlugin
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Stitching Long Screenshot...',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Stitching Long Screenshot...',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ToolIcon extends ConsumerWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final Widget? badge;
  final Color? badgeColor;
  final VoidCallback onPressed;

  const ToolIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    this.isActive = false,
    this.badge,
    this.badgeColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color activeColor = colorScheme.onPrimaryContainer;
    final Color activeBg = colorScheme.primaryContainer;

    Widget iconWidget = Icon(
      icon,
      size: 24,
      color: isActive ? activeColor : colorScheme.onSurface,
    );

    if (badge != null) {
      final isDot = badge is SizedBox;
      iconWidget = Badge(
        label: isDot ? null : badge!,
        smallSize: 8,
        largeSize: isDot ? 8 : 16,
        padding: isDot
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        offset: const Offset(4, -4),
        backgroundColor: badgeColor ?? colorScheme.primary,
        child: iconWidget,
      );
    }

    return SqaInlineTooltipTrigger(
      tooltip: tooltip,
      child: SqaHoverIconButton(
        isSelected: isActive,
        iconWidget: iconWidget,
        onPressed: onPressed,
        tooltip: null,
        backgroundColor: isActive ? activeBg : Colors.transparent,
        color: isActive ? activeColor : colorScheme.onSurface,
        borderRadius: SqaStyles.radiusLarge,
        padding: 6.0,
      ),
    );
  }
}

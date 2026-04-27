import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../core/models/sqa_plugin.dart';
import '../core/providers/plugin_provider.dart';
import '../core/services/preferences_service.dart';
import '../core/services/coffee_shop_service.dart';
import 'widgets/sqa_styles.dart';
import '../plugins/screenshot/ui/screenshot_overlay.dart';
import '../plugins/screenshot/providers/screenshot_provider.dart';
import '../plugins/screen_recorder/ui/screen_recorder_overlay.dart';
import '../plugins/screen_recorder/providers/screen_recorder_provider.dart';
import 'widgets/sqa_fade_wrapper.dart';
import 'widgets/sqa_bug_squasher.dart';
import 'widgets/sqa_scroll_behavior.dart';
import 'widgets/sqa_inline_tooltip.dart';
import '../plugins/todo/providers/todo_notification_provider.dart';
import '../plugins/todo/providers/todo_provider.dart';
import '../plugins/todo/models/todo_settings.dart';

import '../core/window/window_constants.dart';
import '../core/providers/window_provider.dart';

class MainToolbar extends ConsumerStatefulWidget {
  const MainToolbar({super.key});

  @override
  ConsumerState<MainToolbar> createState() => _MainToolbarState();
}

class _MainToolbarState extends ConsumerState<MainToolbar> with WindowListener {
  late final ScrollController _scrollController;

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
    });
    
    super.initState();
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
      windowManager.hide();
    }
  }

  void _togglePlugin(SqaPlugin plugin) async {
    final current = ref.read(activePluginProvider);

    // If we're leaving the settings plugin, revert any theme previews
    if (current?.id == 'com.sqa.settings' && plugin.id != 'com.sqa.settings') {
      ref.read(themeSettingsProvider.notifier).resetToSaved();
    }

    if (current?.id == plugin.id) {
      ref.read(activePluginProvider.notifier).setPlugin(null);
      // Clear history when closing
      ref.read(navigationHistoryProvider.notifier).setHistory(null);
      if (plugin.id == 'com.sqa.settings') {
        ref.read(themeSettingsProvider.notifier).resetToSaved();
      }
      ref.read(windowSizeModeProvider.notifier).reset();
      await windowManager.setMinimumSize(
        const Size(
          WindowConstants.kDefaultWindowWidth,
          WindowConstants.kToolbarWindowHeight,
        ),
      );
      await windowManager.setSize(
        const Size(
          WindowConstants.kDefaultWindowWidth,
          WindowConstants.kToolbarWindowHeight,
        ),
      );
    } else {
      // HANDLE NAVIGATION HISTORY
      if (plugin.id == 'com.sqa.settings') {
        // Entering Settings: record where we came from if it's a real plugin
        if (current != null && current.id != 'com.sqa.settings') {
          ref.read(navigationHistoryProvider.notifier).setHistory(current.id);
        }
        // Default to 'General' tab (0) when accessed from the toolbar
        ref.read(settingsTabProvider.notifier).setTab(0);
      } else {
        // Entering any other plugin: clear the back-navigation history
        ref.read(navigationHistoryProvider.notifier).setHistory(null);
      }

      ref.read(windowSizeModeProvider.notifier).reset();
      ref.read(activePluginProvider.notifier).setPlugin(plugin);
      await windowManager.setMinimumSize(
        const Size(
          WindowConstants.kDefaultWindowWidth,
          WindowConstants.kExpandedWindowHeight,
        ),
      );
      await windowManager.setSize(
        const Size(
          WindowConstants.kDefaultWindowWidth,
          WindowConstants.kExpandedWindowHeight,
        ),
      );
    }
  }

  Widget _buildToolbarBar(
    ColorScheme colorScheme,
    List<SqaPlugin> enabledPlugins,
    SqaPlugin? activePlugin,
    SqaPlugin settingsPlugin,
    int supporterTier,
    bool hasTodoReminder,
  ) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: WindowConstants.kToolbarWindowHeight,
        color: Colors.transparent,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              height: WindowConstants.kToolbarWindowHeight,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  topRight: const Radius.circular(10),
                  bottomLeft: Radius.circular(activePlugin != null ? 0 : 10),
                  bottomRight: Radius.circular(activePlugin != null ? 0 : 10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Transform.translate(
                  offset: const Offset(0, -4.0),
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
                                  key: const PageStorageKey(
                                    'main_toolbar_scroll',
                                  ),
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip.none,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: enabledPlugins
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final plugin = entry.value;
                                          final isActive =
                                              activePlugin?.id == plugin.id;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10.0,
                                            ),
                                            child: ToolIcon(
                                              icon: plugin.icon,
                                              tooltip: _formatTooltip(
                                                plugin,
                                                plugin.name,
                                              ),
                                              isActive: isActive,
                                              badge: _buildBadgeIcon(plugin, hasTodoReminder),
                                              badgeColor: _getBadgeColor(
                                                plugin,
                                                hasTodoReminder,
                                              ),
                                              onPressed: () =>
                                                  _togglePlugin(plugin),
                                            ),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Drag Handle
                      Icon(
                        Symbols.drag_indicator,
                        size: 20,
                        color: colorScheme.outlineVariant,
                      ),
                      const SizedBox(width: 4),

                      ToolIcon(
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

                      // Close to Tray
                      SqaInlineTooltipTrigger(
                        tooltip: 'Close to Tray',
                        child: IconButton(
                          icon: const Icon(Symbols.close, size: 24),
                          onPressed: () => windowManager.hide(),
                          style: IconButton.styleFrom(
                            minimumSize: const Size(36, 36),
                            padding: const EdgeInsets.all(6.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods ---

  Widget? _buildBadgeIcon(SqaPlugin plugin, bool hasTodoReminder) {
    if (plugin.id == 'com.sqa.plugin.todo' && hasTodoReminder) {
      return const Icon(
        Symbols.notifications_active,
        size: 10,
        color: Colors.white,
        weight: 700,
      );
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

  Color? _getBadgeColor(SqaPlugin plugin, bool hasTodoReminder) {
    if (plugin.id == 'com.sqa.plugin.todo' && hasTodoReminder) return Colors.red;
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
    final colorScheme = Theme.of(context).colorScheme;
    final isScreenshotVisible = ref.watch(screenshotProvider).isOverlayVisible;
    final isRecorderVisible = ref
        .watch(screenRecorderProvider)
        .isOverlayVisible;
    final isOverlayActive = isScreenshotVisible || isRecorderVisible;
    final hasPlugin = activePlugin != null;

    return Scaffold(
      backgroundColor: isOverlayActive
          ? Colors.transparent
          : colorScheme.surfaceContainerLow,
      body: Stack(
        children: [
          if (hasPlugin && !isOverlayActive)
            Positioned.fill(
              top: WindowConstants.kToolbarWindowHeight,
              child: activePlugin.buildPluginWindow(context),
            ),
          if (!isOverlayActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: WindowConstants.kToolbarWindowHeight,
              child: _buildToolbarBar(
                colorScheme,
                enabledPlugins,
                activePlugin,
                settingsPlugin,
                supporterTier,
                hasTodoReminder,
              ),
            ),
          if (!isOverlayActive &&
              supporterTier >= 3 &&
              ref.watch(bugSquashEnabledProvider))
            SquashTheBugOverlay(key: SquashTheBugOverlay.bugKey),
          if (isScreenshotVisible)
            const Positioned.fill(child: ScreenshotOverlay()),
          if (isRecorderVisible)
            const Positioned.fill(child: ScreenRecorderOverlay()),
        ],
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
      iconWidget = Badge(
        label: badge!,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        offset: const Offset(4, -4),
        backgroundColor: badgeColor ?? colorScheme.primary,
        child: iconWidget,
      );
    }

    return SqaInlineTooltipTrigger(
      tooltip: tooltip,
      child: IconButton(
        isSelected: isActive,
        icon: iconWidget,
        selectedIcon: iconWidget,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          foregroundColor: isActive ? activeColor : colorScheme.onSurface,
          backgroundColor: isActive ? activeBg : Colors.transparent,
          minimumSize: const Size(36, 36),
          padding: const EdgeInsets.all(6.0),
          shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
        ).copyWith(overlayColor: SqaStyles.buttonOverlay(context)),
      ),
    );
  }
}

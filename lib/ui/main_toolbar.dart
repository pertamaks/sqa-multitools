import 'dart:ui';
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

/// The collapsed toolbar height (no plugin open).
const double kToolbarWindowHeight = 56; // 56px target + 9px Windows offset

/// The default window width.
const double kDefaultWindowWidth = 450;

/// The expanded window height (plugin panel open).
const double kExpandedWindowHeight = 500;

class MainToolbar extends ConsumerStatefulWidget {
  const MainToolbar({super.key});

  @override
  ConsumerState<MainToolbar> createState() => _MainToolbarState();
}

class _MainToolbarState extends ConsumerState<MainToolbar> with WindowListener {
  String? _hoveredTooltip;
  bool _tooltipAlignLeft = false;
  late final ScrollController _scrollController;

  @override
  void initState() {
    windowManager.addListener(this);
    _scrollController = ScrollController();
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
      // If we're closing the settings plugin specifically, revert any theme previews
      if (plugin.id == 'com.sqa.settings') {
        ref.read(themeSettingsProvider.notifier).resetToSaved();
      }
      await windowManager.setMinimumSize(
        const Size(kDefaultWindowWidth, kToolbarWindowHeight),
      );
      await windowManager.setSize(
        const Size(kDefaultWindowWidth, kToolbarWindowHeight),
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

      ref.read(activePluginProvider.notifier).setPlugin(plugin);
      await windowManager.setMinimumSize(
        const Size(kDefaultWindowWidth, kExpandedWindowHeight),
      );
      await windowManager.setSize(
        const Size(kDefaultWindowWidth, kExpandedWindowHeight),
      );
    }
  }

  Widget _buildToolbarBar(
    ColorScheme colorScheme,
    List<SqaPlugin> enabledPlugins,
    SqaPlugin? activePlugin,
    SqaPlugin settingsPlugin,
    int supporterTier,
  ) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: kToolbarWindowHeight,
        color: Colors.transparent,
        alignment: Alignment.topCenter,
        // padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(
          height: kToolbarWindowHeight,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
              bottomLeft: Radius.circular(activePlugin != null ? 0 : 10),
              bottomRight: Radius.circular(activePlugin != null ? 0 : 10),
            ),
            // border: Border.all(
            //   color: colorScheme.primary.withValues(alpha: 0.2),
            //   width: 1.0,
            // ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Transform.translate(
              offset: const Offset(0, -4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        // Scrollable Plugin Icons
                        Positioned.fill(
                          child: SqaFadeWrapper(
                            axis: Axis.horizontal,
                            child: ClipRect(
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(
                                      dragDevices: {
                                        PointerDeviceKind.touch,
                                        PointerDeviceKind.mouse,
                                        PointerDeviceKind.trackpad,
                                      },
                                    ),
                                child: SingleChildScrollView(
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
                                          final index = entry.key;
                                          final plugin = entry.value;
                                          final isActive =
                                              activePlugin?.id == plugin.id;
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              right: 10.0,
                                            ),
                                            child: ToolIcon(
                                              icon: plugin.icon,
                                              tooltip: plugin.name,
                                              isActive: isActive,
                                              badge: _buildBadgeIcon(plugin),
                                              badgeColor: _getBadgeColor(
                                                plugin,
                                              ),
                                              onPressed: () =>
                                                  _togglePlugin(plugin),
                                              onHover: (text) {
                                                setState(() {
                                                  if (text == null) {
                                                    _hoveredTooltip = null;
                                                  } else {
                                                    _hoveredTooltip =
                                                        _formatTooltip(
                                                          plugin,
                                                          text,
                                                        );
                                                  }
                                                  _tooltipAlignLeft =
                                                      index >=
                                                      enabledPlugins.length / 2;
                                                });
                                              },
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

                        // Inline Tooltip Overlay
                        if (_hoveredTooltip != null)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Container(
                                alignment: _tooltipAlignLeft
                                    ? Alignment.centerLeft
                                    : Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      colorScheme.surfaceContainerLow
                                          .withValues(
                                            alpha: _tooltipAlignLeft ? 1 : 0,
                                          ),
                                      colorScheme.surfaceContainerLow,
                                      colorScheme.surfaceContainerLow
                                          .withValues(
                                            alpha: _tooltipAlignLeft ? 0 : 1,
                                          ),
                                    ],
                                    stops: const [0, 0.5, 1],
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    _hoveredTooltip!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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
                    onHover: (text) {
                      setState(() {
                        _hoveredTooltip = text;
                        _tooltipAlignLeft = true;
                      });
                    },
                  ),
                  const SizedBox(width: 4),

                  // Close to Tray
                  MouseRegion(
                    onEnter: (_) => setState(() {
                      _hoveredTooltip = 'Close to Tray';
                      _tooltipAlignLeft = true;
                    }),
                    onExit: (_) => setState(() => _hoveredTooltip = null),
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
    );
  }

  // --- Helper Methods ---

  Widget? _buildBadgeIcon(SqaPlugin plugin) {
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

  Color? _getBadgeColor(SqaPlugin plugin) {
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
    final colorScheme = Theme.of(context).colorScheme;
    final isScreenshotVisible = ref.watch(screenshotProvider).isOverlayVisible;
    final isRecorderVisible = ref
        .watch(screenRecorderProvider)
        .isOverlayVisible;
    final isOverlayActive = isScreenshotVisible || isRecorderVisible;
    final hasPlugin = activePlugin != null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (hasPlugin && !isOverlayActive)
            Padding(
              padding: const EdgeInsets.only(top: kToolbarWindowHeight),
              child: Container(
                color: colorScheme.surface,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: activePlugin.buildPluginWindow(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!isOverlayActive)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: kToolbarWindowHeight,
              child: _buildToolbarBar(
                colorScheme,
                enabledPlugins,
                activePlugin,
                settingsPlugin,
                supporterTier,
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
  final ValueChanged<String?>? onHover;

  const ToolIcon({
    super.key,
    required this.icon,
    required this.tooltip,
    this.isActive = false,
    this.badge,
    this.badgeColor,
    required this.onPressed,
    this.onHover,
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

    return MouseRegion(
      onEnter: (_) => onHover?.call(tooltip),
      onExit: (_) => onHover?.call(null),
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

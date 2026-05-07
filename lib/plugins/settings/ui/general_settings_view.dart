import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/services/coffee_shop_service.dart';
import '../../../core/providers/hotkey_provider.dart';
import '../../../core/providers/version_provider.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_icon_container.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_hotkey_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_update_modal.dart';

class GeneralSettingsView extends ConsumerWidget {
  const GeneralSettingsView({super.key});

  static const List<Map<String, dynamic>> curatedColors = [
    {'name': 'Teal', 'color': Color(0xFF009688)},
    {'name': 'Persimmon', 'color': Color(0xFFFF6B35)}, // 2026 Trend
    {'name': 'Plum Noir', 'color': Color(0xFF543138)}, // 2026 Trend
    {'name': 'Wasabi', 'color': Color(0xFF96B85D)}, // 2026 Trend
    {'name': 'Jade', 'color': Color(0xFF00A86B)}, // 2026 Trend
    {'name': 'Coffee', 'color': Color(0xFF795548)},
    {'name': 'Ruby', 'color': Color(0xFFE91E63)},
    {'name': 'Amethyst', 'color': Color(0xFF673AB7)},
    {'name': 'Emerald', 'color': Color(0xFF4CAF50)},
    {'name': 'Sapphire', 'color': Color(0xFF2196F3)},
  ];

  Widget _buildTierBadge(
    int requiredTier,
    int currentTier,
    ColorScheme colorScheme,
  ) {
    if (currentTier >= requiredTier) return const SizedBox.shrink();

    String label = '';
    IconData icon = Symbols.lock;

    switch (requiredTier) {
      case 1:
        label = 'Comes with espresso';
        break;
      case 2:
        label = 'Comes with latte';
        break;
      case 3:
        label = 'Comes with mocha';
        break;
    }

    return Tooltip(
      message: label,
      child: Icon(icon, size: 16, color: colorScheme.outlineVariant),
    );
  }

  Widget _buildTasterBanner(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
    bool show,
  ) {
    if (!show) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Symbols.info, size: 16, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This is a taster service. If you enjoy this blend, you can order it at the shop!',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SqaButton.tonal(
              onPressed: () {
                DefaultTabController.of(context).animateTo(2);
              },
              icon: Symbols.coffee_maker,
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'PREVIEW',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);
    final supporterTier = ref.watch(supporterTierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SqaPluginScrollableContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appearance Section
          SqaCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.palette, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Theme Mode',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SqaSegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      label: Text('System'),
                      icon: Icon(Symbols.brightness_auto),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('Light'),
                      icon: Icon(Symbols.light_mode),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text('Dark'),
                      icon: Icon(Symbols.dark_mode),
                    ),
                  ],
                  selected: {themeSettings.modeIndex},
                  onSelectionChanged: (set) {
                    ref
                        .read(themeSettingsProvider.notifier)
                        .setModeIndex(set.first);
                  },
                ),
                const SizedBox(height: 24),
                // Premium Effects Group
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Symbols.coffee, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Coffee Shop Amenities',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Accent Color Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Accent Color',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildTierBadge(1, supporterTier, colorScheme),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: curatedColors.map((colorMap) {
                        final name = colorMap['name'] as String;
                        final color = colorMap['color'] as Color;
                        final isSelected =
                            themeSettings.seedColorValue == color.toARGB32();
                        final isLocked = name != 'Teal' && supporterTier < 1;

                        return GestureDetector(
                          onTap: () {
                            if (isLocked) {
                              ref
                                  .read(themeSettingsProvider.notifier)
                                  .previewSeedColor(color.toARGB32());
                            } else {
                              ref
                                  .read(themeSettingsProvider.notifier)
                                  .setSeedColor(color.toARGB32());
                            }
                          },
                          child: Tooltip(
                            message: isLocked ? '$name (Preview)' : name,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  if (isSelected)
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: isLocked
                                  ? const Icon(
                                      Symbols.lock,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : (isSelected
                                        ? const Icon(
                                            Symbols.check,
                                            color: Colors.white,
                                            size: 18,
                                          )
                                        : null),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Dynamic Color Sync
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: supporterTier < 2 ? () {
                        final isCurrentlyPreviewing = themeSettings.useDynamicColor;
                        ref.read(themeSettingsProvider.notifier).previewDynamicColor(!isCurrentlyPreviewing);
                      } : null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Sync with Windows Accent',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (supporterTier < 2 && themeSettings.useDynamicColor) ...[
                                      const SizedBox(width: 8),
                                      _buildPreviewBadge(colorScheme),
                                    ],
                                  ],
                                ),
                                const Text(
                                  'Use your system colors as the app theme.',
                                  style: TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          _buildTierBadge(2, supporterTier, colorScheme),
                          if (supporterTier >= 2)
                            SqaSwitch(
                              value: themeSettings.useDynamicColor,
                              onChanged: (v) {
                                ref
                                    .read(themeSettingsProvider.notifier)
                                    .setUseDynamicColor(v);
                              },
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Transparency Mode
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: supporterTier < 3 ? () {
                            final isCurrentlyPreviewing = themeSettings.isTransparencyModeEnabled;
                            ref.read(themeSettingsProvider.notifier).previewTransparency(!isCurrentlyPreviewing);
                          } : null,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Transparency Mode',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        if (supporterTier < 3 && themeSettings.isTransparencyModeEnabled) ...[
                                          const SizedBox(width: 8),
                                          _buildPreviewBadge(colorScheme),
                                        ],
                                      ],
                                    ),
                                    const Text(
                                      'Enable premium transparency effects for a cleaner look.',
                                      style: TextStyle(fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              _buildTierBadge(3, supporterTier, colorScheme),
                              if (supporterTier >= 3)
                                SqaSwitch(
                                  value: themeSettings.isTransparencyModeEnabled,
                                  onChanged: (v) {
                                    ref
                                        .read(themeSettingsProvider.notifier)
                                        .toggleTransparencyMode(v);
                                  },
                                ),
                            ],
                          ),
                        ),
                        if (themeSettings.isTransparencyModeEnabled && supporterTier >= 3) ...[
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Transparency Level',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Capped at 20% for readability.',
                                    style: TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              Text(
                                '${(themeSettings.opacity * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 14,
                              ),
                            ),
                            child: Slider(
                              value: themeSettings.opacity,
                              min: 0.2,
                              max: 0.85,
                              divisions: 65,
                              onChanged: (v) {
                                ref
                                    .read(themeSettingsProvider.notifier)
                                    .setOpacity(v);
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Premium Group Taster Banner
                    _buildTasterBanner(
                      context,
                      ref,
                      colorScheme,
                      (supporterTier < 1 && themeSettings.seedColorValue != curatedColors[0]['color'].toARGB32()) ||
                      (supporterTier < 2 && themeSettings.useDynamicColor) ||
                      (supporterTier < 3 && themeSettings.isTransparencyModeEnabled),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Window Behavior Section
          SqaCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.desktop_windows, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Window Behavior',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Always on Top',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Keep the toolbar above all other windows.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SqaSwitch(
                      value: themeSettings.alwaysOnTop,
                      onChanged: (v) {
                        ref
                            .read(themeSettingsProvider.notifier)
                            .setAlwaysOnTop(v);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // Hotkeys Section
          SqaCard(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.keyboard, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Hotkeys',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SqaHotkeyField(
                  label: 'Universal Toolbar Shortcut',
                  value: ref.watch(hotkeySettingsProvider).showToolbar,
                  onSave: (info) {
                    final error = ref
                        .read(hotkeySettingsProvider.notifier)
                        .updateHotkey(
                          PreferencesService.keyHotkeyShowToolbar,
                          info,
                        );
                    if (error != null) {
                      SqaToast.show(context, error, type: SqaToastType.error);
                    } else {
                      SqaToast.show(
                        context,
                        'Toolbar shortcut updated!',
                        type: SqaToastType.success,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          // System & About Section
          const _SystemAboutSection(),
        ],
      ),
    );
  }
}

class _SystemAboutSection extends ConsumerWidget {
  const _SystemAboutSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final versionAsync = ref.watch(appVersionProvider);
    final updateState = ref.watch(updateStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Listen for update results
    ref.listen(updateStateProvider, (previous, next) {
      next.when(
        data: (update) {
          if (update != null) {
            SqaUpdateModal.show(context, update);
          } else if (previous is AsyncLoading) {
            SqaToast.show(
              context,
              'You are up to date!',
              type: SqaToastType.success,
            );
          }
        },
        error: (err, _) => SqaToast.show(
          context,
          'Update check failed.',
          type: SqaToastType.error,
        ),
        loading: () {},
      );
    });

    return SqaCard(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.info, size: 20),
              const SizedBox(width: 12),
              Text(
                'System Information',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const SqaIconContainer(
                icon: Symbols.deployed_code,
                size: 48,
                iconSize: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SQA-Multitools',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    versionAsync.when(
                      data: (v) => Text(
                        'Version $v',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      loading: () => const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (error, stackTrace) =>
                          const Text('Version unknown'),
                    ),
                  ],
                ),
              ),
              SqaButton.tonal(
                label: 'Check for Updates',
                icon: Symbols.sync,
                isLoading: updateState is AsyncLoading,
                onPressed: () {
                  ref.read(updateStateProvider.notifier).checkForUpdates();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          SqaButton.outlined(
            onPressed: () =>
                launchUrl(Uri.parse('https://sqa-multitools.pages.dev')),
            label: 'Visit Official Website',
            icon: Symbols.open_in_new,
          ),
        ],
      ),
    );
  }
}

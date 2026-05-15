import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/services/coffee_shop_service.dart';
import '../../../core/services/logging_service.dart';
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
import '../../../ui/widgets/sqa_design_tokens.dart';

class GeneralSettingsView extends ConsumerWidget {
  const GeneralSettingsView({super.key});

  static const List<Map<String, dynamic>> curatedColors = [
    {'name': 'Teal', 'color': Color(0xFF009688)},
    {'name': 'Persimmon', 'color': Color(0xFFFF6B35)}, // 2026 Trend
    {'name': 'Plum Noir', 'color': Color(0xFF543138)}, // 2026 Trend
    {'name': 'Wasabi', 'color': Color(0xFF96B85D)}, // 2026 Trend
    {'name': 'Jade', 'color': Color(0xFF00A86B)}, // 2026 Trend
    {'name': 'Coffee', 'color': Color(0xFF795548)},
    {'name': 'Ruby', 'color': Color(0xE91E63)},
    {'name': 'Amethyst', 'color': Color(0x673AB7)},
    {'name': 'Emerald', 'color': Color(0x4CAF50)},
    {'name': 'Sapphire', 'color': Color(0x2196F3)},
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
      child: Icon(icon, size: SqaTokens.spacingLarge + SqaTokens.spacingTiny, color: colorScheme.outlineVariant),
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
      padding: const EdgeInsets.only(top: SqaTokens.spacingLarge),
      child: Container(
        padding: const EdgeInsets.all(SqaTokens.spacingMedium),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(SqaTokens.spacingMedium),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Symbols.info, size: SqaTokens.spacingLarge, color: colorScheme.primary),
            const SizedBox(width: SqaTokens.spacingMedium),
            Expanded(
              child: Text(
                'This is a taster service. If you enjoy this blend, you can order it at the shop!',
                style: TextStyle(
                  fontSize: SqaTokens.fontSizeSmall,
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
        borderRadius: BorderRadius.circular(SqaTokens.spacingXSmall),
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
            padding: const EdgeInsets.all(SqaTokens.spacingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.palette, size: SqaTokens.spacingXLarge),
                    const SizedBox(width: SqaTokens.spacingMedium),
                    Text(
                      'Appearance',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SqaTokens.spacingLarge),
                const Text(
                  'Theme Mode',
                  style: TextStyle(fontSize: SqaTokens.spacingMedium, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: SqaTokens.spacingSmall),
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
                const SizedBox(height: SqaTokens.spacingXLarge),
                // Premium Effects Group
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Symbols.coffee, size: SqaTokens.spacingMedium, color: colorScheme.primary),
                        const SizedBox(width: SqaTokens.spacingSmall),
                        Text(
                          'Coffee Shop Amenities',
                          style: TextStyle(
                            fontSize: SqaTokens.fontSizeSmall,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SqaTokens.spacingLarge),

                    // Accent Color Selection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Accent Color',
                          style: TextStyle(
                            fontSize: SqaTokens.spacingMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildTierBadge(1, supporterTier, colorScheme),
                      ],
                    ),
                    const SizedBox(height: SqaTokens.spacingMedium),
                    Wrap(
                      spacing: SqaTokens.spacingMedium,
                      runSpacing: SqaTokens.spacingMedium,
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
                              width: SqaTokens.spacingXXLarge + SqaTokens.spacingLarge,
                              height: SqaTokens.spacingXXLarge + SqaTokens.spacingLarge,
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
                                      size: SqaTokens.spacingLarge - 2,
                                    )
                                  : (isSelected
                                        ? const Icon(
                                            Symbols.check,
                                            color: Colors.white,
                                            size: SqaTokens.spacingLarge + SqaTokens.spacingTiny,
                                          )
                                        : null),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: SqaTokens.spacingXLarge),
                    
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
                                        fontSize: SqaTokens.fontSizeSmall,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (supporterTier < 2 && themeSettings.useDynamicColor) ...[
                                      const SizedBox(width: SqaTokens.spacingSmall),
                                      _buildPreviewBadge(colorScheme),
                                    ],
                                  ],
                                ),
                                const Text(
                                  'Use your system colors as the app theme.',
                                  style: TextStyle(fontSize: SqaTokens.fontSizeSmall, color: Colors.grey),
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
                    
                    const SizedBox(height: SqaTokens.spacingLarge),

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
                                          const SizedBox(width: SqaTokens.spacingSmall),
                                          _buildPreviewBadge(colorScheme),
                                        ],
                                      ],
                                    ),
                                    const Text(
                                      'Enable premium transparency effects for a cleaner look.',
                                      style: TextStyle(fontSize: SqaTokens.spacingSmall + 3, color: Colors.grey),
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
                          const SizedBox(height: SqaTokens.spacingLarge),
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
                                  fontSize: SqaTokens.fontSizeSmall,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: SqaTokens.spacingSmall),
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
                              max: 0.95,
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

          const SizedBox(height: SqaTokens.spacingXLarge),
          // Window Behavior Section
          SqaCard(
            padding: const EdgeInsets.all(SqaTokens.spacingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.desktop_windows, size: 20),
                    const SizedBox(width: SqaTokens.spacingMedium),
                    Text(
                      'Window Behavior',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: SqaTokens.fontSizeSmall + 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SqaTokens.spacingLarge),
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
                            style: TextStyle(fontSize: SqaTokens.fontSizeSmall, color: Colors.grey),
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

          const SizedBox(height: SqaTokens.spacingXLarge),
          // Hotkeys Section
          SqaCard(
            padding: const EdgeInsets.all(SqaTokens.spacingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.keyboard, size: 20),
                    const SizedBox(width: SqaTokens.spacingMedium),
                    Text(
                      'Hotkeys',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SqaTokens.spacingLarge),
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

          const SizedBox(height: SqaTokens.spacingXLarge),
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
      padding: const EdgeInsets.all(SqaTokens.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.info, size: 20),
              const SizedBox(width: SqaTokens.spacingMedium),
              Text(
                'System Information',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: SqaTokens.spacingXLarge),
          Row(
            children: [
              const SqaIconContainer(
                icon: Symbols.deployed_code,
                size: SqaTokens.spacingXXXLarge * 1.5,
                iconSize: SqaTokens.spacingXXLarge,
              ),
              const SizedBox(width: SqaTokens.spacingLarge),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SQA-Multitools',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: SqaTokens.fontSizeSmall + 2,
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
          const SizedBox(height: SqaTokens.spacingLarge),
          const Divider(height: 1),
          const SizedBox(height: SqaTokens.spacingLarge),
          Row(
            children: [
              Expanded(
                child: SqaButton.outlined(
                  onPressed: () =>
                      launchUrl(Uri.parse('https://sqa-multitools.pages.dev')),
                  label: 'Visit Official Website',
                  icon: Symbols.open_in_new,
                ),
              ),
              const SizedBox(width: SqaTokens.spacingMedium),
              Expanded(
                child: SqaButton.tonal(
                  onPressed: () async {
                    final logPath = await ref
                        .read(loggingServiceProvider.notifier)
                        .getLogFilePath();
                    if (logPath != null) {
                      final file = File(logPath);
                      if (await file.exists()) {
                        await launchUrl(Uri.file(logPath));
                      } else {
                        if (context.mounted) {
                          SqaToast.show(
                            context,
                            'Log file not found yet.',
                            type: SqaToastType.info,
                          );
                        }
                      }
                    }
                  },
                  label: 'Diagnostic Logs',
                  icon: Symbols.terminal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

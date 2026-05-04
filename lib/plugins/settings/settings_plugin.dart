import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../core/models/sqa_plugin.dart';
import '../../core/providers/plugin_provider.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/coffee_shop_service.dart';
import '../../core/providers/debug_provider.dart';
import '../../core/providers/hotkey_provider.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_segmented_button.dart';
import '../../ui/widgets/sqa_icon_container.dart';
import '../../ui/widgets/sqa_info_banner.dart';
import '../../ui/widgets/sqa_toast.dart';
import '../../ui/widgets/sqa_switch.dart';
import '../../ui/widgets/sqa_plugin_header.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_button.dart';
import '../../ui/widgets/sqa_hotkey_field.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../ui/widgets/sqa_styles.dart';
import '../../ui/widgets/sqa_fade_wrapper.dart';
import '../../ui/widgets/sqa_modal.dart';
import 'providers/settings_debug_provider.dart';
import '../../core/providers/version_provider.dart';
import '../../ui/widgets/sqa_update_modal.dart';

class SettingsPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.settings';
  @override
  String get name => 'Settings';
  @override
  String get description => 'Configure SQA-Multitools.';
  @override
  IconData get icon => Symbols.settings;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const SettingsView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(
      child: Text('Settings Logic Error'),
    ); // Self-referential protection
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialTab = ref.watch(settingsTabProvider);
    final history = ref.watch(navigationHistoryProvider);
    final navService = ref.read(navigationServiceProvider);

    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: SqaPluginLayout(
        icon: Symbols.settings,
        title: 'System Settings',
        description: 'Personalize your SQA-Multitools experience.',
        onBack: history != null ? () => navService.goBack() : null,
        useMask: false, // Handle internal fading for specific tabs
        tabs: [
          const Tab(icon: Icon(Symbols.settings), text: 'General'),
          const Tab(icon: Icon(Symbols.extension), text: 'Plugins'),
          const Tab(icon: Icon(Symbols.coffee), text: 'Coffee Shop'),
        ],
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SqaFadeWrapper(child: const GeneralSettingsView()),
            const PluginsSettingsView(),
            SqaFadeWrapper(child: const CoffeeShopView()),
          ],
        ),
      ),
    );
  }
}

class CoffeeShopView extends ConsumerStatefulWidget {
  const CoffeeShopView({super.key});

  @override
  ConsumerState<CoffeeShopView> createState() => _CoffeeShopViewState();
}

class _CoffeeShopViewState extends ConsumerState<CoffeeShopView> {
  Future<void> _launchDonation() async {
    final url = Uri.parse('https://ko-fi.com/pertamaks');
    if (!await launchUrl(url)) {
      if (mounted) {
        SqaToast.show(
          context,
          'Could not open donation page.',
          type: SqaToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supporterTier = ref.watch(supporterTierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SqaPluginScrollableContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuHeader(colorScheme),
          const SizedBox(height: 24),
          _buildCoffeeMenu(colorScheme, supporterTier),
          if (supporterTier >= 3) ...[
            const SizedBox(height: 16),
            _buildBugSquashToggle(colorScheme),
          ],
          const SizedBox(height: 32),
          _buildRedemptionStatus(colorScheme, supporterTier),
          const SizedBox(height: 32),
          _buildResetDonationButton(colorScheme),
        ],
      ),
    );
  }

  Widget _buildMenuHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SqaPluginHeader(
          icon: Symbols.coffee_maker,
          title: 'The Coffee Shop',
          description: 'Fueling your QA workflow since 2026',
          color: Colors.brown,
          onIconTap: () {
            if (ref
                .read(debugTapCounterProvider.notifier)
                .incrementAndCheck()) {
              final isDebug = ref.read(debugModeProvider);
              SqaToast.show(
                context,
                isDebug ? 'DEVELOPER MODE ENABLED' : 'DEVELOPER MODE DISABLED',
                type: isDebug ? SqaToastType.success : SqaToastType.info,
              );
            }
          },
        ),
        const SizedBox(height: 20),
        const SqaInfoBanner(
          title: 'Barista\'s Note:',
          text:
              'Every tool in SQA-Multitools is on the house! But if these features have saved you from a "Works on my machine" nightmare, consider tipping the barista. Your support keeps the coffee brewing and the bugs squashing!',
          color: Colors.brown,
        ),
        const SizedBox(height: 20),
        SqaButton.tonal(
          onPressed: _launchDonation,
          icon: Symbols.coffee,
          label: 'Support on Ko-fi',
          width: 200,
        ),
      ],
    );
  }

  Widget _buildCoffeeMenu(ColorScheme colorScheme, int tier) {
    return Column(
      children: [
        _buildMenuCard(
          title: 'Espresso',
          price: '\$3',
          description: 'A quick boost!',
          icon: Symbols.coffee,
          isUnlocked: tier >= 1,
          color: Colors.brown.shade300,
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          title: 'Vanilla Latte',
          price: '\$5',
          description: 'Sweet and smooth.',
          icon: Symbols.local_cafe,
          isUnlocked: tier >= 2,
          color: Colors.orange.shade300,
        ),
        const SizedBox(height: 12),
        _buildMenuCard(
          title: 'Double Mocha',
          price: '\$10+',
          description: 'The ultimate fuel.',
          icon: Symbols.water_full,
          isUnlocked: tier >= 3,
          color: Colors.brown.shade600,
        ),
      ],
    );
  }

  Widget _buildBugSquashToggle(ColorScheme colorScheme) {
    final bugsSquashed = ref
        .watch(preferencesServiceProvider)
        .getBugsSquashed();
    final isEnabled = ref.watch(bugSquashEnabledProvider);

    return Column(
      children: [
        SqaCard(
          padding: EdgeInsets.zero,
          child: SqaSettingsTile(
            icon: Symbols.padel,
            iconColor: Colors.green.shade700,
            title: 'Bug Squasher',
            subtitle: 'Bugs squashed so far: $bugsSquashed',
            trailing: SqaSwitch(
              value: isEnabled,
              onChanged: (v) {
                ref.read(bugSquashEnabledProvider.notifier).setEnabled(v);
              },
            ),
          ),
        ),
        if (ref.watch<bool>(debugModeProvider)) ...[
          const SizedBox(height: 8),
          _buildBugDiagnostics(colorScheme),
        ],
      ],
    );
  }

  Widget _buildBugDiagnostics(ColorScheme colorScheme) {
    final isEnabled = ref.watch(bugSquashEnabledProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: SqaStyles.radiusLarge,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DEVELOPER DIAGNOSTICS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: colorScheme.primary,
                ),
              ),
              const Icon(Symbols.labs, size: 14),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Bugs Triggers:',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _diagButton(0, Symbols.arrow_upward, 'Top', colorScheme),
                _diagButton(1, Symbols.arrow_downward, 'Bottom', colorScheme),
                _diagButton(2, Symbols.arrow_back, 'Left', colorScheme),
                _diagButton(3, Symbols.arrow_forward, 'Right', colorScheme),
              ],
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _buildResetDonationButton(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _diagButton(
    int side,
    IconData icon,
    String label,
    ColorScheme colorScheme,
  ) {
    return Tooltip(
      message: 'Trigger $label Border',
      child: IconButton(
        onPressed: () {
          try {
            ref.read(bugTriggerProvider.notifier).trigger(side);
          } catch (e) {
            // Overlay might not be active
          }
        },
        icon: Icon(icon, size: 16),
        style: IconButton.styleFrom(
          backgroundColor: colorScheme.surface,
          padding: const EdgeInsets.all(4),
          minimumSize: const Size(32, 32),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String price,
    required String description,
    required IconData icon,
    required bool isUnlocked,
    required Color color,
  }) {
    return SqaCard(
      padding: const EdgeInsets.all(16.0),
      borderRadius: BorderRadius.circular(16),
      borderSide: isUnlocked
          ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      price,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Symbols.check_circle, color: Colors.green, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildRedemptionStatus(ColorScheme colorScheme, int tier) {
    final email = ref.watch(coffeeShopServiceProvider).supporterEmail;

    return SqaCard(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tier > 0 ? 'Active License' : 'Code Redemption',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (tier > 0 && email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Bound to: ${_maskEmail(email)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  const Text(
                    'Redeem your coffee receipt to unlock features.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          SqaButton(
            label: tier > 0 ? 'Change' : 'Redeem',
            onPressed: () => _showRedemptionModal(context),
            width: 100,
          ),
        ],
      ),
    );
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    if (name.length <= 2) return email;
    return '${name.substring(0, 1)}***@${parts[1]}';
  }

  void _showRedemptionModal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => const SqaRedemptionModal(),
    );
  }

  Widget _buildResetDonationButton(ColorScheme colorScheme) {
    return SqaButton.outlined(
      onPressed: () async {
        await ref.read(settingsDebugActionsProvider.notifier).resetLicense();
        if (mounted) {
          SqaToast.show(
            context,
            'Donation status and squashed bugs reset.',
            type: SqaToastType.info,
          );
        }
      },
      icon: Symbols.refresh,
      label: 'Reset Donation (Debug)',
      color: colorScheme.error,
    );
  }
}

class SqaRedemptionModal extends ConsumerStatefulWidget {
  const SqaRedemptionModal({super.key});

  @override
  ConsumerState<SqaRedemptionModal> createState() => _SqaRedemptionModalState();
}

class _SqaRedemptionModalState extends ConsumerState<SqaRedemptionModal> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleRedeem() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Please enter a valid email.');
      return;
    }
    if (code.isEmpty) {
      setState(() => _error = 'Please enter your receipt code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final tier = await ref
        .read(supporterTierProvider.notifier)
        .redeem(email, code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (tier != null) {
        Navigator.of(context).pop();
        SqaToast.show(
          context,
          'License verified! Thank you for the coffee!',
          type: SqaToastType.success,
        );
      } else {
        setState(() => _error = 'Invalid code or email mismatch.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SqaModal<void>.custom(
      title: 'Redeem Coffee',
      icon: Symbols.coffee,
      confirmLabel: 'Verify',
      cancelLabel: 'Cancel',
      customActions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        SqaButton(
          label: 'Verify',
          onPressed: _isLoading ? null : _handleRedeem,
          isLoading: _isLoading,
          width: 100,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your details to activate your supporter tier. Your email is used to bind the license to you.',
            style: TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 20),
          label('Email Address'),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: 'your@email.com',
              prefixIcon: Icon(Symbols.mail, size: 20),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),
          const SizedBox(height: 16),
          label('Receipt Code'),
          const SizedBox(height: 8),
          TextField(
            controller: _codeController,
            decoration: const InputDecoration(
              hintText: 'ESP-XXXX-XXXX-YY',
              prefixIcon: Icon(Symbols.confirmation_number, size: 20),
            ),
            textCapitalization: TextCapitalization.characters,
            enabled: !_isLoading,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget label(String text) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class PluginsSettingsView extends ConsumerStatefulWidget {
  const PluginsSettingsView({super.key});

  @override
  ConsumerState<PluginsSettingsView> createState() =>
      _PluginsSettingsViewState();
}

class _PluginsSettingsViewState extends ConsumerState<PluginsSettingsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFocused();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocused() {
    final history = ref.read(navigationHistoryProvider);
    if (history == null) return;

    final allPlugins = ref.read(orderedAvailablePluginsProvider);
    final index = allPlugins.indexWhere((p) => p.id == history);

    if (index != -1 && _scrollController.hasClients) {
      // Estimate position: each collapsed card is ~72px high + 8px margin
      const itemHeight = 80.0;
      final targetOffset = (index * itemHeight).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlugins = ref.watch(orderedAvailablePluginsProvider);
    final enabledPlugins = ref.watch(enabledPluginsProvider);
    final history = ref.watch(navigationHistoryProvider);
    final editMode = ref.watch(pluginEditModeProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                editMode ? 'Rearrange Plugins' : 'Manage Plugins',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SqaButton(
                label: editMode ? 'Done' : 'Sort',
                icon: editMode ? Symbols.check : Symbols.sort,
                onPressed: () {
                  ref.read(pluginEditModeProvider.notifier).toggle();
                },
                width: 85,
              ),
            ],
          ),
        ),
        Expanded(
          child: SqaFadeWrapper(
            child: Scrollbar(
              controller: _scrollController,
              child: ReorderableListView.builder(
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(enabledPluginsProvider.notifier)
                      .reorder(oldIndex, newIndex);
                },
                scrollController: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: allPlugins.length,
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final animValue = Curves.easeInOut.transform(
                        animation.value,
                      );
                      final elevation = lerpDouble(0, 6, animValue)!;
                      return Material(
                        elevation: elevation,
                        color: Colors.transparent,
                        shadowColor: Colors.black26,
                        borderRadius: SqaStyles.radiusLarge,
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final plugin = allPlugins[index];
                  final isEnabled = enabledPlugins.any(
                    (p) => p.id == plugin.id,
                  );
                  final isFocused = !editMode && history == plugin.id;

                  return SqaCard(
                    // Use a dynamic key to force rebuild and collapse when toggling editMode
                    key: ValueKey('${plugin.id}_$editMode'),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: EdgeInsets.zero,
                    borderSide: isFocused
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          )
                        : null,
                    child: ExpansionTile(
                      collapsedShape: const Border(),
                      shape: const Border(),
                      // Disable expansion interactions in Edit Mode
                      enabled: !editMode,
                      initiallyExpanded: isFocused,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (editMode)
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Icon(
                                  Symbols.drag_indicator,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                          SqaIconContainer(
                            icon: plugin.icon,
                            size: 32,
                            iconSize: 18,
                          ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Text(
                            plugin.name,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (plugin.badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: plugin.badge == 'ALPHA'
                                    ? Colors.amber
                                    : plugin.badge == 'BETA'
                                    ? Colors.blue
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                plugin.badge!,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      plugin.badge == 'ALPHA' ||
                                          plugin.badge == 'BETA'
                                      ? Colors.white
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        plugin.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      // Hide toggle switches in Edit Mode to reduce clutter
                      trailing: editMode
                          ? const SizedBox.shrink()
                          : SqaSwitch(
                              value: isEnabled,
                              onChanged: (v) {
                                ref
                                    .read(enabledPluginsProvider.notifier)
                                    .togglePlugin(plugin.id, v);
                              },
                            ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: plugin.buildSettingsPanel(context),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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

                // Color Selection
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
                    if (supporterTier < 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Symbols.lock, size: 10, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              'In-House Service',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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

                // Preview Warning / Upgrade Prompt
                if (supporterTier < 1 &&
                    themeSettings.seedColorValue !=
                        curatedColors[0]['color'].toARGB32()) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Symbols.info,
                          size: 16,
                          color: colorScheme.primary,
                        ),
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
                          label: 'Order at Shop',
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),
                // Dynamic Color Sync
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sync with Windows Accent',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Use your system colors as the app theme.',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (supporterTier < 2)
                      const Icon(Symbols.lock, size: 16, color: Colors.grey)
                    else
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
                const SizedBox(height: 24),
                // Always on Top Toggle
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

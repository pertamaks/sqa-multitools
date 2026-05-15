import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/services/coffee_shop_service.dart';
import '../../../core/providers/debug_provider.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_settings_tile.dart';
import '../../../ui/widgets/sqa_info_banner.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_plugin_header.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../providers/settings_debug_provider.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';

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
          const SizedBox(height: SqaTokens.spacingXLarge),
          _buildCoffeeMenu(colorScheme, supporterTier),
          if (supporterTier >= 3) ...[
            const SizedBox(height: SqaTokens.spacingMedium),
            _buildBugSquashToggle(colorScheme),
          ],
          const SizedBox(height: SqaTokens.spacingXXLarge),
          _buildRedemptionStatus(colorScheme, supporterTier),
          if (ref.watch(debugModeProvider)) ...[
            const SizedBox(height: SqaTokens.spacingXXLarge),
            _buildResetDonationButton(colorScheme),
          ],
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
          iconMouseCursor: SystemMouseCursors.basic,
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
        const SizedBox(height: SqaTokens.spacingLarge),
        const SqaInfoBanner(
          title: 'Barista\'s Note:',
          text:
              'Every tool in SQA-Multitools is on the house! But if these features have saved you from a "Works on my machine" nightmare, consider tipping the barista. Your support keeps the coffee brewing and the bugs squashing!',
          color: Colors.brown,
        ),
        const SizedBox(height: SqaTokens.spacingLarge),
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
        const SizedBox(height: SqaTokens.spacingMedium),
        _buildMenuCard(
          title: 'Vanilla Latte',
          price: '\$5',
          description: 'Sweet and smooth.',
          icon: Symbols.local_cafe,
          isUnlocked: tier >= 2,
          color: Colors.orange.shade300,
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
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
          const SizedBox(height: SqaTokens.spacingSmall),
          _buildBugDiagnostics(colorScheme),
        ],
      ],
    );
  }

  Widget _buildBugDiagnostics(ColorScheme colorScheme) {
    final isEnabled = ref.watch(bugSquashEnabledProvider);

    return Container(
      padding: const EdgeInsets.all(SqaTokens.spacingMedium),
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
            const SizedBox(height: SqaTokens.spacingMedium),
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
            const SizedBox(height: SqaTokens.spacingSmall),
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
          const SizedBox(height: SqaTokens.spacingMedium),
          const Divider(height: 1),
          const SizedBox(height: SqaTokens.spacingMedium),
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
    return SqaHoverIconButton(
      onPressed: () {
        try {
          ref.read(bugTriggerProvider.notifier).trigger(side);
        } catch (e) {
          // Overlay might not be active
        }
      },
      icon: icon,
      iconSize: 16,
      backgroundColor: colorScheme.surface,
      padding: 4,
      tooltip: 'Trigger $label Border',
      borderRadius: BorderRadius.circular(4),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return SqaCard(
      padding: const EdgeInsets.all(SqaTokens.spacingLarge),
      borderRadius: SqaStyles.radiusLarge,
      borderSide: isUnlocked
          ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(SqaTokens.spacingMedium),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: SqaTokens.spacingLarge),
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
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      price,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SqaTokens.spacingSmall),
                Text(
                  description,
                  style: textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Padding(
              padding: const EdgeInsets.only(left: SqaTokens.spacingSmall),
              child: Icon(
                Symbols.check_circle,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRedemptionStatus(ColorScheme colorScheme, int tier) {
    final emailAsync = ref.watch(supporterEmailProvider);

    return SqaCard(
      padding: const EdgeInsets.all(SqaTokens.spacingLarge),
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
                if (tier > 0) ...[
                  const SizedBox(height: SqaTokens.spacingSmall),
                  emailAsync.when(
                    data: (email) => Text(
                      'Bound to: ${email != null && email.isNotEmpty ? _maskEmail(email) : 'Verified User'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    loading: () => const SizedBox(
                      height: 2,
                      width: 100,
                      child: LinearProgressIndicator(),
                    ),
                    error: (error, stack) => const Text(
                      'License Active',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: SqaTokens.spacingSmall),
                  const Text(
                    'Redeem your coffee receipt to unlock features.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: SqaTokens.spacingLarge),
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
        SqaButton.tonal(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          label: 'Cancel',
        ),
        const SizedBox(width: SqaTokens.spacingSmall),
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
          const SizedBox(height: SqaTokens.spacingLarge),
          label('Email Address'),
          const SizedBox(height: SqaTokens.spacingSmall),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              hintText: 'your@email.com',
              prefixIcon: Icon(Symbols.mail, size: 20),
            ),
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
          ),
          const SizedBox(height: SqaTokens.spacingLarge),
          label('Receipt Code'),
          const SizedBox(height: SqaTokens.spacingSmall),
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
            const SizedBox(height: SqaTokens.spacingLarge),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: SqaTokens.spacingMedium),
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

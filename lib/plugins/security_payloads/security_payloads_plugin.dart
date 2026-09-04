import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import './ui/security_payloads_view.dart';
import './providers/security_payloads_provider.dart';
import '../../core/models/sqa_coachmark_step.dart';

class SecurityPayloadsPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.security_payloads';
  @override
  String get name => 'Security Payloads';
  @override
  String get description => 'Common security testing & fuzzing payloads.';
  @override
  IconData get icon => Symbols.security;

  @override
  String? get badge => null;

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const SecurityPayloadsView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Security Payloads Settings'));
  }

  @override
  Future<void> initialize() async {
    try {
      await rootBundle.loadString('assets/security_payload.md');
    } catch (e) {
      debugPrint('Warning: Failed to warm up security payload asset: $e');
    }
  }

  @override
  Future<void> dispose() async {}

  @override
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: SecurityPayloadsView.tabBarKey,
        title: 'Reference Tabs',
        description:
            'Start with the Risk Legend, then explore Web or System Vulnerabilities, and review the Ethical guidelines.',
        contentAlign: CoachmarkContentAlign.bottom,
        beforeStepAction: (ref) async {
          ref.read(securityPayloadsProvider.notifier).dismissDisclaimer();
        },
      ),
      SqaCoachmarkStep(
        targetKey: SecurityPayloadsView.firstCardKey,
        title: 'Expand for Full Context',
        description:
            'Each payload comes with a vulnerability primer, what the payload does, how to test it, and what a successful exploit looks like. Expand the card to read it.',
        contentAlign: CoachmarkContentAlign.top,
        beforeStepAction: (ref) async {
          final context = SecurityPayloadsView.tabBarKey.currentContext;
          if (context != null) {
            DefaultTabController.maybeOf(context)
                ?.animateTo(SecurityPayloadsView.firstPayloadCatIndex);
          }
          // Scroll list back to top so item 0 (firstCardKey) is mounted and visible
          final scrollController = SecurityPayloadsView.listScrollController;
          if (scrollController != null && scrollController.hasClients) {
            await scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
      ),
      SqaCoachmarkStep(
        targetKey: SecurityPayloadsView.copyButtonKey,
        title: 'Copy & Paste into Your Target',
        description:
            'Hit Copy to grab the payload string. Paste it directly into the field you\'re testing — no reformatting needed.',
        contentAlign: CoachmarkContentAlign.top,
        beforeStepAction: (ref) async {
          final tabContext = SecurityPayloadsView.tabBarKey.currentContext;
          if (tabContext != null) {
            DefaultTabController.maybeOf(tabContext)
                ?.animateTo(SecurityPayloadsView.firstPayloadCatIndex);
          }
          // Scroll list back to top so item 0 (copyButtonKey) is mounted and visible
          final scrollController = SecurityPayloadsView.listScrollController;
          if (scrollController != null && scrollController.hasClients) {
            await scrollController.animateTo(
              0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
      ),
    ];
  }
}

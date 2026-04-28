import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_field.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../ui/widgets/sqa_info_banner.dart';
import '../../ui/widgets/sqa_button.dart';
import 'security_payload_models.dart';
import 'security_payload_data.dart';
import 'providers/security_payloads_provider.dart';

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
    return const _SecurityPayloadsView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Security Payloads Settings'));
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _SecurityPayloadsView extends ConsumerStatefulWidget {
  const _SecurityPayloadsView();

  @override
  ConsumerState<_SecurityPayloadsView> createState() =>
      _SecurityPayloadsViewState();
}

class _SecurityPayloadsViewState extends ConsumerState<_SecurityPayloadsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _expandedState = {};
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initial sync from provider if URL was set (e.g. state restoration later)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlController.text = ref.read(securityPayloadsProvider).targetUrl;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showDisclaimer = ref.watch(
      securityPayloadsProvider.select((s) => s.showDisclaimer),
    );

    return Stack(
      children: [
        SqaPluginLayout(
          icon: Symbols.security,
          title: 'Security Payloads',
          description: 'Educational lab for fuzzing and vulnerability testing.',
          tabs: const [
            Tab(text: 'Web', icon: Icon(Symbols.web)),
            Tab(text: 'System', icon: Icon(Symbols.computer)),
          ],
          tabController: _tabController,
          child: TabBarView(
            controller: _tabController,
            children: [_buildWebTab(), _buildSystemTab()],
          ),
        ),
        if (showDisclaimer) _buildFloatingDisclaimer(),
      ],
    );
  }

  Widget _buildWebTab() {
    return SqaPluginScrollableContent(
      child: Column(
        children: [
          ...SecurityPayloadData.webCategories.map(
            (cat) => _buildCategory(cat),
          ),
          _buildPathTraversalSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return SqaPluginScrollableContent(
      child: Column(
        children: [
          ...SecurityPayloadData.systemCategories.map(
            (cat) => _buildCategory(cat),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategory(VulnerabilityCategory cat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SqaInfoBanner(title: cat.name, text: cat.description, icon: cat.icon),
          const SizedBox(height: 12),
          ...cat.payloads.map((p) => _buildPayloadCard(p)),
        ],
      ),
    );
  }

  Widget _buildPayloadCard(SecurityPayload p) {
    final isExpanded = _expandedState[p.payload] ?? false;

    return SqaCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SqaField(
            label: p.name,
            initialValue: p.payload,
            readOnly: true,
            isMonospace: true,
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Symbols.expand_less : Symbols.info,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _expandedState[p.payload] = !isExpanded;
                });
              },
              tooltip: 'Learn more about this payload',
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildInfoRow('Description', p.description),
            const SizedBox(height: 8),
            _buildInfoRow('How to Test', p.howToTest),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Success Indicator',
              p.successIndicator,
              isHighlight: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'RISK LEVEL: ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                _buildRiskBadge(p.risk),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPathTraversalSection() {
    final colorScheme = Theme.of(context).colorScheme;
    final generatedPTs = ref.watch(
      securityPayloadsProvider.select((s) => s.generatedPayloads),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SqaInfoBanner(
          title: 'Path Traversal Generator',
          text:
              'Paste a target URL below to automatically generate traversal strings for each parameter.',
          icon: Symbols.folder_open,
          color: colorScheme.tertiary,
        ),
        const SizedBox(height: 12),
        SqaCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SqaField(
                label: 'TARGET URL',
                controller: _urlController,
                hintText: 'https://example.com/api?file=test.png',
                icon: Symbols.link,
                onChanged: (val) =>
                    ref.read(securityPayloadsProvider.notifier).updateUrl(val),
              ),
              if (generatedPTs.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'GENERATED PAYLOADS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ...generatedPTs.map(
                  (pt) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: SqaField(
                      label: '',
                      initialValue: pt,
                      readOnly: true,
                      isMonospace: true,
                      showCopyButton: true,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingDisclaimer() {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned(
      bottom: 24,
      left: 24,
      right: 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, (1 - value) * 100),
            child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
          );
        },
        child: SqaCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: colorScheme.errorContainer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Symbols.warning, color: colorScheme.error, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'SAFETY WARNING',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'These payloads are for authorized security testing only. Using them on unauthorized targets is illegal and unethical.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: colorScheme.onErrorContainer,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 32,
                  child: SqaButton(
                    label: 'I UNDERSTAND',
                    onPressed: () => ref
                        .read(securityPayloadsProvider.notifier)
                        .dismissDisclaimer(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            fontWeight: isHighlight ? FontWeight.w500 : FontWeight.normal,
            color: isHighlight ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskBadge(PayloadRisk risk) {
    Color color;
    switch (risk) {
      case PayloadRisk.low:
        color = Colors.green;
        break;
      case PayloadRisk.medium:
        color = Colors.orange;
        break;
      case PayloadRisk.high:
        color = Colors.red;
        break;
      case PayloadRisk.critical:
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        risk.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

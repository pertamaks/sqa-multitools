import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/security_payloads_provider.dart';
import '../../security_payload_data.dart';
import '../../security_payload_models.dart';
import '../widgets/payload_card.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_info_banner.dart';
import '../../../../ui/widgets/sqa_plugin_scrollable_content.dart';

class WebTabView extends ConsumerStatefulWidget {
  const WebTabView({super.key});

  @override
  ConsumerState<WebTabView> createState() => _WebTabViewState();
}

class _WebTabViewState extends ConsumerState<WebTabView> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _urlController.text = ref.read(securityPayloadsProvider).targetUrl;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generatedPTs = ref.watch(
      securityPayloadsProvider.select((s) => s.generatedPayloads),
    );

    return SqaPluginScrollableContent(
      child: Column(
        children: [
          ...SecurityPayloadData.webCategories.map(
            (cat) => _buildCategory(cat),
          ),
          _buildPathTraversalSection(generatedPTs),
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
          ...cat.payloads.map((p) => PayloadCard(payload: p)),
        ],
      ),
    );
  }

  Widget _buildPathTraversalSection(List<String> generatedPTs) {
    final colorScheme = Theme.of(context).colorScheme;

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
}

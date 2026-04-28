import 'package:flutter/material.dart';
import '../../security_payload_data.dart';
import '../../security_payload_models.dart';
import '../widgets/payload_card.dart';
import '../../../../ui/widgets/sqa_info_banner.dart';
import '../../../../ui/widgets/sqa_plugin_scrollable_content.dart';

class SystemTabView extends StatelessWidget {
  const SystemTabView({super.key});

  @override
  Widget build(BuildContext context) {
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
          ...cat.payloads.map((p) => PayloadCard(payload: p)),
        ],
      ),
    );
  }
}

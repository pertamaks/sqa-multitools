import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/payload_providers.dart';
import '../providers/security_payloads_provider.dart';
import '../security_payload_models.dart';
import './widgets/security_disclaimer.dart';
import './widgets/payload_card.dart';
import '../../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../../ui/widgets/sqa_segmented_button.dart';
import '../../../../ui/widgets/sqa_markdown_viewer.dart';
import '../../../../ui/widgets/sqa_fade_wrapper.dart';

class SecurityPayloadsView extends ConsumerStatefulWidget {
  const SecurityPayloadsView({super.key});

  @override
  ConsumerState<SecurityPayloadsView> createState() =>
      _SecurityPayloadsViewState();
}

class _SecurityPayloadsViewState extends ConsumerState<SecurityPayloadsView> {
  final Map<String, String> _selectedSectionIds = {};

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(securityPayloadDataProvider);
    final showDisclaimer = ref.watch(
      securityPayloadsProvider.select((s) => s.showDisclaimer),
    );

    return Stack(
      children: [
        dataAsync.when(
          data: (List<PayloadCategory> categories) {
            if (categories.isEmpty) {
              return const SqaPluginLayout(
                title: 'Security Payloads',
                child: Center(
                  child: Text('No payload categories found.'),
                ),
              );
            }

            return DefaultTabController(
              length: categories.length,
              child: SqaPluginLayout(
                icon: Symbols.security,
                title: 'Security Payloads',
                description:
                    'Educational lab for fuzzing and vulnerability testing.',
                isTabScrollable: true,
                tabs: categories
                    .map((c) => Tab(
                          text: c.name,
                          icon: Icon(c.icon, size: 18),
                          iconMargin: const EdgeInsets.only(bottom: 4),
                        ))
                    .toList(),
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: categories
                      .map((cat) => _buildCategoryView(cat))
                      .toList(),
                ),
              ),
            );
          },
          loading: () => const SqaPluginLayout(
            title: 'Security Payloads',
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => SqaPluginLayout(
            title: 'Security Payloads',
            child: Center(child: Text('Error: $err')),
          ),
        ),
        if (showDisclaimer) const SecurityDisclaimer(),
      ],
    );
  }

  Widget _buildCategoryView(PayloadCategory category) {
    if (!_selectedSectionIds.containsKey(category.name) &&
        category.sections.isNotEmpty) {
      _selectedSectionIds[category.name] = category.sections.first.id;
    }

    final selectedId = _selectedSectionIds[category.name];
    final selectedSection = category.sections.firstWhere(
      (s) => s.id == selectedId,
      orElse: () => category.sections.first,
    );

    final hasStructuredData = selectedSection.structuredPayloads != null &&
        selectedSection.structuredPayloads!.isNotEmpty;

    return Column(
      children: [
        if (category.sections.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: SqaSegmentedButton<String>(
              segments: category.sections.map((s) {
                return ButtonSegment<String>(
                  value: s.id,
                  label: Text(s.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  icon: Icon(s.icon, size: 16),
                );
              }).toList(),
              selected: {selectedId ?? ''},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _selectedSectionIds[category.name] = selection.first;
                });
              },
            ),
          ),
        Expanded(
          child: SqaFadeWrapper(
            child: hasStructuredData
                ? ListView.builder(
                    key: ValueKey(selectedSection.id),
                    padding: const EdgeInsets.all(24.0),
                    itemCount: selectedSection.structuredPayloads!.length,
                    itemBuilder: (context, index) {
                      return PayloadCard(
                        payload: selectedSection.structuredPayloads![index],
                      );
                    },
                  )
                : SqaMarkdownViewer(
                    key: ValueKey(selectedSection.id),
                    markdown: selectedSection.markdown,
                    padding: const EdgeInsets.all(24.0),
                    useScrollable: true,
                  ),
          ),
        ),
      ],
    );
  }
}

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
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(securityPayloadsProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(securityPayloadsProvider);
    final dataAsync = ref.watch(securityPayloadDataProvider);
    final showDisclaimer = state.showDisclaimer;

    return Stack(
      children: [
        dataAsync.when(
          data: (List<PayloadCategory> allCategories) {
            final searchQuery = state.searchQuery.toLowerCase();
            
            // 1. Filter categories that have matching sections
            final categories = allCategories.where((cat) {
              if (searchQuery.isEmpty) return true;
              return cat.name.toLowerCase().contains(searchQuery) ||
                     cat.sections.any((s) => 
                        s.title.toLowerCase().contains(searchQuery) || 
                        s.markdown.toLowerCase().contains(searchQuery) ||
                        (s.structuredPayloads?.any((p) => 
                           p.name.toLowerCase().contains(searchQuery) || 
                           p.payload.toLowerCase().contains(searchQuery) || 
                           p.description.toLowerCase().contains(searchQuery)) ?? false)
                     );
            }).toList();

            if (categories.isEmpty) {
              return SqaPluginLayout(
                icon: Symbols.security,
                title: 'Security Payloads',
                searchController: _searchController,
                onSearchChanged: (val) =>
                    ref.read(securityPayloadsProvider.notifier).setSearchQuery(val),
                searchHint: 'Filter payloads...',
                child: const Center(
                  child: Text('No matching payloads found.'),
                ),
              );
            }

            return SqaPluginLayout(
              icon: Symbols.security,
              title: 'Security Payloads',
              description:
                  'Educational lab for fuzzing and vulnerability testing.',
              searchController: _searchController,
              onSearchChanged: (val) =>
                  ref.read(securityPayloadsProvider.notifier).setSearchQuery(val),
              searchHint: 'Filter payloads...',
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
                    .map((cat) => _buildCategoryView(cat, state))
                    .toList(),
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

  Widget _buildCategoryView(PayloadCategory category, SecurityPayloadsState state) {
    final searchQuery = state.searchQuery.toLowerCase();
    
    // 2. Filter sections within this category
    final filteredSections = category.sections.where((s) {
      if (searchQuery.isEmpty) return true;
      return s.title.toLowerCase().contains(searchQuery) || 
             s.markdown.toLowerCase().contains(searchQuery) ||
             (s.structuredPayloads?.any((p) => 
                p.name.toLowerCase().contains(searchQuery) || 
                p.payload.toLowerCase().contains(searchQuery) || 
                p.description.toLowerCase().contains(searchQuery)) ?? false);
    }).toList();

    if (filteredSections.isEmpty) {
      return const Center(child: Text('No matching sections in this category.'));
    }

    if (!_selectedSectionIds.containsKey(category.name) || 
        !filteredSections.any((s) => s.id == _selectedSectionIds[category.name])) {
      _selectedSectionIds[category.name] = filteredSections.first.id;
    }

    final selectedId = _selectedSectionIds[category.name];
    final selectedSection = filteredSections.firstWhere(
      (s) => s.id == selectedId,
      orElse: () => filteredSections.first,
    );

    final hasStructuredData = selectedSection.structuredPayloads != null &&
        selectedSection.structuredPayloads!.isNotEmpty;

    return Column(
      children: [
        if (filteredSections.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: SqaSegmentedButton<String>(
              segments: filteredSections.map((s) {
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
                    itemCount: (selectedSection.structuredPayloads ?? []).where((p) {
                      if (state.searchQuery.isEmpty) return true;
                      final query = state.searchQuery.toLowerCase();
                      return p.name.toLowerCase().contains(query) ||
                          p.payload.toLowerCase().contains(query) ||
                          p.description.toLowerCase().contains(query);
                    }).length,
                    itemBuilder: (context, index) {
                      final filtered = selectedSection.structuredPayloads!.where((p) {
                        if (state.searchQuery.isEmpty) return true;
                        final query = state.searchQuery.toLowerCase();
                        return p.name.toLowerCase().contains(query) ||
                            p.payload.toLowerCase().contains(query) ||
                            p.description.toLowerCase().contains(query);
                      }).toList();
                      return PayloadCard(
                        payload: filtered[index],
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

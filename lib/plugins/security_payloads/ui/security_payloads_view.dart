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
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../core/providers/coachmark_provider.dart';

class SecurityPayloadsView extends ConsumerStatefulWidget {
  const SecurityPayloadsView({super.key});

  static final tabBarKey = GlobalKey(debugLabel: 'security.tab_bar');
  static final firstCardKey = GlobalKey(debugLabel: 'security.first_card');
  static final copyButtonKey = GlobalKey(debugLabel: 'security.copy_btn');

  /// Index of the first category that has structured payload data.
  /// Updated whenever data loads so coachmark steps can navigate to it.
  static int firstPayloadCatIndex = 1;

  /// ScrollController for the payload list view, used by coachmark steps to scroll to top.
  static ScrollController? listScrollController;

  @override
  ConsumerState<SecurityPayloadsView> createState() =>
      _SecurityPayloadsViewState();
}

class _SecurityPayloadsViewState extends ConsumerState<SecurityPayloadsView> {
  final Map<String, String> _selectedSectionIds = {};
  late TextEditingController _searchController;
  late ScrollController _listScrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(securityPayloadsProvider).searchQuery,
    );
    _listScrollController = ScrollController();
    SecurityPayloadsView.listScrollController = _listScrollController;
  }

  @override
  void dispose() {
    if (SecurityPayloadsView.listScrollController == _listScrollController) {
      SecurityPayloadsView.listScrollController = null;
    }
    _searchController.dispose();
    _listScrollController.dispose();
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

            final computedFirstPayloadCatIndex = allCategories.indexWhere((cat) =>
                cat.sections.any((s) => s.structuredPayloads != null && s.structuredPayloads!.isNotEmpty));
            // Publish the resolved index so plugin beforeStepActions can read it.
            SecurityPayloadsView.firstPayloadCatIndex =
                computedFirstPayloadCatIndex < 0 ? 1 : computedFirstPayloadCatIndex;
            final firstPayloadCatIndex = SecurityPayloadsView.firstPayloadCatIndex;

            // 1. Filter categories that have matching sections
            final categories = allCategories.where((cat) {
              if (searchQuery.isEmpty) return true;
              return cat.name.toLowerCase().contains(searchQuery) ||
                  cat.sections.any(
                    (s) =>
                        s.title.toLowerCase().contains(searchQuery) ||
                        s.markdown.toLowerCase().contains(searchQuery) ||
                        (s.structuredPayloads?.any(
                              (p) =>
                                  p.name.toLowerCase().contains(searchQuery) ||
                                  p.payload.toLowerCase().contains(
                                    searchQuery,
                                  ) ||
                                  p.description.toLowerCase().contains(
                                    searchQuery,
                                  ),
                            ) ??
                            false),
                  );
            }).toList();

            if (categories.isEmpty) {
              return SqaPluginLayout(
                icon: Symbols.security,
                title: 'Security Payloads',
                searchController: _searchController,
                onSearchChanged: (val) => ref
                    .read(securityPayloadsProvider.notifier)
                    .setSearchQuery(val),
                searchHint: 'Filter payloads...',
                child: const Center(child: Text('No matching payloads found.')),
              );
            }

            return SqaPluginLayout(
              icon: Symbols.security,
              title: 'Security Payloads',
              description:
                  'Educational lab for fuzzing and vulnerability testing.',
              onShowCoachmark: () {
                ref
                    .read(coachmarkServiceProvider.notifier)
                    .requestPluginTour('com.sqa.plugin.security_payloads');
              },
              searchController: _searchController,
              onSearchChanged: (val) => ref
                  .read(securityPayloadsProvider.notifier)
                  .setSearchQuery(val),
              searchHint: 'Filter payloads...',
              isTabScrollable: true,
              tabBarKey: SecurityPayloadsView.tabBarKey,
              tabs: categories
                  .asMap()
                  .entries
                  .map(
                    (entry) => Tab(
                      text: entry.value.name,
                      icon: Icon(
                        entry.value.icon,
                        size: SqaTokens.spacingLarge + SqaTokens.spacingTiny,
                      ),
                      iconMargin: const EdgeInsets.only(
                        bottom: SqaTokens.spacingXSmall,
                      ),
                    ),
                  )
                  .toList(),
              child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                children: categories
                    .asMap()
                    .entries
                    .map((entry) => _buildCategoryView(
                          entry.value,
                          state,
                          isFirstCategory: entry.key == firstPayloadCatIndex,
                        ))
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

  Widget _buildCategoryView(
    PayloadCategory category,
    SecurityPayloadsState state, {
    bool isFirstCategory = false,
  }) {
    final searchQuery = state.searchQuery.toLowerCase();

    // 2. Filter sections within this category
    final filteredSections = category.sections.where((s) {
      if (searchQuery.isEmpty) return true;
      return s.title.toLowerCase().contains(searchQuery) ||
          s.markdown.toLowerCase().contains(searchQuery) ||
          (s.structuredPayloads?.any(
                (p) =>
                    p.name.toLowerCase().contains(searchQuery) ||
                    p.payload.toLowerCase().contains(searchQuery) ||
                    p.description.toLowerCase().contains(searchQuery),
              ) ??
              false);
    }).toList();

    if (filteredSections.isEmpty) {
      return const Center(
        child: Text('No matching sections in this category.'),
      );
    }

    if (!_selectedSectionIds.containsKey(category.name) ||
        !filteredSections.any(
          (s) => s.id == _selectedSectionIds[category.name],
        )) {
      _selectedSectionIds[category.name] = filteredSections.first.id;
    }

    final selectedId = _selectedSectionIds[category.name];
    final selectedSection = filteredSections.firstWhere(
      (s) => s.id == selectedId,
      orElse: () => filteredSections.first,
    );

    final hasStructuredData =
        selectedSection.structuredPayloads != null &&
        selectedSection.structuredPayloads!.isNotEmpty;

    final allPayloads = selectedSection.structuredPayloads ?? [];
    final filteredPayloads = allPayloads.where((p) {
      if (searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(searchQuery) ||
          p.payload.toLowerCase().contains(searchQuery) ||
          p.description.toLowerCase().contains(searchQuery);
    }).toList();

    return Column(
      children: [
        if (filteredSections.length > 1)
          Padding(
            padding: const EdgeInsets.only(
              left: SqaTokens.spacingXLarge,
              right: SqaTokens.spacingXLarge,
              top: SqaTokens.spacingMedium,
            ),
            child: SqaSegmentedButton<String>(
              segments: filteredSections.map((s) {
                return ButtonSegment<String>(
                  value: s.id,
                  label: Text(
                    s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  icon: Icon(s.icon, size: SqaTokens.spacingLarge),
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
                ? Scrollbar(
                    controller: _listScrollController,
                    child: ListView.builder(
                      key: ValueKey(selectedSection.id),
                      controller: _listScrollController,
                      padding: const EdgeInsets.all(SqaTokens.spacingXLarge),
                      itemCount: filteredPayloads.length,
                      itemBuilder: (context, index) {
                        return PayloadCard(
                          payload: filteredPayloads[index],
                          cardKey: (isFirstCategory && index == 0) ? SecurityPayloadsView.firstCardKey : null,
                          copyButtonKey: (isFirstCategory && index == 0) ? SecurityPayloadsView.copyButtonKey : null,
                        );
                      },
                    ),
                  )
                : SqaMarkdownViewer(
                    key: ValueKey(selectedSection.id),
                    markdown: selectedSection.markdown,
                    padding: const EdgeInsets.all(SqaTokens.spacingXLarge),
                    useScrollable: true,
                  ),
          ),
        ),
      ],
    );
  }
}

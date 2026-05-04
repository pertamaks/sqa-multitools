import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_markdown_viewer.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../models/cheatsheet_models.dart';
import '../providers/cheatsheet_provider.dart';

class QaCheatsheetView extends ConsumerStatefulWidget {
  const QaCheatsheetView({super.key});

  @override
  ConsumerState<QaCheatsheetView> createState() => _QaCheatsheetViewState();
}

class _QaCheatsheetViewState extends ConsumerState<QaCheatsheetView> {
  final Map<String, String> _selectedSectionIds = {};
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(cheatsheetSearchProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(cheatsheetDataProvider);

    return dataAsync.when(
      data: (List<CheatsheetCategory> categories) {
        if (categories.isEmpty) {
          return const SqaPluginLayout(
            title: 'QA Cheatsheet',
            child: Center(child: Text('No categories found.')),
          );
        }

        final searchQuery = ref.watch(cheatsheetSearchProvider);
        final filteredCategories = categories.where((cat) {
          if (searchQuery.isEmpty) return true;
          final query = searchQuery.toLowerCase();
          return cat.name.toLowerCase().contains(query) ||
              cat.sections.any(
                (s) =>
                    s.title.toLowerCase().contains(query) ||
                    s.markdown.toLowerCase().contains(query),
              );
        }).toList();

        if (filteredCategories.isEmpty) {
          return SqaPluginLayout(
            icon: Symbols.menu_book,
            title: 'QA Cheatsheet',
            searchController: _searchController,
            onSearchChanged: (val) => ref
                .read<CheatsheetSearch>(cheatsheetSearchProvider.notifier)
                .setQuery(val),
            searchHint: 'Search cheatsheet...',
            child: const Center(child: Text('No matching content found.')),
          );
        }

        return SqaPluginLayout(
          icon: Symbols.menu_book,
          title: 'QA Cheatsheet',
          description: 'High-Fidelity quality assurance reference compilation',
          searchController: _searchController,
          onSearchChanged: (val) => ref
              .read<CheatsheetSearch>(cheatsheetSearchProvider.notifier)
              .setQuery(val),
          searchHint: 'Search cheatsheet...',
          tabs: filteredCategories
              .map(
                (c) => Tab(
                  text: c.name,
                  icon: Icon(c.icon, size: 18),
                  iconMargin: const EdgeInsets.only(bottom: 4),
                ),
              )
              .toList(),
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: filteredCategories
                .map((cat) => _buildCategoryView(cat, searchQuery))
                .toList(),
          ),
        );
      },
      loading: () => const SqaPluginLayout(
        title: 'QA Cheatsheet',
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => SqaPluginLayout(
        title: 'QA Cheatsheet',
        child: Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCategoryView(CheatsheetCategory category, String searchQuery) {
    final filteredSections = category.sections.where((s) {
      if (searchQuery.isEmpty) return true;
      final query = searchQuery.toLowerCase();
      return s.title.toLowerCase().contains(query) ||
          s.markdown.toLowerCase().contains(query);
    }).toList();

    if (filteredSections.isEmpty) {
      return const Center(child: Text('No matching sections.'));
    }

    // Initialize or get selected section ID
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

    return Column(
      children: [
        if (filteredSections.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: SqaSegmentedButton<String>(
              segments: filteredSections.map((s) {
                return ButtonSegment<String>(
                  value: s.id,
                  label: Text(
                    s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
            child: SqaMarkdownViewer(
              key: ValueKey(
                selectedSection.id,
              ), // Force rebuild when switching sections
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

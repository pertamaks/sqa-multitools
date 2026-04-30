import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_markdown_viewer.dart';
import '../models/cheatsheet_models.dart';
import '../providers/cheatsheet_provider.dart';

class QaCheatsheetView extends ConsumerStatefulWidget {
  const QaCheatsheetView({super.key});

  @override
  ConsumerState<QaCheatsheetView> createState() => _QaCheatsheetViewState();
}

class _QaCheatsheetViewState extends ConsumerState<QaCheatsheetView> {
  final Map<String, String> _selectedSectionIds = {};

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(cheatsheetDataProvider);

    return dataAsync.when(
      data: (List<CheatsheetCategory> categories) {
        if (categories.isEmpty) {
          return const SqaPluginLayout(
            title: 'QA Cheatsheet',
            child: Center(
              child: Text('No categories found.'),
            ),
          );
        }

        return DefaultTabController(
          length: categories.length,
          child: SqaPluginLayout(
            icon: Symbols.menu_book,
            title: 'QA Cheatsheet',
            description: 'High-Fidelity quality assurance reference compilation',
            tabs: categories.map((c) => Tab(
              text: c.name,
              icon: Icon(c.icon, size: 18),
              iconMargin: const EdgeInsets.only(bottom: 4),
            )).toList(),
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: categories.map((cat) => _buildCategoryView(cat)).toList(),
            ),
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

  Widget _buildCategoryView(CheatsheetCategory category) {
    // Initialize or get selected section ID
    if (!_selectedSectionIds.containsKey(category.name) && category.sections.isNotEmpty) {
      _selectedSectionIds[category.name] = category.sections.first.id;
    }

    final selectedId = _selectedSectionIds[category.name];
    final selectedSection = category.sections.firstWhere(
      (s) => s.id == selectedId,
      orElse: () => category.sections.first,
    );

    return Column(
      children: [
        if (category.sections.length > 1)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: SqaSegmentedButton<String>(
              segments: category.sections.map((s) {
                return ButtonSegment<String>(
                  value: s.id,
                  label: Text(s.title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
          child: SqaMarkdownViewer(
            key: ValueKey(selectedSection.id), // Force rebuild when switching sections
            markdown: selectedSection.markdown,
            padding: const EdgeInsets.all(24.0),
            useScrollable: true,
          ),
        ),
      ],
    );
  }
}

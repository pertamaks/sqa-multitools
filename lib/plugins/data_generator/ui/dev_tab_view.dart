import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/dev_state.dart';
import '../providers/dev_provider.dart';
import '../widgets/dev_config_panel.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';

class DevTabView extends ConsumerStatefulWidget {
  const DevTabView({super.key});

  @override
  ConsumerState<DevTabView> createState() => _DevTabViewState();
}

class _DevTabViewState extends ConsumerState<DevTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(devGeneratorProvider);
    final notifier = ref.read(devGeneratorProvider.notifier);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaSegmentedButton<DevType>(
            stretches: false,
            hasChild:
                state.selectedType == DevType.json ||
                state.selectedType == DevType.date,
            segments: const [
              ButtonSegment(
                value: DevType.uuid,
                label: Text('UUID'),
                icon: Icon(Symbols.fingerprint),
              ),
              ButtonSegment(
                value: DevType.json,
                label: Text('JSON'),
                icon: Icon(Symbols.code),
              ),
              ButtonSegment(
                value: DevType.date,
                label: Text('Date'),
                icon: Icon(Symbols.calendar_today),
              ),
            ],
            selected: {state.selectedType},
            onSelectionChanged: (set) => notifier.setType(set.first),
          ),
          if (state.selectedType == DevType.json ||
              state.selectedType == DevType.date) ...[
            const SizedBox(height: 12),
            if (state.selectedType == DevType.json)
              SqaSegmentedButton<JsonCategory>(
                stretches: false,
                isChild: true,
                segments: [
                  const ButtonSegment(
                    value: JsonCategory.simple,
                    label: Text('Simple'),
                    icon: Icon(Symbols.token),
                  ),
                  const ButtonSegment(
                    value: JsonCategory.medium,
                    label: Text('Medium'),
                    icon: Icon(Symbols.data_object),
                  ),
                  const ButtonSegment(
                    value: JsonCategory.complex,
                    label: Text('Complex'),
                    icon: Icon(Symbols.account_tree),
                  ),
                ],
                selected: {state.selectedJsonCategory},
                onSelectionChanged: (set) =>
                    notifier.setJsonCategory(set.first),
              )
            else
              SqaSegmentedButton<DateCategory>(
                stretches: false,
                isChild: true,
                segments: [
                  const ButtonSegment(
                    value: DateCategory.past,
                    label: Text('Past'),
                    icon: Icon(Symbols.history),
                  ),
                  const ButtonSegment(
                    value: DateCategory.future,
                    label: Text('Future'),
                    icon: Icon(Symbols.update),
                  ),
                ],
                selected: {state.selectedDateCategory},
                onSelectionChanged: (set) =>
                    notifier.setDateCategory(set.first),
              ),
          ],
          const SizedBox(height: 12),
          Text(
            _getUsageDescription(state.selectedType),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const DevConfigPanel(),
          if ((state.resultsMap[state.selectedType] ?? <String>[])
              .isNotEmpty) ...[
            const SizedBox(height: 24),
            ..._buildDevResults(state),
          ],
        ],
      ),
    );
  }

  String _getUsageDescription(DevType type) {
    switch (type) {
      case DevType.uuid:
        return 'Generate random Version 4 Universally Unique Identifiers.';
      case DevType.json:
        return 'Generate nested mock JSON structures for API testing.';
      case DevType.date:
        return 'Generate past or future dates in common developer formats.';
    }
  }

  List<Widget> _buildDevResults(DevState state) {
    final results = state.resultsMap[state.selectedType] ?? <String>[];
    if (state.selectedType == DevType.date && results.length == 5) {
      final labels = [
        'ISO 8601',
        'RFC 2822',
        'SQL DATETIME',
        'UNIX TIMESTAMP',
        'HUMAN READABLE',
      ];
      return List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 4 ? 0 : 16.0),
          child: SqaField(
            label: labels[index],
            initialValue: results[index],
            icon: Symbols.calendar_today,
            isMonospace: true,
          ),
        );
      });
    }

    if (state.selectedType == DevType.uuid && results.isNotEmpty) {
      final latest = results.first;
      final history = state.uuidHistory.where((u) => u != latest).toList();

      return [
        SqaField(
          label: 'Latest UUID',
          initialValue: latest,
          icon: Symbols.fingerprint,
          isMonospace: true,
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 24),
          SqaField(
            label: 'HISTORY (LAST 10)',
            initialValue: history.join('\n'),
            icon: Symbols.history,
            isMultiline: true,
            isMonospace: true,
            collapsedMaxLines: 10,
          ),
        ],
      ];
    }

    // JSON or fallback
    return [
      SqaField(
        label: 'Result',
        initialValue: results.join('\n\n---\n\n'),
        icon: _getDevIcon(state.selectedType),
        isMultiline: true,
        isMonospace: true,
        collapsedMaxLines: 10,
      ),
    ];
  }

  IconData _getDevIcon(DevType type) {
    switch (type) {
      case DevType.uuid:
        return Symbols.fingerprint;
      case DevType.json:
        return Symbols.code;
      case DevType.date:
        return Symbols.calendar_today;
    }
  }
}

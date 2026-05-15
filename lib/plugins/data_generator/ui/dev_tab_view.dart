import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter/services.dart';

import '../models/dev_state.dart';
import '../providers/dev_provider.dart';
import '../providers/identity_provider.dart';
import '../widgets/dev_config_panel.dart';
import 'widgets/history_tile.dart';
import '../../../ui/widgets/sqa_history_list.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../core/utils/locale_names.dart';

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

  void _showResult(List<String> session, String title) {
    final state = ref.read(devGeneratorProvider);
    String text = '';
    
    if (state.selectedType == DevType.date && session.length == 5) {
      final labels = [
        'ISO 8601',
        'RFC 2822',
        'SQL DATETIME',
        'UNIX TIMESTAMP',
        'HUMAN READABLE',
      ];
      text = List.generate(5, (index) => '${labels[index]}:\n${session[index]}').join('\n\n');
    } else {
      text = state.includeFormatting 
          ? session.map((e) => '• $e').join('\n') 
          : session.join('\n');
    }

    showDialog<void>(
      context: context,
      builder: (context) => SqaModal<void>.custom(
        title: title,
        scrollable: false,
        confirmLabel: 'Close',
        customActions: [
          SqaButton.tonal(
            label: 'Copy',
            icon: Symbols.content_copy,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              SqaToast.show(context, 'Copied to clipboard', type: SqaToastType.success);
            },
          ),
          const SizedBox(width: SqaTokens.spacingXXSmall),
          SqaButton.primary(
            label: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: SqaField(
          label: 'Generated Data',
          showLabel: false,
          isMonospace: true,
          readOnly: true,
          isMultiline: true,
          maxLines: null,
          expands: true,
          fontSize: SqaTokens.spacingMedium,
          showLineNumbers: true,
          showCopyButton: false,
          initialValue: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(devGeneratorProvider);
    final identityState = ref.watch(identityProvider);
    final notifier = ref.read(devGeneratorProvider.notifier);
    final history = state.resultsMap[state.selectedType] ?? [];
    final theme = Theme.of(context);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              _getUsageDescription(state.selectedType),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: SqaTokens.spacingXLarge),
          const DevConfigPanel(),
          const SizedBox(height: SqaTokens.spacingXLarge),
          
          SqaHistoryList<List<String>>(
            items: history,
            title: 'History',
            onClearAll: () => notifier.clear(),
            itemBuilder: (context, item, isLast) {
              final index = history.indexOf(item);
              final displayIndex = history.length - index;
              return DataHistoryTile(
                title: state.selectedType == DevType.uuid
                    ? '${state.selectedType.label} • ${LocaleNames.getDisplayName(identityState.locale.name)} • ${identityState.quantity} items ($displayIndex)'
                    : '${state.selectedType.label} • ${LocaleNames.getDisplayName(identityState.locale.name)} ($displayIndex)',
                subtitle: state.selectedType == DevType.uuid 
                    ? item.join(', ')
                    : item.first,
                icon: _getDevIcon(state.selectedType),
                onTap: () => _showResult(item, 'Dev Result'),
                onDelete: () => notifier.removeHistory(item),
                customActions: [
                  SqaHoverIconButton(
                    icon: Symbols.content_copy,
                    tooltip: 'Copy all',
                    onPressed: () {
                      final text = (state.selectedType == DevType.uuid && state.includeFormatting)
                          ? item.map((e) => '• $e').join('\n')
                          : item.join('\n');
                      Clipboard.setData(ClipboardData(text: text));
                      SqaToast.show(context, 'Copied to clipboard', type: SqaToastType.success);
                    },
                  ),
                ],
              );
            },
          ),
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

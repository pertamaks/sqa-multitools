import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/dev_state.dart';
import '../providers/dev_provider.dart';
import '../providers/identity_provider.dart';
import '../widgets/dev_config_panel.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_toast.dart';
import 'widgets/history_tile.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../core/utils/locale_names.dart';
import 'package:flutter/services.dart';

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
          const SizedBox(width: 8),
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
          fontSize: 12,
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
          SizedBox(height: SqaSpacing.xLarge),
          const DevConfigPanel(),
          SizedBox(height: SqaSpacing.xLarge),
          
          if (history.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'History',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                SqaHoverIconButton(
                  icon: Symbols.delete_sweep,
                  onPressed: () async {
                    final confirmed = await SqaModal.showDanger(
                      context,
                      title: 'Clear History',
                      message: 'Are you sure you want to clear all generation history for this category?',
                      confirmLabel: 'Clear All',
                    );
                    if (confirmed == true) {
                      notifier.clear();
                    }
                  },
                  tooltip: 'Clear All',
                  iconSize: 18,
                  color: theme.colorScheme.error.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SqaCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < history.length; i++) ...[
                    DataHistoryTile(
                      title: state.selectedType == DevType.uuid
                          ? '${state.selectedType.label} • ${LocaleNames.getDisplayName(identityState.locale.name)} • ${identityState.quantity} items (${history.length - i})'
                          : '${state.selectedType.label} • ${LocaleNames.getDisplayName(identityState.locale.name)} (${history.length - i})',
                      subtitle: state.selectedType == DevType.uuid 
                          ? history[i].join(', ')
                          : history[i].first,
                      icon: _getDevIcon(state.selectedType),
                      onTap: () => _showResult(history[i], 'Dev Result'),
                      onDelete: () => ref.read(devGeneratorProvider.notifier).removeHistory(history[i]),
                      customActions: [
                        SqaHoverIconButton(
                          icon: Symbols.content_copy,
                          tooltip: 'Copy all',
                          onPressed: () {
                            final text = (state.selectedType == DevType.uuid && state.includeFormatting)
                                ? history[i].map((e) => '• $e').join('\n')
                                : history[i].join('\n');
                            Clipboard.setData(ClipboardData(text: text));
                            SqaToast.show(context, 'Copied to clipboard', type: SqaToastType.success);
                          },
                        ),
                      ],
                    ),
                    if (i < history.length - 1) 
                      const Divider(height: 1, indent: 64),
                  ],
                ],
              ),
            ),
          ] else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Symbols.history,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No history yet',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
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

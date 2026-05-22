import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/identity_state.dart';
import '../providers/identity_provider.dart';
import '../widgets/identity_config_panel.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_toast.dart';
import 'widgets/history_tile.dart';
import '../../../ui/widgets/sqa_history_list.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../core/utils/locale_names.dart';
import 'package:flutter/services.dart';

class IdentityTabView extends ConsumerStatefulWidget {
  const IdentityTabView({super.key});

  @override
  ConsumerState<IdentityTabView> createState() => _IdentityTabViewState();
}

class _IdentityTabViewState extends ConsumerState<IdentityTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showResult(List<String> session, String title) {
    final state = ref.read(identityProvider);
    final text = state.includeFormatting 
        ? session.map((e) => '• $e').join('\n') 
        : session.join('\n');
    
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
          fontSize: SqaTokens.fontSizeSmall,
          showLineNumbers: true,
          showCopyButton: false,
          initialValue: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(identityProvider);
    final notifier = ref.read(identityProvider.notifier);
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
          const IdentityConfigPanel(),
          const SizedBox(height: SqaTokens.spacingXLarge),
          
          SqaHistoryList<List<String>>(
            items: history,
            title: 'History',
            onClearAll: () => notifier.clear(),
            itemBuilder: (context, item, isLast) {
              final index = history.indexOf(item);
              final displayIndex = history.length - index;
              return DataHistoryTile(
                title: '${state.selectedType.label} • ${LocaleNames.getDisplayName(state.locale.name)} • ${state.quantity} items ($displayIndex)',
                subtitle: item.join(', '),
                icon: Symbols.person,
                onTap: () => _showResult(item, 'Identity Result'),
                onDelete: () => notifier.removeHistory(item),
                customActions: [
                  SqaHoverIconButton(
                    icon: Symbols.content_copy,
                    tooltip: 'Copy all',
                    onPressed: () {
                      final text = state.includeFormatting 
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

  String _getUsageDescription(IdentityType type) {
    switch (type) {
      case IdentityType.email:
        return 'Generate realistic email addresses with optional custom domains.';
      case IdentityType.address:
        return 'Generate localized physical mailing addresses.';
      case IdentityType.phone:
        return 'Generate formatted phone numbers with optional extensions.';
      case IdentityType.internet:
        return 'Generate mock URLs, User-Agents, and IP addresses.';
      case IdentityType.company:
        return 'Generate company names, job titles, and professional catchphrases.';
      case IdentityType.name:
        return 'Generate localized full names including first and last names.';
    }
  }
}

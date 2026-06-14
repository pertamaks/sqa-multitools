import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_icon_container.dart';
import '../../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../../ui/widgets/sqa_history_list.dart';
import '../providers/swagger_provider.dart';
import '../models/swagger_state.dart';

class SwaggerListView extends ConsumerStatefulWidget {
  const SwaggerListView({super.key});

  @override
  ConsumerState<SwaggerListView> createState() => _SwaggerListViewState();
}

class _SwaggerListViewState extends ConsumerState<SwaggerListView> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _fetchUrl() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      ref.read(swaggerProvider.notifier).fetchFromUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(swaggerProvider);

    return SqaPluginLayout(
      title: 'Swagger Explorer',
      description: 'Discover API endpoints natively and send them to the cURL Requester.',
      icon: Symbols.api,
      child: SqaPluginScrollableContent(
        center: false,
        padding: const EdgeInsets.symmetric(
          horizontal: SqaTokens.contentPaddingHorizontal,
          vertical: SqaTokens.contentPaddingVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: SqaField(
                    controller: _urlController,
                    label: 'OPENAPI URL (e.g., /v3/api-docs)',
                    hintText: 'http://localhost:8080/v3/api-docs',
                    onSubmitted: (_) => _fetchUrl(),
                  ),
                ),
                const SizedBox(width: SqaTokens.spacingMedium),
                SqaButton(
                  label: 'Fetch',
                  icon: Symbols.download,
                  onPressed: state.isLoading ? null : _fetchUrl,
                  type: SqaButtonType.primary,
                ),
              ],
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: SqaTokens.spacingMedium),
              Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            
            const SizedBox(height: SqaTokens.spacingXXXLarge),
            
            SqaHistoryList<SwaggerHistoryItem>(
              title: 'HISTORY',
              items: state.history,
              emptyLabel: 'No APIs loaded yet.',
              itemBuilder: (context, item, isLast) {
                return InkWell(
                  onTap: () {
                    if (item.url != null) {
                      ref.read(swaggerProvider.notifier).fetchFromUrl(item.url!);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: SqaTokens.spacingMedium, horizontal: SqaTokens.spacingMedium),
                    child: Row(
                      children: [
                        SqaIconContainer(
                          icon: Symbols.api,
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ),
                        const SizedBox(width: SqaTokens.spacingMedium),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (item.url != null)
                                Text(
                                  item.url!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        Icon(Symbols.chevron_right, size: 20, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

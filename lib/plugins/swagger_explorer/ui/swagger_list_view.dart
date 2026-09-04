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
import '../../../../ui/widgets/sqa_popup_menu.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import 'package:file_selector/file_selector.dart';
import '../providers/swagger_provider.dart';
import '../models/swagger_state.dart';

class SwaggerListView extends ConsumerStatefulWidget {
  const SwaggerListView({super.key});

  static final swaggerUrlKey = GlobalKey(debugLabel: 'swagger.url_input');

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
      description:
          'Discover API endpoints natively and send them to the cURL Requester.',
      icon: Symbols.data_object,
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
                Text(
                  'OPENAPI URL',
                  style: SqaTextStyles.labelBold(context).copyWith(
                    letterSpacing: 1.1,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SqaTokens.spacingSmall),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  key: SwaggerListView.swaggerUrlKey,
                  child: SqaField(
                    controller: _urlController,
                    label: '',
                    showLabel: false,
                    hintText: 'http://localhost:8080/v3/api-docs',
                    onSubmitted: (_) => _fetchUrl(),
                    showCopyButton: false,
                  ),
                ),
                const SizedBox(width: SqaTokens.spacingMedium),
                SqaButton(
                  label: '',
                  icon: Symbols.folder_open,
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          const typeGroup = XTypeGroup(
                            label: 'Swagger Documents',
                            extensions: ['json'],
                          );
                          final file = await openFile(
                            acceptedTypeGroups: [typeGroup],
                          );
                          if (file != null) {
                            ref
                                .read(swaggerProvider.notifier)
                                .fetchFromFile(file.path);
                          }
                        },
                  type: SqaButtonType.tonal,
                ),
                const SizedBox(width: SqaTokens.spacingSmall),
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

            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: SqaTokens.spacingMedium),
                child: LinearProgressIndicator(),
              ),

            const SizedBox(height: SqaTokens.spacingXXXLarge),

            SqaHistoryList<SwaggerHistoryItem>(
              title: 'HISTORY',
              items: state.history,
              emptyLabel: 'No APIs loaded yet.',
              onClearAll: () =>
                  ref.read(swaggerProvider.notifier).clearHistory(),
              itemBuilder: (context, item, isLast) {
                return SqaCard(
                  onTap: () {
                    if (item.url != null) {
                      ref
                          .read(swaggerProvider.notifier)
                          .fetchFromUrl(item.url!);
                    } else if (item.filePath != null) {
                      ref
                          .read(swaggerProvider.notifier)
                          .fetchFromFile(item.filePath!);
                    }
                  },
                  padding: const EdgeInsets.symmetric(
                    vertical: SqaTokens.spacingMedium,
                    horizontal: SqaTokens.spacingMedium,
                  ),
                  child: Row(
                    children: [
                      SqaIconContainer(
                        icon: Symbols.data_object,
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      const SizedBox(width: SqaTokens.spacingMedium),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                      SqaPopupMenu(
                        icon: Symbols.more_vert,
                        tooltip: 'Options',
                        children: [
                          SqaPopupMenuItem(
                            icon: const Icon(Symbols.delete),
                            label: 'Remove',
                            isDestructive: true,
                            onPressed: () {
                              ref
                                  .read(swaggerProvider.notifier)
                                  .deleteFromHistory(item.id);
                            },
                          ),
                        ],
                      ),
                    ],
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

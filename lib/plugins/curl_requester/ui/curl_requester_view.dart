import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_modal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/curl_requester_provider.dart';
import '../models/curl_transaction.dart';
import '../services/curl_parser_service.dart';
import 'tabs/request_tab.dart';
import 'tabs/history_tab.dart';
import 'modals/transaction_inspector_modal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../ui/widgets/sqa_popup_menu.dart';
import '../../../core/providers/plugin_provider.dart';
import '../providers/environments_provider.dart';
import '../models/environment.dart';
import 'modals/environment_editor_modal.dart';
import '../../../ui/widgets/sqa_text_controller.dart';

class CurlRequesterView extends ConsumerStatefulWidget {
  const CurlRequesterView({super.key});

  @override
  ConsumerState<CurlRequesterView> createState() => _CurlRequesterViewState();
}

class _CurlRequesterViewState extends ConsumerState<CurlRequesterView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _urlController;
  late TextEditingController _curlController;
  late ScrollController _requestScrollController;
  late ScrollController _historyScrollController;

  bool _showReflector = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestScrollController = ScrollController();
    _historyScrollController = ScrollController();
    Set<String> getVars() {
      final envs = ref.read(environmentsProvider);
      final activeId = ref.read(activeEnvironmentIdProvider);
      return envs
          .firstWhere((e) => e.id == activeId, orElse: () => envs.first)
          .variables
          .keys
          .toSet();
    }

    _urlController = SqaVariableController(
      text: ref.read(curlRequesterProvider).currentCommand.url,
      getKnownVariables: getVars,
    );
    _curlController = SqaVariableController(
      text: CurlParserService.stringify(
        ref.read(curlRequesterProvider).currentCommand,
      ),
      getKnownVariables: getVars,
    );

    // Add listener to _curlController to parse changes into the provider state
    _curlController.addListener(() {
      if (!_showReflector) {
        final notifier = ref.read(curlRequesterProvider.notifier);
        final currentState = ref.read(curlRequesterProvider);
        if (_curlController.text !=
            CurlParserService.stringify(currentState.currentCommand)) {
          notifier.updateFromCurl(_curlController.text);
        }
      }
    });

    _urlController.addListener(() {
      if (_showReflector) {
        final notifier = ref.read(curlRequesterProvider.notifier);
        final currentCommand = ref.read(curlRequesterProvider).currentCommand;
        if (currentCommand.url != _urlController.text) {
          notifier.updateCommand(
            currentCommand.copyWith(url: _urlController.text),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _curlController.dispose();
    _requestScrollController.dispose();
    _historyScrollController.dispose();
    super.dispose();
  }

  void _syncRawFromState() {
    final state = ref.read(curlRequesterProvider);
    final newCurl = CurlParserService.stringify(state.currentCommand);
    if (_curlController.text != newCurl) {
      _curlController.text = newCurl;
    }
    if (_urlController.text != state.currentCommand.url) {
      _urlController.text = state.currentCommand.url;
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      ref.read(curlRequesterProvider.notifier).updateFromCurl(data!.text!);
      _syncRawFromState();
    }
  }

  void _clearRequest() {
    ref.read(curlRequesterProvider.notifier).clearCommand();
    _syncRawFromState();
  }

  Future<void> _handleClearHistory() async {
    final history = ref.read(curlRequesterProvider).history;
    if (history.isEmpty) return;

    final confirmed = await SqaModal.showDanger(
      context,
      title: 'Clear History',
      message:
          'Are you sure you want to clear your entire request history? This action cannot be undone.',
      confirmLabel: 'Clear All',
    );

    if (confirmed == true) {
      ref.read(curlRequesterProvider.notifier).clearHistory();
    }
  }

  void _showResponseModal({
    bool isHistory = false,
    CurlTransaction? transaction,
  }) {
    TransactionInspectorModal.show(
      context,
      transaction: transaction,
      isHistory: isHistory,
      onSendAgain: () async {
        final notifier = ref.read(curlRequesterProvider.notifier);
        if (isHistory && transaction?.resolvedRequest != null) {
          await notifier.executeCommand(transaction!.resolvedRequest!);
        } else {
          await notifier.execute();
        }

        final history = ref.read(curlRequesterProvider).history;
        if (history.isNotEmpty) {
          _showResponseModal(transaction: history.first);
        }
      },
    );
  }

  Widget _buildWorkspaceSelector(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final envs = ref.watch(environmentsProvider);
    final activeId = ref.watch(activeEnvironmentIdProvider);

    final activeEnv = envs.firstWhere(
      (e) => e.id == activeId,
      orElse: () => envs.first,
    );

    return SqaPopupMenu(
      icon: Symbols.language,
      tooltip: 'Switch Environment',
      alignmentOffset: const Offset(0, SqaTokens.spacingSmall),
      builder: (context, controller, child) {
        return InkWell(
          onTap: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          borderRadius: SqaTokens.borderRadiusSmall,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SqaTokens.spacingXSmall,
              vertical: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activeEnv.name,
                  style: GoogleFonts.dmSans(
                    fontSize: SqaTokens.fontSizeSmall,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Symbols.arrow_drop_down,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        );
      },
      children: [
        ...envs.map((env) {
          final isSelected = env.id == activeId;
          return SqaPopupMenuItem(
            onPressed: () => ref
                .read(activeEnvironmentIdProvider.notifier)
                .setActiveId(env.id),
            icon: Icon(
              Symbols.language,
              color: isSelected ? theme.colorScheme.primary : null,
            ),
            label: env.name,
          );
        }),
        const Divider(height: 1),
        SqaPopupMenuItem(
          onPressed: () {
            EnvironmentEditorModal.show(context, activeEnv);
          },
          icon: Icon(Symbols.edit, color: theme.colorScheme.primary),
          label: 'Edit Active Environment',
        ),
        SqaPopupMenuItem(
          onPressed: () async {
            final name = await SqaModal.showPrompt(
              context,
              title: 'Create Environment',
              message: 'Enter a name for the new environment:',
              confirmLabel: 'Create',
              icon: Symbols.add,
            );
            if (name != null && name.isNotEmpty) {
              final newEnv = Environment(
                id: const Uuid().v4(),
                name: name,
                variables: {},
              );
              ref.read(environmentsProvider.notifier).addEnvironment(newEnv);
              ref
                  .read(activeEnvironmentIdProvider.notifier)
                  .setActiveId(newEnv.id);
              if (context.mounted) {
                EnvironmentEditorModal.show(context, newEnv);
              }
            }
          },
          icon: Icon(Symbols.add, color: theme.colorScheme.primary),
          label: 'New Environment',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(curlRequesterProvider);

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return SqaPluginLayout(
          icon: Symbols.terminal,
          titleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'cURL Requester',
                style: GoogleFonts.dmSans(
                  fontSize: SqaTokens.fontSizeXLarge,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Environment: ',
                    style: GoogleFonts.dmSans(
                      fontSize: SqaTokens.fontSizeSmall,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  _buildWorkspaceSelector(context, ref),
                ],
              ),
            ],
          ),
          description: 'Transform and execute cURL commands',
          onBack: ref.watch(navigationHistoryProvider) != null
              ? () {
                  ref.read(navigationServiceProvider).goBack();
                }
              : null,
          tabController: _tabController,
          trailing: _tabController.index == 0
              ? SqaButton.primary(
                  label: '',
                  isLoading: state.isLoading,
                  icon: Symbols.rocket_launch,
                  onPressed: () async {
                    await ref.read(curlRequesterProvider.notifier).execute();
                    if (context.mounted) {
                      final history = ref.read(curlRequesterProvider).history;
                      if (history.isNotEmpty) {
                        _showResponseModal(transaction: history.first);
                      }
                    }
                  },
                  tooltip: 'Execute Command',
                )
              : SqaHoverIconButton(
                  icon: Symbols.delete_sweep,
                  onPressed: _handleClearHistory,
                  tooltip: 'Clear History',
                  iconSize: SqaTokens.spacingXLarge,
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.8),
                ),
          tabs: const [
            Tab(
              text: 'Request',
              icon: Icon(Symbols.send, size: SqaTokens.spacingLarge),
            ),
            Tab(
              text: 'History',
              icon: Icon(Symbols.history, size: SqaTokens.spacingLarge),
            ),
          ],
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SqaFadeWrapper(
                child: RequestTab(
                  scrollController: _requestScrollController,
                  urlController: _urlController,
                  curlController: _curlController,
                  showReflector: _showReflector,
                  onToggleReflector: () =>
                      setState(() => _showReflector = !_showReflector),
                  onPasteFromClipboard: _pasteFromClipboard,
                  onClearRequest: _clearRequest,
                  onSyncRaw: _syncRawFromState,
                ),
              ),
              SqaFadeWrapper(
                child: HistoryTab(
                  scrollController: _historyScrollController,
                  onTransactionTap: _syncRawFromState,
                  showTransactionModal: (t) =>
                      _showResponseModal(isHistory: true, transaction: t),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

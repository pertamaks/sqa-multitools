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

    final initialState = ref.read(curlRequesterProvider);
    _urlController = TextEditingController(
      text: initialState.currentCommand.url,
    );
    _curlController = TextEditingController(
      text: CurlParserService.stringify(initialState.currentCommand),
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
              currentCommand.copyWith(url: _urlController.text));
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

  void _showResponseModal({bool isHistory = false, CurlTransaction? transaction}) {
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(curlRequesterProvider);

    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return SqaPluginLayout(
          icon: Symbols.terminal,
          title: 'cURL Requester',
          description: 'Transform and execute cURL commands',
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
                  iconSize: 20,
                  color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
                ),
          tabs: const [
            Tab(text: 'Request', icon: Icon(Symbols.send)),
            Tab(text: 'History', icon: Icon(Symbols.history)),
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

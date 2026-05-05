import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_status_badge.dart';
import '../../../ui/widgets/sqa_metadata_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'components/curl_requester_grid_row.dart';
import '../providers/curl_requester_provider.dart';
import '../models/curl_transaction.dart';
import '../models/curl_requester_state.dart';
import '../services/curl_parser_service.dart';


enum ModalTab { request, response }

class CurlRequesterView extends ConsumerStatefulWidget {
  const CurlRequesterView({super.key});

  @override
  ConsumerState<CurlRequesterView> createState() => _CurlRequesterViewState();
}

class _CurlRequesterViewState extends ConsumerState<CurlRequesterView>
    with SingleTickerProviderStateMixin {
  // --- State ---
  late TabController _tabController;
  late TextEditingController _urlController;
  late TextEditingController _curlController;
  late ScrollController _requestScrollController;
  late ScrollController _historyScrollController;

  bool _showReflector = false;

  ModalTab _modalTab = ModalTab.response;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestScrollController = ScrollController();
    _historyScrollController = ScrollController();

    // Initialize controllers from the CurlRequesterState
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
        // Only update if the text is actually different from the stringified state
        // to avoid recursive updates.
        final currentState = ref.read(curlRequesterProvider);
        if (_curlController.text != CurlParserService.stringify(currentState.currentCommand)) {
           notifier.updateFromCurl(_curlController.text);
        }
      }
    });

    _urlController.addListener(() {
      if (_showReflector) {
        final notifier = ref.read(curlRequesterProvider.notifier);
        final currentCommand = ref.read(curlRequesterProvider).currentCommand;
        if (currentCommand.url != _urlController.text) {
          notifier.updateCommand(currentCommand.copyWith(url: _urlController.text));
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
                  // TODO(Logic): Bind icon and loading state to CurlRequesterState.isLoading
                  icon: Symbols.rocket_launch,
                  onPressed: () {
                    // TODO(Logic): Call ref.read(curlRequesterProvider.notifier).execute()
                    _showResponseModal(context, isHistory: false);
                  },
                  tooltip: 'Execute Command',
                )
              : null,
          tabs: const [
            Tab(text: 'Request', icon: Icon(Symbols.send)),
            Tab(text: 'History', icon: Icon(Symbols.history)),
          ],
          secondaryHeader: _tabController.index == 0
              ? Container(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                  ),
                  child: _buildRequestHeader(),
                )
              : null,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SqaFadeWrapper(child: _buildRequestTab()),
              SqaFadeWrapper(child: _buildHistoryTab()),
            ],
          ),
        );
      },
    );
  }

  // TODO(Refactor): Extract into ui/tabs/request_tab.dart
  Widget _buildRequestTab() {
    return Scrollbar(
      controller: _requestScrollController,
      child: SingleChildScrollView(
        controller: _requestScrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _showReflector ? _buildUnifiedGridContent() : _buildCommandDeckContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              _showReflector ? Symbols.grid_3x3 : Symbols.terminal,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _showReflector ? 'Structured Request' : 'Command Deck (cURL)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SqaHoverIconButton(
              icon: _showReflector ? Symbols.terminal : Symbols.grid_3x3,
              onPressed: () => setState(() {
                _showReflector = !_showReflector;
              }),
              tooltip: _showReflector ? 'Switch to Command' : 'Show Grid',
              iconSize: 18,
            ),
            const SizedBox(width: 8),
            SqaHoverIconButton(
              icon: Symbols.content_paste,
              onPressed: _pasteFromClipboard,
              tooltip: 'Paste from Clipboard',
              iconSize: 18,
            ),
            const SizedBox(width: 8),
            SqaHoverIconButton(
              icon: Symbols.delete_sweep,
              onPressed: _clearRequest,
              tooltip: 'Clear Request',
              iconSize: 18,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
            ),
          ],
        ),
      ],
    );
  }

  void _clearRequest() {
    ref.read(curlRequesterProvider.notifier).clearCommand();
    _syncRawFromState();
  }

  Widget _buildCommandDeckContent() {
    return SqaCard(
      padding: const EdgeInsets.all(16),
      child: SqaField(
        label: '',
        showLabel: false,
        controller: _curlController,
        isMonospace: true,
        isMultiline: true,
        minLines: 8,
        maxLines: 20,
        fontSize: 12,
        hintText: 'Paste curl command here...',
        showCopyButton: false,
      ),
    );
  }

  Widget _buildUnifiedGridContent() {
    return Column(
      children: [
        _buildParamsEditor(),
        const SizedBox(height: 32),
        _buildHeadersEditor(),
        const SizedBox(height: 32),
        _buildBodySection(),
      ],
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJsonBodyHeader(),
        const SizedBox(height: 16),
        _buildGridEditor(),
      ],
    );
  }


  Widget _buildJsonBodyHeader() {
    return Text(
      'JSON Body',
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }


  Widget _buildParamsEditor() {
    final state = ref.read(curlRequesterProvider); // Use read here as parent already watches
    final notifier = ref.read(curlRequesterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Query Parameters',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        SqaCard(
          child: Column(
            children: [
              ...state.currentCommand.queryParameters.entries.map((entry) {
                return Column(
                  key: ValueKey('param_${entry.key}'),
                  children: [
                    CurlRequesterGridRow(
                      label: entry.key,
                      value: entry.value,
                      isActive: !state.currentCommand.inactiveQueryParameters.contains(entry.key),
                      onChanged: (k, v) {
                        notifier.updateQueryParam(entry.key, k, v);
                        _syncRawFromState();
                      },
                      onToggle: (isActive) {
                        notifier.toggleQueryParam(entry.key, isActive);
                        _syncRawFromState();
                      },
                      onDelete: () {
                        notifier.removeQueryParam(entry.key);
                        _syncRawFromState();
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
              _buildAddRowButton(onPressed: () {
                notifier.addQueryParam();
                _syncRawFromState();
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddRowButton({required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SqaHoverIconButton(
          icon: Symbols.add,
          onPressed: onPressed,
          tooltip: 'Add new row',
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildHeadersEditor() {
    final state = ref.read(curlRequesterProvider); // Use read here as parent already watches
    final notifier = ref.read(curlRequesterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Headers',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        SqaCard(
          child: Column(
            children: [
              ...state.currentCommand.headers.entries.map((entry) {
                return Column(
                  key: ValueKey('header_${entry.key}'),
                  children: [
                    CurlRequesterGridRow(
                      label: entry.key,
                      value: entry.value,
                      isActive: !state.currentCommand.inactiveHeaders.contains(entry.key),
                      onChanged: (k, v) {
                        notifier.updateHeader(entry.key, k, v);
                        _syncRawFromState();
                      },
                      onToggle: (isActive) {
                        notifier.toggleHeader(entry.key, isActive);
                        _syncRawFromState();
                      },
                      onDelete: () {
                        notifier.removeHeader(entry.key);
                        _syncRawFromState();
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
              _buildAddRowButton(onPressed: () {
                notifier.addHeader();
                _syncRawFromState();
              }),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildGridEditor() {
    final state = ref.read(curlRequesterProvider);
    final body = state.currentCommand.body;
    
    if (body.isEmpty) {
      return const SqaCard(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: Text('No JSON body provided')),
        ),
      );
    }

    try {
      final json = jsonDecode(body);
      return SqaCard(
        child: Column(
          children: _buildJsonRows(json),
        ),
      );
    } catch (e) {
      return SqaCard(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                const Icon(Symbols.error_outline, color: Colors.orange, size: 24),
                const SizedBox(height: 8),
                Text('Invalid JSON: ${e.toString()}', 
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }
  }

  List<Widget> _buildJsonRows(dynamic json, {int depth = 0, List<dynamic> path = const []}) {
    final widgets = <Widget>[];
    final notifier = ref.read(curlRequesterProvider.notifier);

    void updateJsonValue(List<dynamic> targetPath, String newValue) {
      final body = ref.read(curlRequesterProvider).currentCommand.body;
      try {
        final decoded = jsonDecode(body);
        
        // Traverse to the parent of the target node
        dynamic current = decoded;
        for (int i = 0; i < targetPath.length - 1; i++) {
          current = current[targetPath[i]];
        }
        
        final lastKey = targetPath.last;
        final oldValue = current[lastKey];
        
        // Simple type inference for the new value
        dynamic typedValue = newValue;
        if (oldValue is num) typedValue = num.tryParse(newValue) ?? newValue;
        if (oldValue is bool) typedValue = newValue.toLowerCase() == 'true';
        
        current[lastKey] = typedValue;
        
        notifier.updateBody(jsonEncode(decoded));
        _syncRawFromState();
      } catch (_) {}
    }

    if (json is Map) {
      for (var entry in json.entries) {
        final key = entry.key.toString();
        final val = entry.value;
        final currentPath = [...path, key];

        if (val is Map || val is List) {
          widgets.add(
            CurlRequesterGridRow(
              key: ValueKey('json_${currentPath.join('_')}'),
              label: key,
              value: val is Map ? '{...}' : '[...]',
              depth: depth,
              isParent: true,
              showCheckbox: false,
              readOnlyValue: true,
            ),
          );
          widgets.add(const Divider(height: 1, indent: 16, endIndent: 16));
          widgets.addAll(_buildJsonRows(val, depth: depth + 1, path: currentPath));
        } else {
          widgets.add(
            CurlRequesterGridRow(
              key: ValueKey('json_${currentPath.join('_')}'),
              label: key,
              value: val.toString(),
              depth: depth,
              showCheckbox: false,
              onChanged: (_, v) => updateJsonValue(currentPath, v),
            ),
          );
          widgets.add(const Divider(height: 1, indent: 16, endIndent: 16));
        }
      }
    } else if (json is List) {
      for (int i = 0; i < json.length; i++) {
        final val = json[i];
        final key = '[$i]';
        final currentPath = [...path, i];

        if (val is Map || val is List) {
          widgets.add(
            CurlRequesterGridRow(
              label: key,
              value: val is Map ? '{...}' : '[...]',
              depth: depth,
              isParent: true,
              showCheckbox: false,
              readOnlyValue: true,
            ),
          );
          widgets.add(const Divider(height: 1, indent: 16, endIndent: 16));
          widgets.addAll(_buildJsonRows(val, depth: depth + 1, path: currentPath));
        } else {
          widgets.add(
            CurlRequesterGridRow(
              label: key,
              value: val.toString(),
              depth: depth,
              showCheckbox: false,
              onChanged: (_, v) => updateJsonValue(currentPath, v),
            ),
          );
          widgets.add(const Divider(height: 1, indent: 16, endIndent: 16));
        }
      }
    }

    return widgets;
  }


  // TODO(Refactor): Extract into ui/tabs/history_tab.dart
  Widget _buildHistoryTab() {
    // TODO(Logic): Bind to real transaction history from CurlRequesterState.history
    return Scrollbar(
      controller: _historyScrollController,
      child: ListView.separated(
        controller: _historyScrollController,
        padding: const EdgeInsets.all(24),
        itemCount: 5, // TODO(Logic): Use real history length
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // TODO(Logic): Get real CurlTransaction from history list
          return InkWell(
            onTap: () => _showResponseModal(context, isHistory: true),
            borderRadius: SqaStyles.radiusLarge,
            child: SqaCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // TODO(Logic): Display real status code and latency metadata
                      const SqaStatusBadge(text: '200 OK', color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        'POST /v1/users', // TODO(Logic): Display real method and path
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '2 mins ago', // TODO(Logic): Calculate real relative timestamp
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      // TODO(Logic): Provide real stringified cURL snippet for history item
                      'curl -X POST "https://api.example.com/v1/users" -H "Content-Type: application/json" -d \'{"name": "John Doe"}\'',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // TODO(Refactor): Extract into ui/modals/transaction_inspector_modal.dart
  Future<void> _showResponseModal(
    BuildContext context, {
    bool isHistory = false,
  }) async {
    // TODO(Logic): Accept a CurlTransaction parameter to display real data

    // Reset modal tab to response when opening
    setState(() => _modalTab = ModalTab.response);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SqaModal<bool>.custom(
              title: isHistory ? 'Transaction Inspector' : 'Response',
              leading: const SqaStatusBadge(
                text: '200 OK', // TODO(Logic): Dynamic status badge
                color: Colors.green,
              ),
              confirmLabel: 'Done',
              cancelLabel: 'Send Again',
              topBar: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const SqaMetadataItem(
                            icon: Symbols.timer,
                            text: '1,245.82 ms', // TODO(Logic): Dynamic latency display
                          ),
                          const SizedBox(width: 12),
                          const SqaMetadataItem(
                            icon: Symbols.database,
                            text: '1,242.08 MB', // TODO(Logic): Dynamic response size display
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isHistory) ...[
                    const SizedBox(width: 16),
                    SqaSegmentedButton<ModalTab>(
                      stretches: false,
                      minScale: 0.8,
                      segments: const [
                        ButtonSegment(
                          value: ModalTab.request,
                          label: Text('REQ'),
                          icon: Icon(Symbols.send, size: 14),
                        ),
                        ButtonSegment(
                          value: ModalTab.response,
                          label: Text('RES'),
                          icon: Icon(Symbols.data_object, size: 14),
                        ),
                      ],
                      selected: {_modalTab},
                      onSelectionChanged: (v) {
                        setModalState(() => _modalTab = v.first);
                        setState(() => _modalTab = v.first);
                      },
                    ),
                  ],
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  minWidth: MediaQuery.of(context).size.width * 0.85 > 800
                      ? 800
                      : MediaQuery.of(context).size.width * 0.85,
                  maxWidth: 800,
                ),
                child: _modalTab == ModalTab.request
                    ? _buildRequestModalContent()
                    : _buildResponseContent(),
              ),
            );
          },
        );
      },
    );

    // If "Send Again" (Cancel button) was pressed, re-trigger the modal
    if (result == false) {
      if (context.mounted) {
        // TODO(Logic): Re-execute the request before showing the modal again
        _showResponseModal(context);
      }
    }
  }

  Widget _buildRequestModalContent() {
    return const SqaField(
      label: 'cURL Command',
      showLabel: false,
      isMonospace: true,
      readOnly: true,
      isMultiline: true,
      maxLines: 40,
      fontSize: 12,
      showCopyButton: true,
      initialValue:
          'curl -X POST "https://api.example.com/v1/users" \\\n  -H "Accept: application/json" \\\n  -H "Content-Type: application/json" \\\n  -d \'{"name": "John Doe", "email": "john@example.com"}\'',
      // TODO(Logic): Provide real request cURL string
    );
  }

  Widget _buildResponseContent() {
    return const SqaField(
      label: 'Response Output',
      showLabel: false,
      isMonospace: true,
      readOnly: true,
      isMultiline: true,
      maxLines: 40,
      fontSize: 12,
      showCopyButton: true,
      initialValue:
          '{\n  "status": "success",\n  "data": {\n    "id": 101,\n    "title": "foo",\n    "body": "bar",\n    "userId": 1\n  }\n}',
      // TODO(Logic): Provide real response body string
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      ref.read(curlRequesterProvider.notifier).updateFromCurl(data.text!);
      
      // Update controllers from the new state
      final newState = ref.read(curlRequesterProvider);
      _urlController.text = newState.currentCommand.url;
      _curlController.text = CurlParserService.stringify(newState.currentCommand);
    }
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
}

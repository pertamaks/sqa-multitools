import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/curl_requester_provider.dart';
import '../../services/curl_parser_service.dart';
import '../components/curl_requester_grid_row.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';

class RequestTab extends ConsumerWidget {
  final ScrollController scrollController;
  final TextEditingController urlController;
  final TextEditingController curlController;
  final bool showReflector;
  final VoidCallback onToggleReflector;
  final VoidCallback onPasteFromClipboard;
  final VoidCallback onClearRequest;
  final VoidCallback onSyncRaw;

  const RequestTab({
    super.key,
    required this.scrollController,
    required this.urlController,
    required this.curlController,
    required this.showReflector,
    required this.onToggleReflector,
    required this.onPasteFromClipboard,
    required this.onClearRequest,
    required this.onSyncRaw,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildRequestHeader(context),
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  showReflector
                      ? _buildUnifiedGridContent(context, ref)
                      : _buildCommandDeckContent(context),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                showReflector ? Symbols.grid_3x3 : Symbols.terminal,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                showReflector ? 'Structured Request' : 'Command Deck (cURL)',
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
                icon: showReflector ? Symbols.terminal : Symbols.grid_3x3,
                onPressed: onToggleReflector,
                tooltip: showReflector ? 'Switch to Command' : 'Show Grid',
                iconSize: 18,
              ),
              const SizedBox(width: 8),
              SqaHoverIconButton(
                icon: Symbols.content_paste,
                onPressed: onPasteFromClipboard,
                tooltip: 'Paste from Clipboard',
                iconSize: 18,
              ),
              const SizedBox(width: 8),
              SqaHoverIconButton(
                icon: Symbols.delete_sweep,
                onPressed: onClearRequest,
                tooltip: 'Clear Request',
                iconSize: 18,
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommandDeckContent(BuildContext context) {
    return SqaCard(
      padding: const EdgeInsets.all(16),
      child: SqaField(
        label: '',
        showLabel: false,
        controller: curlController,
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

  Widget _buildUnifiedGridContent(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildParamsEditor(context, ref),
        const SizedBox(height: 32),
        _buildHeadersEditor(context, ref),
        const SizedBox(height: 32),
        _buildBodySection(context, ref),
      ],
    );
  }

  Widget _buildBodySection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'JSON Body',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 16),
        _buildGridEditor(context, ref),
      ],
    );
  }

  Widget _buildParamsEditor(BuildContext context, WidgetRef ref) {
    final state = ref.watch(curlRequesterProvider);
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
                      isActive: !state.currentCommand.inactiveQueryParameters
                          .contains(entry.key),
                      onChanged: (k, v) {
                        notifier.updateQueryParam(entry.key, k, v);
                        onSyncRaw();
                      },
                      onToggle: (isActive) {
                        notifier.toggleQueryParam(entry.key, isActive);
                        onSyncRaw();
                      },
                      onDelete: () {
                        notifier.removeQueryParam(entry.key);
                        onSyncRaw();
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
              _buildAddRowButton(
                context,
                onPressed: () {
                  notifier.addQueryParam();
                  onSyncRaw();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeadersEditor(BuildContext context, WidgetRef ref) {
    final state = ref.watch(curlRequesterProvider);
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
                      isActive:
                          !state.currentCommand.inactiveHeaders.contains(entry.key),
                      onChanged: (k, v) {
                        notifier.updateHeader(entry.key, k, v);
                        onSyncRaw();
                      },
                      onToggle: (isActive) {
                        notifier.toggleHeader(entry.key, isActive);
                        onSyncRaw();
                      },
                      onDelete: () {
                        notifier.removeHeader(entry.key);
                        onSyncRaw();
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }),
              _buildAddRowButton(
                context,
                onPressed: () {
                  notifier.addHeader();
                  onSyncRaw();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddRowButton(BuildContext context, {required VoidCallback onPressed}) {
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

  Widget _buildGridEditor(BuildContext context, WidgetRef ref) {
    final state = ref.watch(curlRequesterProvider);
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
          children: _buildJsonRows(context, ref, json),
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

  List<Widget> _buildJsonRows(BuildContext context, WidgetRef ref, dynamic json,
      {int depth = 0, List<dynamic> path = const []}) {
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
        onSyncRaw();
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
          widgets.addAll(_buildJsonRows(context, ref, val,
              depth: depth + 1, path: currentPath));
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
          widgets.addAll(_buildJsonRows(context, ref, val,
              depth: depth + 1, path: currentPath));
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
}

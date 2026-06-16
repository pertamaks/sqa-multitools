import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/curl_requester_provider.dart';

import '../../models/curl_command.dart';
import '../components/curl_requester_grid_row.dart';
import '../components/auth_editor.dart';
import '../components/form_data_editor.dart';
import '../components/curl_variable_info_button.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';

class RequestTab extends ConsumerStatefulWidget {
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
  ConsumerState<RequestTab> createState() => _RequestTabState();
}

class _RequestTabState extends ConsumerState<RequestTab> {
  bool _isClearing = false;
  bool _isPasting = false;

  void _handleClear() {
    final hasData = widget.urlController.text.isNotEmpty || 
                    widget.curlController.text.isNotEmpty;
    
    if (!hasData || _isClearing) {
      widget.onClearRequest();
      setState(() => _isClearing = false);
    } else {
      setState(() => _isClearing = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isClearing) {
          setState(() => _isClearing = false);
        }
      });
    }
  }

  void _handlePaste() {
    final hasData = widget.urlController.text.isNotEmpty || 
                    widget.curlController.text.isNotEmpty;

    if (!hasData || _isPasting) {
      widget.onPasteFromClipboard();
      setState(() => _isPasting = false);
    } else {
      setState(() => _isPasting = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isPasting) {
          setState(() => _isPasting = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRequestHeader(context),
        Expanded(
          child: widget.showReflector
              ? Scrollbar(
                  controller: widget.scrollController,
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(SqaTokens.contentPaddingHorizontal),
                    child: _buildUnifiedGridContent(context, ref),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SqaTokens.contentPaddingHorizontal,
                    SqaTokens.spacingMedium,
                    SqaTokens.contentPaddingHorizontal,
                    SqaTokens.spacingLarge,
                  ),
                  child: _buildCommandDeckContent(context),
                ),
        ),
      ],
    );
  }

  Widget _buildRequestHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        SqaTokens.contentPaddingHorizontal,
        SqaTokens.spacingMedium,
        SqaTokens.contentPaddingHorizontal,
        SqaTokens.spacingMedium,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                widget.showReflector ? Symbols.grid_3x3 : Symbols.terminal,
                size: SqaTokens.spacingLarge + 2,
              ),
              const SizedBox(width: SqaTokens.spacingSmall),
              Text(
                widget.showReflector ? 'STRUCTURED REQUEST' : 'COMMAND DECK (CURL)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      fontSize: SqaTokens.fontSizeSmall,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),

            ],
          ),
          Row(
            children: [
              SqaHoverIconButton(
                icon: widget.showReflector ? Symbols.terminal : Symbols.grid_3x3,
                onPressed: widget.onToggleReflector,
                tooltip: widget.showReflector ? 'Switch to Command' : 'Show Grid',
                iconSize: SqaTokens.spacingLarge + 2,
              ),
              const SizedBox(width: SqaTokens.spacingSmall),
              SqaHoverIconButton(
                icon: Symbols.content_paste,
                onPressed: _handlePaste,
                tooltip: _isPasting ? 'Click again to overwrite' : 'Paste from Clipboard',
                iconSize: SqaTokens.spacingLarge + 2,
                color: _isPasting 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(width: SqaTokens.spacingSmall),
              SqaHoverIconButton(
                icon: Symbols.delete_sweep,
                onPressed: _handleClear,
                tooltip: _isClearing ? 'Click again to confirm' : 'Clear Request',
                iconSize: SqaTokens.spacingLarge + SqaTokens.spacingTiny,
                color: _isClearing 
                    ? Theme.of(context).colorScheme.error 
                    : Colors.grey.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildCommandDeckContent(BuildContext context) {
    return SizedBox.expand(
      child: SqaField(
        label: '',
        showLabel: false,
        controller: widget.curlController,
        isMonospace: true,
        isMultiline: true,
        maxLines: null,
        expands: true,
        fontSize: SqaTokens.spacingMedium,
        hintText: 'Paste curl command here...',
        showCopyButton: false,
        showLineNumbers: true,
        extraFloatingButtonBuilder: (ctrl) => CurlVariableInfoButton(controller: ctrl),
      ),
    );
  }

  Widget _buildUnifiedGridContent(BuildContext context, WidgetRef ref) {
    final state = ref.watch(curlRequesterProvider);
    final hasPathParams = state.currentCommand.pathParameters.isNotEmpty;

    return Column(
      children: [
        if (hasPathParams) ...[
          _buildPathParamsEditor(context, ref),
          const SizedBox(height: SqaTokens.spacingXXLarge),
        ],
        _buildParamsEditor(context, ref),
        const SizedBox(height: SqaTokens.spacingXXLarge),
        _buildHeadersEditor(context, ref),
        const SizedBox(height: SqaTokens.spacingXXLarge),
        AuthEditor(onSyncRaw: widget.onSyncRaw),
        const SizedBox(height: SqaTokens.spacingXXLarge),
        _buildBodySection(context, ref),
      ],
    );
  }

  Widget _buildBodySection(BuildContext context, WidgetRef ref) {
    final state = ref.watch(curlRequesterProvider);
    final command = state.currentCommand;
    final notifier = ref.read(curlRequesterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'BODY',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: SqaTokens.fontSizeSmall,
                  ),
            ),
            SqaPopupMenu(
              icon: Symbols.arrow_drop_down,
              builder: (context, controller, child) {
                String currentLabel = command.bodyType.name;
                if (command.bodyType == BodyType.none) currentLabel = 'None';
                if (command.bodyType == BodyType.raw) currentLabel = 'Raw Text';
                if (command.bodyType == BodyType.json) currentLabel = 'JSON (Structured)';
                if (command.bodyType == BodyType.urlEncoded) currentLabel = 'x-www-form-urlencoded';
                if (command.bodyType == BodyType.multipartFormData) currentLabel = 'multipart/form-data';
                if (command.bodyType == BodyType.binaryFile) currentLabel = 'Binary File';
                
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
                    padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingXSmall, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(currentLabel, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Symbols.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                );
              },
              children: BodyType.values.map((t) {
                String label = t.name;
                if (t == BodyType.none) label = 'None';
                if (t == BodyType.raw) label = 'Raw Text';
                if (t == BodyType.json) label = 'JSON (Structured)';
                if (t == BodyType.urlEncoded) label = 'x-www-form-urlencoded';
                if (t == BodyType.multipartFormData) label = 'multipart/form-data';
                if (t == BodyType.binaryFile) label = 'Binary File';
                
                return SqaPopupMenuItem(
                  onPressed: () {
                    notifier.updateCommand(command.copyWith(bodyType: t));
                    widget.onSyncRaw();
                  },
                  icon: const Icon(Symbols.short_text, size: 16),
                  label: label,
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
        if (command.bodyType == BodyType.json)
          _buildGridEditor(context, ref)
        else if (command.bodyType == BodyType.multipartFormData)
          FormDataEditor(onSyncRaw: widget.onSyncRaw, isUrlEncoded: false)
        else if (command.bodyType == BodyType.urlEncoded)
          FormDataEditor(onSyncRaw: widget.onSyncRaw, isUrlEncoded: true)
        else if (command.bodyType == BodyType.binaryFile)
          SqaCard(
            child: Row(
              children: [
                Expanded(
                  child: SqaField(
                    label: 'File Path',
                    initialValue: command.body,
                    isMonospace: true,
                    onChanged: (val) {
                      notifier.updateCommand(command.copyWith(body: val));
                      widget.onSyncRaw();
                    },
                    showCopyButton: false,
                    fontSize: SqaTokens.spacingMedium,
                  ),
                ),
                const SizedBox(width: SqaTokens.spacingSmall),
                SqaButton(
                  label: 'Browse',
                  icon: Symbols.folder_open,
                  type: SqaButtonType.tonal,
                  onPressed: () async {
                    const XTypeGroup typeGroup = XTypeGroup(label: 'All Files');
                    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
                    if (file != null) {
                      notifier.updateCommand(command.copyWith(body: '@${file.path}'));
                      widget.onSyncRaw();
                    }
                  },
                ),
              ],
            ),
          )
        else if (command.bodyType == BodyType.raw)
          SqaCard(
            child: SqaField(
              label: '',
              showLabel: false,
              initialValue: command.body,
              isMonospace: true,
              highlightVariables: true,
              isMultiline: true,
              maxLines: 8,
              minLines: 4,
              fontSize: SqaTokens.spacingMedium,
              hintText: 'Enter raw body payload...',
              showCopyButton: false,
              extraFloatingButtonBuilder: (ctrl) => CurlVariableInfoButton(controller: ctrl),
              onChanged: (v) {
                notifier.updateCommand(command.copyWith(body: v));
                widget.onSyncRaw();
              },
            ),
          )
        else
          const SqaCard(
            child: Padding(
              padding: EdgeInsets.all(SqaTokens.spacingXXLarge),
              child: Center(child: Text('This request does not have a body.')),
            ),
          ),
      ],
    );
  }

  Widget _buildPathParamsEditor(BuildContext context, WidgetRef ref) {
    final state = ref.watch(curlRequesterProvider);
    final notifier = ref.read(curlRequesterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PATH VARIABLES',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.primary,
                fontSize: SqaTokens.fontSizeSmall,
              ),
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
        SqaCard(
          child: Column(
            children: [
              ...state.currentCommand.pathParameters.entries.map((entry) {
                return Column(
                  key: ValueKey('path_param_${entry.key}'),
                  children: [
                    CurlRequesterGridRow(
                      label: entry.key,
                      value: entry.value,
                      isActive: !state.currentCommand.inactivePathParameters
                          .contains(entry.key),
                      onChanged: (k, v) {
                        notifier.updatePathParam(entry.key, k, v);
                        widget.onSyncRaw();
                      },
                      onToggle: (isActive) {
                        notifier.togglePathParam(entry.key, isActive);
                        widget.onSyncRaw();
                      },
                      onDelete: () {
                        notifier.removePathParam(entry.key);
                        widget.onSyncRaw();
                      },
                    ),
                    const Divider(height: 1, indent: SqaTokens.spacingLarge, endIndent: SqaTokens.spacingLarge),
                  ],
                );
              }),
              _buildAddRowButton(
                context,
                onPressed: () {
                  notifier.addPathParam();
                  widget.onSyncRaw();
                },
              ),
            ],
          ),
        ),
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
          'QUERY PARAMETERS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.primary,
                fontSize: SqaTokens.fontSizeSmall,
              ),
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
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
                        widget.onSyncRaw();
                      },
                      onToggle: (isActive) {
                        notifier.toggleQueryParam(entry.key, isActive);
                        widget.onSyncRaw();
                      },
                      onDelete: () {
                        notifier.removeQueryParam(entry.key);
                        widget.onSyncRaw();
                      },
                    ),
                    const Divider(height: 1, indent: SqaTokens.spacingLarge, endIndent: SqaTokens.spacingLarge),
                  ],
                );
              }),
              _buildAddRowButton(
                context,
                onPressed: () {
                  notifier.addQueryParam();
                  widget.onSyncRaw();
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
          'HEADERS',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                color: Theme.of(context).colorScheme.primary,
                fontSize: SqaTokens.fontSizeSmall,
              ),
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
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
                        widget.onSyncRaw();
                      },
                      onToggle: (isActive) {
                        notifier.toggleHeader(entry.key, isActive);
                        widget.onSyncRaw();
                      },
                      onDelete: () {
                        notifier.removeHeader(entry.key);
                        widget.onSyncRaw();
                      },
                    ),
                    const Divider(height: 1, indent: SqaTokens.spacingLarge, endIndent: SqaTokens.spacingLarge),
                  ],
                );
              }),
              _buildAddRowButton(
                context,
                onPressed: () {
                  notifier.addHeader();
                  widget.onSyncRaw();
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
      padding: const EdgeInsets.all(SqaTokens.spacingSmall),
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
          padding: EdgeInsets.all(SqaTokens.spacingXXLarge),
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
          padding: const EdgeInsets.all(SqaTokens.spacingXXLarge),
          child: Center(
            child: Column(
              children: [
                const Icon(Symbols.error_outline, color: Colors.orange, size: SqaTokens.spacingXXLarge),
                const SizedBox(height: SqaTokens.spacingSmall),
                Text('Invalid JSON: ${e.toString()}',
                    style: const TextStyle(fontSize: SqaTokens.fontSizeSmall, color: Colors.grey)),
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
        widget.onSyncRaw();
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
          widgets.add(const Divider(height: 1, indent: SqaTokens.spacingLarge, endIndent: SqaTokens.spacingLarge));
        }
      }
    }

    return widgets;
  }
}

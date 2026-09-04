import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../curl_requester/providers/curl_requester_provider.dart';
import '../../../../core/providers/plugin_provider.dart';
import '../providers/swagger_provider.dart';
import '../models/swagger_state.dart';
import '../providers/swagger_curl_service.dart';
import 'swagger_authorize_dialog.dart';
import 'dart:convert';

class SwaggerDetailView extends ConsumerWidget {
  const SwaggerDetailView({super.key});

  static final swaggerEndpointsKey = GlobalKey(debugLabel: 'swagger.endpoints');

  static Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return const Color(0xFF61AFFE);
      case 'POST':
        return const Color(0xFF49CC90);
      case 'PUT':
        return const Color(0xFFFCA130);
      case 'DELETE':
        return const Color(0xFFF93E3E);
      case 'PATCH':
        return const Color(0xFF50E3C2);
      default:
        return Colors.grey;
    }
  }

  void _sendToCurl(
    BuildContext context,
    WidgetRef ref,
    SwaggerEndpoint endpoint,
    SwaggerSchemaInfo schema,
  ) {
    final command = ref
        .read(swaggerCurlServiceProvider)
        .generateCommand(
          endpoint,
          schema,
          ref.read(swaggerProvider).activeSecurityValues,
        );

    // 1. Send to Curl Requester Provider
    ref.read(curlRequesterProvider.notifier).updateCommand(command);

    // 2. Switch plugin with back navigation history
    ref
        .read(navigationHistoryProvider.notifier)
        .setHistory('com.sqa.plugin.swagger_explorer');

    final allPlugins = ref.read(availablePluginsProvider);
    final curlPlugin = allPlugins
        .where((p) => p.id == 'com.sqa.plugin.curl_requester')
        .firstOrNull;
    if (curlPlugin == null) return;

    ref.read(activePluginProvider.notifier).setPlugin(curlPlugin);
  }

  bool _isEndpointAuthorized(
    SwaggerEndpoint endpoint,
    SwaggerSchemaInfo schema,
    Map<String, String> activeValues,
  ) {
    final securityList = endpoint.security ?? schema.security;
    if (securityList.isEmpty) return true;

    for (final req in securityList) {
      if (req.isEmpty) return true;
      bool allSatisfied = true;
      for (final key in req.keys) {
        if (activeValues[key] == null || activeValues[key]!.isEmpty) {
          allSatisfied = false;
          break;
        }
      }
      if (allSatisfied) return true;
    }
    return false;
  }

  Widget _buildParameter(ThemeData theme, Map<String, dynamic> param) {
    final name = (param['name'] ?? '').toString();
    final inLoc = (param['in'] ?? '').toString();
    final required = param['required'] == true;
    final schema =
        param['schema'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final type = (schema['type'] ?? 'string').toString();
    final desc = (param['description'] ?? '').toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  inLoc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 12,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (required) ...[
                      const SizedBox(width: 8),
                      Text(
                        'required',
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestBody(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    Map<String, dynamic> body,
  ) {
    final content = body['content'] as Map<String, dynamic>?;
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    final type = content.keys.first;
    final schema =
        content[type]?['schema'] as Map<String, dynamic>? ??
        <String, dynamic>{};

    // Attempt to generate a clean example payload instead of raw schema dump
    final parsedExample = ref
        .read(swaggerCurlServiceProvider)
        .generateExampleFromSchema(schema);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Request Body',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: SqaTokens.spacingSmall),
        Text(
          type,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: SqaTokens.spacingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SqaTokens.spacingMedium),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: SqaTokens.borderRadiusSmall,
          ),
          child: Text(
            const JsonEncoder.withIndent('  ').convert(parsedExample),
            style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12),
          ),
        ),
        const SizedBox(height: SqaTokens.spacingLarge),
      ],
    );
  }

  Widget _buildResponses(ThemeData theme, Map<String, dynamic> responses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Responses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
        for (final entry in responses.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    ((entry.value as Map<String, dynamic>?)?['description'] ??
                            '')
                        .toString(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(swaggerProvider);
    final schema = state.activeSchema;

    if (schema == null) {
      return const SizedBox.shrink();
    }

    // Group endpoints by tag
    final grouped = <String, List<SwaggerEndpoint>>{};
    for (final ep in schema.endpoints) {
      final tag = ep.tags.isNotEmpty ? ep.tags.first : 'Default';
      grouped.putIfAbsent(tag, () => []).add(ep);
    }

    return SqaPluginLayout(
      title: schema.title,
      onBack: () {
        ref.read(swaggerProvider.notifier).setViewMode(SwaggerViewMode.list);
      },
      trailing: schema.securitySchemes.isNotEmpty
          ? SqaButton(
              label: 'Authorize',
              icon: state.activeSecurityValues.isNotEmpty
                  ? Symbols.lock
                  : Symbols.lock_open,
              type: state.activeSecurityValues.isNotEmpty
                  ? SqaButtonType.primary
                  : SqaButtonType.tonal,
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => const SwaggerAuthorizeDialog(),
                );
              },
            )
          : null,
      child: SqaPluginScrollableContent(
        key: SwaggerDetailView.swaggerEndpointsKey,
        center: false,
        padding: const EdgeInsets.symmetric(
          horizontal: SqaTokens.contentPaddingHorizontal,
          vertical: SqaTokens.contentPaddingVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (schema.description != null &&
                schema.description!.isNotEmpty) ...[
              Text(schema.description!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: SqaTokens.spacingLarge),
            ],
            for (final tag in grouped.keys)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SqaTokens.spacingMedium,
                    ),
                    child: Text(
                      tag.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  ...grouped[tag]!.map((ep) {
                    final methodColor = _getMethodColor(ep.method);
                    return SqaCard(
                      margin: const EdgeInsets.only(
                        bottom: SqaTokens.spacingMedium,
                      ),
                      padding: EdgeInsets.zero,
                      child: Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          key: PageStorageKey(
                            'swagger_ep_${ep.method}_${ep.path}',
                          ),
                          title: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: methodColor.withValues(alpha: 0.1),
                                  borderRadius: SqaTokens.borderRadiusSmall,
                                  border: Border.all(color: methodColor),
                                ),
                                width: 70,
                                alignment: Alignment.center,
                                child: Text(
                                  ep.method,
                                  style: TextStyle(
                                    color: methodColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: SqaTokens.spacingMedium),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      ep.path,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'JetBrains Mono',
                                        fontSize: 13,
                                      ),
                                    ),
                                    if (ep.summary.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        ep.summary,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SqaButton(
                                label: '',
                                tooltip: 'Send to cURL Requester',
                                icon: Symbols.rocket_launch,
                                type: SqaButtonType.tonal,
                                onPressed: () =>
                                    _sendToCurl(context, ref, ep, schema),
                              ),
                              const SizedBox(width: SqaTokens.spacingSmall),
                              if ((ep.security ?? schema.security).isNotEmpty &&
                                  !(ep.security ?? schema.security).any(
                                    (req) => req.isEmpty,
                                  ))
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: SqaTokens.spacingMedium,
                                  ),
                                  child: Icon(
                                    _isEndpointAuthorized(
                                          ep,
                                          schema,
                                          state.activeSecurityValues,
                                        )
                                        ? Symbols.lock
                                        : Symbols.lock_open,
                                    size: 16,
                                    color:
                                        _isEndpointAuthorized(
                                          ep,
                                          schema,
                                          state.activeSecurityValues,
                                        )
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(
                                SqaTokens.spacingLarge,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (state.isLoading)
                                    const LinearProgressIndicator(),
                                  if (ep.parameters != null &&
                                      ep.parameters!.isNotEmpty) ...[
                                    Text(
                                      'Parameters',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: SqaTokens.spacingMedium,
                                    ),
                                    ...ep.parameters!.map(
                                      (p) => _buildParameter(theme, p),
                                    ),
                                    const SizedBox(
                                      height: SqaTokens.spacingMedium,
                                    ),
                                  ],
                                  if (ep.requestBody != null)
                                    _buildRequestBody(
                                      context,
                                      ref,
                                      theme,
                                      ep.requestBody!,
                                    ),
                                  if (ep.responses != null &&
                                      ep.responses!.isNotEmpty) ...[
                                    _buildResponses(theme, ep.responses!),
                                    const SizedBox(
                                      height: SqaTokens.spacingLarge,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: SqaTokens.spacingLarge),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

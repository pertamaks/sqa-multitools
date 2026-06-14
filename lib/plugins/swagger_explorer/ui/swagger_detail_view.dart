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
import 'dart:convert';

class SwaggerDetailView extends ConsumerWidget {
  const SwaggerDetailView({super.key});

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET': return const Color(0xFF61AFFE);
      case 'POST': return const Color(0xFF49CC90);
      case 'PUT': return const Color(0xFFFCA130);
      case 'DELETE': return const Color(0xFFF93E3E);
      case 'PATCH': return const Color(0xFF50E3C2);
      default: return Colors.grey;
    }
  }

  void _sendToCurl(BuildContext context, WidgetRef ref, SwaggerEndpoint endpoint, SwaggerSchemaInfo schema) {
    final baseUrl = schema.baseUrl ?? 'http://localhost:8080';
    var url = endpoint.path;
    
    final queryParams = <String, String>{};
    final headers = <String, String>{'Accept': 'application/json'};
    final formFields = <String, String>{};
    String rawBody = '';
    
    // Process Parameters
    if (endpoint.parameters != null && endpoint.parameters!['raw'] != null) {
      for (final p in endpoint.parameters!['raw'] as List) {
        if (p is! Map) continue;
        final name = p['name']?.toString() ?? '';
        final inLoc = p['in']?.toString() ?? '';
        
        // Generate a dummy value
        dynamic val = p['example'] ?? p['schema']?['example'] ?? p['schema']?['default'];
        if (val == null) {
          final type = p['type'] ?? p['schema']?['type'] ?? 'string';
          if (type == 'integer' || type == 'number') val = '0';
          else if (type == 'boolean') val = 'true';
          else if (type == 'file') val = '@dummy_file.txt';
          else val = 'string';
        }
        final valStr = val.toString();

        if (inLoc == 'query') {
          queryParams[name] = valStr;
        } else if (inLoc == 'header') {
          headers[name] = valStr;
        } else if (inLoc == 'path') {
          url = url.replaceAll('{$name}', valStr);
        } else if (inLoc == 'formData') {
          formFields[name] = valStr;
          if (!headers.containsKey('Content-Type')) {
            headers['Content-Type'] = (valStr.startsWith('@')) ? 'multipart/form-data' : 'application/x-www-form-urlencoded';
          }
        }
      }
    }

    // Process Request Body
    if (endpoint.requestBody != null) {
      final content = endpoint.requestBody!['content'] as Map<String, dynamic>?;
      if (content != null) {
        if (content.containsKey('application/json')) {
          headers['Content-Type'] = 'application/json';
          final bodySchema = content['application/json']['schema'];
          final parsedExample = _generateExampleFromSchema(bodySchema ?? {});
          if ((parsedExample is Map && parsedExample.isNotEmpty) || (parsedExample is List && parsedExample.isNotEmpty)) {
            rawBody = const JsonEncoder.withIndent('  ').convert(parsedExample);
          }
        } else if (content.containsKey('application/x-www-form-urlencoded')) {
          headers['Content-Type'] = 'application/x-www-form-urlencoded';
          final bodySchema = content['application/x-www-form-urlencoded']['schema'];
          final parsedExample = _generateExampleFromSchema(bodySchema ?? {});
          if (parsedExample is Map) {
            parsedExample.forEach((k, v) => formFields[k] = v.toString());
          }
        } else if (content.containsKey('multipart/form-data')) {
          headers['Content-Type'] = 'multipart/form-data';
          final bodySchema = content['multipart/form-data']['schema'];
          final parsedExample = _generateExampleFromSchema(bodySchema ?? {});
          if (parsedExample is Map) {
            parsedExample.forEach((k, v) {
              if (bodySchema['properties']?[k]?['type'] == 'string' && bodySchema['properties']?[k]?['format'] == 'binary') {
                formFields[k] = '@dummy_file.txt';
              } else {
                formFields[k] = v.toString();
              }
            });
          }
        }
      }
    }

    // Construct URL with query parameters
    if (queryParams.isNotEmpty) {
      final qs = queryParams.entries.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&');
      url = '$url?$qs';
    }

    // Construct cURL string
    final sb = StringBuffer();
    sb.write('curl -X ${endpoint.method} "$baseUrl$url"');
    
    for (final h in headers.entries) {
      sb.write(' \\\n  -H "${h.key}: ${h.value}"');
    }
    
    if (rawBody.isNotEmpty) {
      sb.write(' \\\n  -d \'${rawBody.replaceAll("'", "'\\''")}\'');
    } else if (formFields.isNotEmpty) {
      final isMultipart = headers['Content-Type'] == 'multipart/form-data';
      for (final f in formFields.entries) {
        if (isMultipart) {
          sb.write(' \\\n  -F "${f.key}=${f.value}"');
        } else {
          sb.write(' \\\n  -d "${f.key}=${f.value}"');
        }
      }
    }

    final curlString = sb.toString();

    // 1. Send to Curl Requester Provider
    ref.read(curlRequesterProvider.notifier).updateFromCurl(curlString);

    // 2. Switch plugin with back navigation history
    ref.read(navigationHistoryProvider.notifier).setHistory('com.sqa.plugin.swagger_explorer');
    final allPlugins = ref.read(availablePluginsProvider);
    final curlPlugin = allPlugins.firstWhere((p) => p.id == 'com.sqa.plugin.curl_requester');
    ref.read(activePluginProvider.notifier).setPlugin(curlPlugin);
  }

  Widget _buildParameter(ThemeData theme, Map<String, dynamic> param) {
    final name = param['name'] ?? '';
    final inLoc = param['in'] ?? '';
    final required = param['required'] == true;
    final schema = param['schema'] ?? {};
    final type = schema['type'] ?? 'string';
    final desc = param['description'] ?? '';

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
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono', fontSize: 13)),
                const SizedBox(height: 2),
                Text(inLoc, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ]
            )
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(type, style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: theme.colorScheme.primary)),
                    if (required) ...[
                      const SizedBox(width: 8),
                      Text('required', style: TextStyle(color: theme.colorScheme.error, fontSize: 10, fontWeight: FontWeight.bold)),
                    ]
                  ]
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc, style: theme.textTheme.bodySmall),
                ]
              ]
            )
          )
        ]
      )
    );
  }

  dynamic _generateExampleFromSchema(Map<String, dynamic> schema) {
    if (schema.containsKey('example')) return schema['example'];
    if (schema['type'] == 'object' && schema.containsKey('properties')) {
      final properties = schema['properties'] as Map<String, dynamic>;
      final example = <String, dynamic>{};
      properties.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          if (value.containsKey('example')) {
            example[key] = value['example'];
          } else if (value['type'] == 'string') {
            example[key] = 'string';
          } else if (value['type'] == 'integer' || value['type'] == 'number') {
            example[key] = 0;
          } else if (value['type'] == 'boolean') {
            example[key] = true;
          } else if (value['type'] == 'array') {
            final items = value['items'];
            if (items is Map<String, dynamic>) {
              example[key] = [_generateExampleFromSchema(items)];
            } else {
              example[key] = [];
            }
          } else if (value['type'] == 'object') {
            example[key] = _generateExampleFromSchema(value);
          } else {
            example[key] = 'unknown';
          }
        }
      });
      return example;
    } else if (schema['type'] == 'array') {
      final items = schema['items'];
      if (items is Map<String, dynamic>) {
        return [_generateExampleFromSchema(items)];
      }
      return [];
    }
    return schema;
  }

  Widget _buildRequestBody(ThemeData theme, Map<String, dynamic> body) {
    final content = body['content'] as Map<String, dynamic>?;
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    final type = content.keys.first;
    final schema = content[type]?['schema'] ?? {};
    
    // Attempt to generate a clean example payload instead of raw schema dump
    final parsedExample = _generateExampleFromSchema(schema);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Request Body', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        const SizedBox(height: SqaTokens.spacingSmall),
        Text(type, style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: SqaTokens.spacingSmall),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SqaTokens.spacingMedium),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: SqaTokens.borderRadiusSmall,
          ),
          child: Text(
            const JsonEncoder.withIndent('  ').convert(parsedExample),
            style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12)
          )
        ),
        const SizedBox(height: SqaTokens.spacingLarge),
      ]
    );
  }

  Widget _buildResponses(ThemeData theme, Map<String, dynamic> responses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Responses', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        const SizedBox(height: SqaTokens.spacingMedium),
        for (final entry in responses.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  child: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'))
                ),
                Expanded(
                  child: Text(entry.value['description'] ?? '', style: theme.textTheme.bodyMedium)
                )
              ]
            )
          )
      ]
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
      description: schema.description ?? '',
      onBack: () {
        ref.read(swaggerProvider.notifier).setViewMode(SwaggerViewMode.list);
      },
      child: SqaPluginScrollableContent(
        center: false,
        padding: const EdgeInsets.symmetric(
          horizontal: SqaTokens.contentPaddingHorizontal,
          vertical: SqaTokens.contentPaddingVertical,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final tag in grouped.keys)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: SqaTokens.spacingMedium),
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
                      margin: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
                      padding: EdgeInsets.zero,
                      child: Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                child: Text(
                                  ep.path,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'JetBrains Mono', fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          subtitle: ep.summary.isNotEmpty ? Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(ep.summary, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ) : null,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(SqaTokens.spacingLarge),
                              decoration: BoxDecoration(
                                border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5))),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (ep.parameters != null && ep.parameters!['raw'] != null && (ep.parameters!['raw'] as List).isNotEmpty) ...[
                                    Text('Parameters', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                                    const SizedBox(height: SqaTokens.spacingMedium),
                                    ...(ep.parameters!['raw'] as List).map((p) => _buildParameter(theme, p as Map<String, dynamic>)),
                                    const SizedBox(height: SqaTokens.spacingMedium),
                                  ],
                                  if (ep.requestBody != null)
                                    _buildRequestBody(theme, ep.requestBody!),
                                  if (ep.responses != null && ep.responses!.isNotEmpty) ...[
                                    _buildResponses(theme, ep.responses!),
                                    const SizedBox(height: SqaTokens.spacingLarge),
                                  ],
                                  
                                  const Divider(),
                                  const SizedBox(height: SqaTokens.spacingMedium),
                                  
                                  SqaButton(
                                    label: 'Send to cURL Requester',
                                    icon: Symbols.send,
                                    onPressed: () => _sendToCurl(context, ref, ep, schema),
                                    type: SqaButtonType.primary,
                                  ),
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

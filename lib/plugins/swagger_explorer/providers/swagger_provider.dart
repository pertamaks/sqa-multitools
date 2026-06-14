import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../models/swagger_state.dart';

final swaggerProvider = NotifierProvider<SwaggerNotifier, SwaggerState>(() {
  return SwaggerNotifier();
});

class SwaggerNotifier extends Notifier<SwaggerState> {
  @override
  SwaggerState build() => const SwaggerState();

  void setViewMode(SwaggerViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setActiveEndpoint(SwaggerEndpoint endpoint) {
    state = state.copyWith(activeEndpoint: endpoint);
  }

  Future<void> fetchFromUrl(String url) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final dio = Dio();
      final response = await dio.get(url);
      
      Map<String, dynamic> jsonMap;
      if (response.data is String) {
        jsonMap = jsonDecode(response.data);
      } else {
        jsonMap = response.data;
      }

      final schemaInfo = _parseSwaggerJson(jsonMap, sourceUrl: url);

      // Add to history
      final historyItem = SwaggerHistoryItem(
        id: const Uuid().v4(),
        name: schemaInfo.title,
        url: url,
        lastAccessed: DateTime.now(),
      );

      final newHistory = [historyItem, ...state.history];

      state = state.copyWith(
        isLoading: false,
        activeSchema: schemaInfo,
        history: newHistory,
        viewMode: SwaggerViewMode.detail,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch Swagger JSON: $e',
      );
    }
  }

  SwaggerSchemaInfo _parseSwaggerJson(Map<String, dynamic> json, {String? sourceUrl}) {
    final info = json['info'] ?? {};
    final title = info['title'] ?? 'Unknown API';
    final version = info['version'] ?? '1.0';
    final description = info['description'];

    // Extract Base URL
    String? baseUrl;
    if (json.containsKey('servers') && json['servers'] is List && (json['servers'] as List).isNotEmpty) {
      baseUrl = (json['servers'] as List).first['url'] as String?;
      if (baseUrl != null && baseUrl.startsWith('/') && sourceUrl != null) {
        try {
          final uri = Uri.parse(sourceUrl);
          final portString = (uri.hasPort && uri.port != 80 && uri.port != 443) ? ':${uri.port}' : '';
          baseUrl = '${uri.scheme}://${uri.host}$portString$baseUrl';
        } catch (_) {}
      }
    } else if (json.containsKey('host')) {
      final scheme = (json['schemes'] is List && (json['schemes'] as List).isNotEmpty) ? (json['schemes'] as List).first : 'http';
      final host = json['host'];
      final basePath = json['basePath'] ?? '';
      baseUrl = '$scheme://$host$basePath';
    }

    final paths = json['paths'] as Map<String, dynamic>? ?? {};
    final List<SwaggerEndpoint> endpoints = [];

    paths.forEach((path, methodsMap) {
      if (methodsMap is! Map) return;
      methodsMap.forEach((method, details) {
        if (details is! Map) return;
        final summary = details['summary'] ?? details['operationId'] ?? '';
        final tags = (details['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['default'];
        
        // Handle Swagger 2.0 "in: body" parameters
        var requestBody = details['requestBody'];
        if (requestBody == null && details['parameters'] is List) {
          final bodyParam = (details['parameters'] as List).firstWhere(
            (p) => p is Map && p['in'] == 'body', 
            orElse: () => null
          );
          if (bodyParam != null && bodyParam['schema'] != null) {
            requestBody = {
              'content': {
                'application/json': {
                  'schema': bodyParam['schema']
                }
              }
            };
          }
        }

        endpoints.add(SwaggerEndpoint(
          path: path,
          method: method.toUpperCase(),
          summary: summary,
          tags: tags,
          parameters: details['parameters'] != null ? {'raw': _resolveRefs(details['parameters'], json)} : null,
          requestBody: _resolveRefs(requestBody, json),
          responses: _resolveRefs(details['responses'], json),
        ));
      });
    });

    return SwaggerSchemaInfo(
      title: title,
      version: version,
      description: description,
      baseUrl: baseUrl,
      endpoints: endpoints,
    );
  }

  dynamic _resolveRefs(dynamic node, Map<String, dynamic> root, [Set<String>? visited]) {
    visited ??= {};
    if (node is Map) {
      if (node.containsKey(r'$ref')) {
        final ref = node[r'$ref'] as String;
        if (visited.contains(ref)) return {r'$ref': ref}; // Prevent infinite circular resolution
        visited.add(ref);
        
        final parts = ref.split('/');
        dynamic current = root;
        for (int i = 1; i < parts.length; i++) { // Skip '#'
          if (current is Map && current.containsKey(parts[i])) {
            current = current[parts[i]];
          } else {
            current = null;
            break;
          }
        }
        if (current != null) {
          return _resolveRefs(current, root, Set.from(visited!));
        }
        return node;
      }
      
      final result = <String, dynamic>{};
      for (final entry in node.entries) {
        result[entry.key] = _resolveRefs(entry.value, root, Set.from(visited!));
      }
      return result;
    } else if (node is List) {
      return node.map((e) => _resolveRefs(e, root, Set.from(visited!))).toList();
    }
    return node;
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/logging_service.dart';
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
      final response = await dio.get<dynamic>(url);

      Map<String, dynamic> jsonMap;
      if (response.data is String) {
        jsonMap = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        jsonMap = response.data as Map<String, dynamic>;
      }

      final schemaInfo = await compute(_parseSwaggerJsonIsolate, {
        'json': jsonMap,
        'sourceUrl': url,
      });

      // Add to history
      final historyItem = SwaggerHistoryItem(
        id: const Uuid().v4(),
        name: schemaInfo.title,
        url: url,
        lastAccessed: DateTime.now(),
      );

      final newHistory = [
        historyItem,
        ...state.history.where((item) => item.url != url)
      ];

      state = state.copyWith(
        isLoading: false,
        activeSchema: schemaInfo,
        history: newHistory,
        viewMode: SwaggerViewMode.detail,
      );
    } catch (e, stack) {
      ref.read(loggingServiceProvider.notifier).logError('Failed to fetch Swagger JSON from URL: $e', 'SwaggerExplorer', e, stack);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch Swagger JSON: $e',
      );
    }
  }

  Future<void> fetchFromFile(String filePath) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      final Map<String, dynamic> jsonMap = jsonDecode(content) as Map<String, dynamic>;
      final schemaInfo = await compute(_parseSwaggerJsonIsolate, {
        'json': jsonMap,
      });

      final historyItem = SwaggerHistoryItem(
        id: const Uuid().v4(),
        name: schemaInfo.title,
        filePath: filePath,
        lastAccessed: DateTime.now(),
      );

      final newHistory = [
        historyItem,
        ...state.history.where((item) => item.filePath != filePath)
      ];

      state = state.copyWith(
        isLoading: false,
        activeSchema: schemaInfo,
        history: newHistory,
        viewMode: SwaggerViewMode.detail,
      );
    } catch (e, stack) {
      ref.read(loggingServiceProvider.notifier).logError('Failed to parse Swagger JSON from file: $e', 'SwaggerExplorer', e, stack);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse Swagger JSON from file: $e',
      );
    }
  }

  void deleteFromHistory(String id) {
    final newHistory = state.history.where((item) => item.id != id).toList();
    state = state.copyWith(history: newHistory);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  void setSecurityValue(String key, String value) {
    final newValues = Map<String, String>.from(state.activeSecurityValues);
    newValues[key] = value;
    state = state.copyWith(activeSecurityValues: newValues);
  }

  void removeSecurityValue(String key) {
    final newValues = Map<String, String>.from(state.activeSecurityValues);
    newValues.remove(key);
    state = state.copyWith(activeSecurityValues: newValues);
  }
}

SwaggerSchemaInfo _parseSwaggerJsonIsolate(Map<String, dynamic> args) {
  final json = args['json'] as Map<String, dynamic>;
  final sourceUrl = args['sourceUrl'] as String?;

  return _SwaggerParser.parse(json, sourceUrl: sourceUrl);
}

class _SwaggerParser {
  static SwaggerSchemaInfo parse(
    Map<String, dynamic> json, {
    String? sourceUrl,
  }) {
    final info = json['info'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final title = (info['title'] ?? 'Unknown API').toString();
    final version = (info['version'] ?? '1.0').toString();
    final description = info['description']?.toString();

    // Extract Base URL
    String? baseUrl;
    if (json.containsKey('servers') &&
        json['servers'] is List &&
        (json['servers'] as List).isNotEmpty) {
      baseUrl = (json['servers'] as List).first['url'] as String?;
      if (baseUrl != null && baseUrl.startsWith('/') && sourceUrl != null) {
        try {
          final uri = Uri.parse(sourceUrl);
          final portString = (uri.hasPort && uri.port != 80 && uri.port != 443)
              ? ':${uri.port}'
              : '';
          baseUrl = '${uri.scheme}://${uri.host}$portString$baseUrl';
        } catch (_) {}
      }
    } else if (json.containsKey('host')) {
      final scheme =
          (json['schemes'] is List && (json['schemes'] as List).isNotEmpty)
          ? (json['schemes'] as List).first
          : 'http';
      final host = json['host'];
      final basePath = json['basePath'] ?? '';
      baseUrl = '$scheme://$host$basePath';
    }

    // Parse Security Schemes
    final parsedSecuritySchemes = <String, SwaggerSecurityScheme>{};
    
    // OpenAPI 3.0
    final components = json['components'];
    if (components is Map && components['securitySchemes'] is Map) {
      final schemes = components['securitySchemes'] as Map;
      schemes.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            parsedSecuritySchemes[key.toString()] = SwaggerSecurityScheme.fromJson(value);
          } catch (_) {}
        }
      });
    }

    // Swagger 2.0
    final securityDefinitions = json['securityDefinitions'];
    if (securityDefinitions is Map) {
      securityDefinitions.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            parsedSecuritySchemes[key.toString()] = SwaggerSecurityScheme.fromJson(value);
          } catch (_) {}
        }
      });
    }

    // Parse Global Security
    final globalSecurityList = <Map<String, List<String>>>[];
    if (json['security'] is List) {
      for (final sec in json['security'] as List) {
        if (sec is Map) {
          final mappedSec = <String, List<String>>{};
          sec.forEach((key, value) {
            if (value is List) {
              mappedSec[key.toString()] = value.map((e) => e.toString()).toList();
            } else if (value == null || value is String) {
              mappedSec[key.toString()] = [];
            }
          });
          globalSecurityList.add(mappedSec);
        }
      }
    }

    final paths = json['paths'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<SwaggerEndpoint> endpoints = [];

    paths.forEach((path, methodsMap) {
      if (methodsMap is! Map) return;
      methodsMap.forEach((method, details) {
        if (details is! Map) return;
        final summary = (details['summary'] ?? details['operationId'] ?? '').toString();
        final tags =
            (details['tags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>['default'];

        // Handle Swagger 2.0 "in: body" parameters
        var requestBody = details['requestBody'];
        if (requestBody == null && details['parameters'] is List) {
          final bodyParam = (details['parameters'] as List).firstWhere(
            (p) => p is Map && p['in'] == 'body',
            orElse: () => null,
          );
          if (bodyParam != null && bodyParam['schema'] != null) {
            requestBody = {
              'content': {
                'application/json': {'schema': bodyParam['schema']},
              },
            };
          }
        }

        List<Map<String, List<String>>>? endpointSecurity;
        if (details['security'] is List) {
          endpointSecurity = [];
          for (final sec in details['security'] as List) {
            if (sec is Map) {
              final mappedSec = <String, List<String>>{};
              sec.forEach((key, value) {
                if (value is List) {
                  mappedSec[key.toString()] = value.map((e) => e.toString()).toList();
                } else if (value == null || value is String) {
                  mappedSec[key.toString()] = [];
                }
              });
              endpointSecurity.add(mappedSec);
            }
          }
        }

        endpoints.add(
          SwaggerEndpoint(
            path: path,
            method: method.toString().toUpperCase(),
            summary: summary,
            tags: tags,
            parameters: details['parameters'] != null
                ? {'raw': _resolveRefs(details['parameters'], json)}
                : null,
            requestBody: _resolveRefs(requestBody, json) as Map<String, dynamic>?,
            responses: _resolveRefs(details['responses'], json) as Map<String, dynamic>?,
            security: endpointSecurity,
          ),
        );
      });
    });

    return SwaggerSchemaInfo(
      title: title,
      version: version,
      description: description,
      baseUrl: baseUrl,
      securitySchemes: parsedSecuritySchemes,
      security: globalSecurityList,
      endpoints: endpoints,
    );
  }

  static dynamic _resolveRefs(
    dynamic node,
    Map<String, dynamic> root, [
    Set<String>? visited,
  ]) {
    visited ??= <String>{};
    if (node is Map) {
      if (node.containsKey(r'$ref')) {
        final ref = node[r'$ref'] as String;
        if (visited.contains(ref)) {
          return {r'$ref': ref}; // Prevent infinite circular resolution
        }
        visited.add(ref);

        final parts = ref.split('/');
        dynamic current = root;
        for (int i = 1; i < parts.length; i++) {
          // Skip '#'
          if (current is Map && current.containsKey(parts[i])) {
            current = current[parts[i]];
          } else {
            current = null;
            break;
          }
        }
        if (current != null) {
          return _resolveRefs(current, root, Set<String>.from(visited));
        }
        return node;
      }

      final result = <String, dynamic>{};
      for (final entry in node.entries) {
        result[entry.key as String] = _resolveRefs(entry.value, root, Set<String>.from(visited));
      }
      return result;
    } else if (node is List) {
      return node
          .map((e) => _resolveRefs(e, root, Set<String>.from(visited!)))
          .toList();
    }
    return node;
  }
}

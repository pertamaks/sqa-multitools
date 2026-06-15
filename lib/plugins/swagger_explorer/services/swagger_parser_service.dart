import 'package:flutter/foundation.dart';
import '../models/swagger_state.dart';

/// Public, testable parser service for OpenAPI/Swagger JSON schemas.
///
/// Parses both OpenAPI 3.0 and Swagger 2.0 documents into [SwaggerSchemaInfo].
/// Designed to be used either directly or via [parseSwaggerJsonIsolate] with
/// [compute] for off-main-thread parsing.
class SwaggerParserService {
  SwaggerParserService._();

  /// Entry point: parse a decoded [json] map into [SwaggerSchemaInfo].
  ///
  /// [sourceUrl] is optional; when provided it's used to resolve relative
  /// server URLs from OpenAPI 3.0 `servers` blocks.
  static SwaggerSchemaInfo parse(
    Map<String, dynamic> json, {
    String? sourceUrl,
  }) {
    final info = json['info'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final title = (info['title'] ?? 'Unknown API').toString();
    final version = (info['version'] ?? '1.0').toString();
    final description = info['description']?.toString();

    // ── Base URL ──────────────────────────────────────────────────────
    final baseUrl = _extractBaseUrl(json, sourceUrl);

    // ── Security Schemes ──────────────────────────────────────────────
    final parsedSecuritySchemes = _extractSecuritySchemes(json);

    // ── Global Security ───────────────────────────────────────────────
    final globalSecurityList = _extractSecurityRequirements(json['security']);

    // ── Paths / Endpoints ─────────────────────────────────────────────
    final rawPaths = json['paths'];
    final paths = (rawPaths is Map)
        ? Map<String, dynamic>.from(rawPaths)
        : <String, dynamic>{};
    final List<SwaggerEndpoint> endpoints = [];

    paths.forEach((path, methodsMap) {
      if (methodsMap is! Map) return;
      methodsMap.forEach((method, details) {
        if (details is! Map<String, dynamic>) return;
        endpoints.add(_parseEndpoint(path, method, details, json));
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

  /// Recursively resolve `$ref` pointers in a Swagger document tree.
  ///
  /// Uses a single mutable [visited] set with backtracking to prevent
  /// infinite loops from circular references while avoiding O(n²) memory
  /// allocation of per-recursion copies.
  static dynamic resolveRefs(
    dynamic node,
    Map<String, dynamic> root, [
    Set<String>? visited,
  ]) {
    visited ??= <String>{};
    if (node is Map) {
      if (node.containsKey(r'$ref')) {
        final ref = node[r'$ref'] as String;
        if (!visited.add(ref)) {
          // Circular reference detected — return the ref stub instead of
          // recursing forever.
          return {r'$ref': ref};
        }

        final parts = ref.split('/');
        dynamic current = root;
        for (int i = 1; i < parts.length; i++) {
          if (current is Map && current.containsKey(parts[i])) {
            current = current[parts[i]];
          } else {
            current = null;
            break;
          }
        }

        dynamic result;
        if (current != null) {
          result = resolveRefs(current, root, visited);
        } else {
          result = node;
        }

        visited.remove(ref);
        return result;
      }

      final result = <String, dynamic>{};
      for (final entry in node.entries) {
        result[entry.key as String] =
            resolveRefs(entry.value, root, visited);
      }
      return result;
    } else if (node is List) {
      return node.map((e) => resolveRefs(e, root, visited)).toList();
    }
    return node;
  }

  // ── Private helpers ──────────────────────────────────────────────────

  static String? _extractBaseUrl(
    Map<String, dynamic> json,
    String? sourceUrl,
  ) {
    // OpenAPI 3.0: servers[0].url
    if (json.containsKey('servers') &&
        json['servers'] is List &&
        (json['servers'] as List).isNotEmpty) {
      var baseUrl = (json['servers'] as List).first['url'] as String?;
      if (baseUrl != null && baseUrl.startsWith('/') && sourceUrl != null) {
        try {
          final uri = Uri.parse(sourceUrl);
          final portString =
              (uri.hasPort && uri.port != 80 && uri.port != 443)
                  ? ':${uri.port}'
                  : '';
          baseUrl = '${uri.scheme}://${uri.host}$portString$baseUrl';
        } catch (_) {
          // Malformed source URL — leave baseUrl as-is
        }
      }
      return baseUrl;
    }

    // Swagger 2.0: host + basePath
    if (json.containsKey('host')) {
      final scheme =
          (json['schemes'] is List && (json['schemes'] as List).isNotEmpty)
              ? (json['schemes'] as List).first
              : 'http';
      final host = json['host'];
      final basePath = json['basePath'] ?? '';
      return '$scheme://$host$basePath';
    }

    return null;
  }

  static Map<String, SwaggerSecurityScheme> _extractSecuritySchemes(
    Map<String, dynamic> json,
  ) {
    final schemes = <String, SwaggerSecurityScheme>{};

    // OpenAPI 3.0: components.securitySchemes
    final components = json['components'];
    if (components is Map && components['securitySchemes'] is Map) {
      final raw = components['securitySchemes'] as Map;
      raw.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            schemes[key.toString()] = SwaggerSecurityScheme.fromJson(value);
          } catch (_) {
            // Skip malformed security scheme entries
          }
        }
      });
    }

    // Swagger 2.0: securityDefinitions
    final securityDefinitions = json['securityDefinitions'];
    if (securityDefinitions is Map) {
      securityDefinitions.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          try {
            schemes[key.toString()] = SwaggerSecurityScheme.fromJson(value);
          } catch (_) {
            // Skip malformed security definition entries
          }
        }
      });
    }

    return schemes;
  }

  static List<Map<String, List<String>>> _extractSecurityRequirements(
    dynamic security,
  ) {
    final result = <Map<String, List<String>>>[];
    if (security is List) {
      for (final sec in security) {
        if (sec is Map) {
          final mappedSec = <String, List<String>>{};
          sec.forEach((key, value) {
            if (value is List) {
              mappedSec[key.toString()] =
                  value.map((e) => e.toString()).toList();
            } else if (value == null || value is String) {
              mappedSec[key.toString()] = [];
            }
          });
          result.add(mappedSec);
        }
      }
    }
    return result;
  }

  static SwaggerEndpoint _parseEndpoint(
    String path,
    dynamic method,
    Map<String, dynamic> details,
    Map<String, dynamic> root,
  ) {
    final summary =
        (details['summary'] ?? details['operationId'] ?? '').toString();
    final tags = (details['tags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        <String>['default'];

    // Handle Swagger 2.0 "in: body" parameters → requestBody conversion
    var requestBody = details['requestBody'];
    if (requestBody == null && details['parameters'] is List) {
      final bodyParam = (details['parameters'] as List<dynamic>)
          .where((p) => p is Map && p['in'] == 'body')
          .firstOrNull;
      if (bodyParam != null && (bodyParam as Map)['schema'] != null) {
        requestBody = {
          'content': {
            'application/json': {'schema': bodyParam['schema']},
          },
        };
      }
    }

    // Endpoint-level security (overrides global)
    List<Map<String, List<String>>>? endpointSecurity;
    if (details['security'] is List) {
      endpointSecurity = _extractSecurityRequirements(details['security']);
    }

    // Resolve $refs in parameters, requestBody, and responses.
    // Cast to List<Map> for type-safe access in consumers.
    final resolvedParams = details['parameters'] != null
        ? (resolveRefs(details['parameters'], root) as List<dynamic>?)
            ?.cast<Map<String, dynamic>>()
        : null;

    return SwaggerEndpoint(
      path: path,
      method: method.toString().toUpperCase(),
      summary: summary,
      tags: tags,
      parameters: resolvedParams,
      requestBody:
          resolveRefs(requestBody, root) as Map<String, dynamic>?,
      responses:
          resolveRefs(details['responses'], root) as Map<String, dynamic>?,
      security: endpointSecurity,
    );
  }
}

/// Top-level function suitable for passing to [compute] for
/// off-main-thread Swagger document parsing.
///
/// [args] must contain:
///   - `'json'`: the decoded JSON map
///   - `'sourceUrl'` (optional): the URL the JSON was fetched from
SwaggerSchemaInfo parseSwaggerJsonIsolate(Map<String, dynamic> args) {
  final json = args['json'] as Map<String, dynamic>;
  final sourceUrl = args['sourceUrl'] as String?;
  return SwaggerParserService.parse(json, sourceUrl: sourceUrl);
}

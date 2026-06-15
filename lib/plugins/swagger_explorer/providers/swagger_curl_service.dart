import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/swagger_state.dart';
import '../../curl_requester/models/curl_command.dart';

final swaggerCurlServiceProvider = Provider<SwaggerCurlService>((ref) {
  return SwaggerCurlService();
});

class SwaggerCurlService {
  CurlCommand generateCommand(
    SwaggerEndpoint endpoint,
    SwaggerSchemaInfo schema,
    Map<String, String> activeSecurityValues,
  ) {
    final baseUrl = schema.baseUrl ?? 'http://localhost:8080';
    var url = endpoint.path;

    final queryParams = <String, String>{};
    final pathParams = <String, String>{};
    final headers = <String, String>{'Accept': 'application/json'};
    final formFields = <String, String>{};
    String rawBody = '';

    // Process Security
    final securityList = endpoint.security ?? schema.security;
    if (securityList.isNotEmpty) {
      for (final securityReq in securityList) {
        if (securityReq.isEmpty) continue; // Skip empty auth requirements

        bool allSatisfied = true;
        final tempHeaders = <String, String>{};
        final tempQueryParams = <String, String>{};

        for (final secKey in securityReq.keys) {
          final token = activeSecurityValues[secKey];
          if (token == null || token.isEmpty) {
            allSatisfied = false;
            break;
          }

          final schemeDef = schema.securitySchemes[secKey];
          if (schemeDef != null) {
            if (schemeDef.type == 'apiKey') {
              if (schemeDef.inLocation == 'header') {
                tempHeaders[schemeDef.name ?? secKey] = token;
              } else if (schemeDef.inLocation == 'query') {
                tempQueryParams[schemeDef.name ?? secKey] = token;
              }
            } else if (schemeDef.type == 'http') {
              if (schemeDef.scheme?.toLowerCase() == 'bearer') {
                tempHeaders['Authorization'] = 'Bearer $token';
              } else if (schemeDef.scheme?.toLowerCase() == 'basic') {
                tempHeaders['Authorization'] = 'Basic $token';
              } else {
                tempHeaders['Authorization'] = token;
              }
            } else if (schemeDef.type == 'oauth2' || schemeDef.type == 'openIdConnect') {
               tempHeaders['Authorization'] = 'Bearer $token';
            } else if (schemeDef.type == 'basic') {
               tempHeaders['Authorization'] = 'Basic $token';
            }
          }
        }

        if (allSatisfied) {
          headers.addAll(tempHeaders);
          queryParams.addAll(tempQueryParams);
          break; // Stop at first fully satisfied security requirement
        }
      }
    }

    // Process Parameters
    if (endpoint.parameters != null && endpoint.parameters!['raw'] != null) {
      for (final p in endpoint.parameters!['raw'] as List) {
        if (p is! Map) continue;
        final name = p['name']?.toString() ?? '';
        final inLoc = p['in']?.toString() ?? '';

        // Generate a dummy value
        dynamic val =
            p['example'] ?? p['schema']?['example'] ?? p['schema']?['default'];
        if (val == null) {
          final type = p['type'] ?? p['schema']?['type'] ?? 'string';
          if (type == 'integer' || type == 'number') {
            val = '0';
          } else if (type == 'boolean') {
            val = 'true';
          } else if (type == 'file') {
            val = '@dummy_file.txt';
          } else {
            val = 'string';
          }
        }
        final valStr = val.toString();

        if (inLoc == 'query') {
          queryParams[name] = valStr;
        } else if (inLoc == 'header') {
          headers[name] = valStr;
        } else if (inLoc == 'path') {
          pathParams[name] = valStr;
        } else if (inLoc == 'formData') {
          formFields[name] = valStr;
          if (!headers.containsKey('Content-Type')) {
            headers['Content-Type'] = (valStr.startsWith('@'))
                ? 'multipart/form-data'
                : 'application/x-www-form-urlencoded';
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
          final bodySchema = content['application/json']['schema'] as Map<String, dynamic>?;
          final parsedExample = generateExampleFromSchema(bodySchema ?? <String, dynamic>{});
          if ((parsedExample is Map && parsedExample.isNotEmpty) ||
              (parsedExample is List && parsedExample.isNotEmpty)) {
            rawBody = const JsonEncoder.withIndent('  ').convert(parsedExample);
          }
        } else if (content.containsKey('application/x-www-form-urlencoded')) {
          headers['Content-Type'] = 'application/x-www-form-urlencoded';
          final bodySchema =
              content['application/x-www-form-urlencoded']['schema'] as Map<String, dynamic>?;
          final parsedExample = generateExampleFromSchema(bodySchema ?? <String, dynamic>{});
          if (parsedExample is Map) {
            parsedExample.forEach((k, v) => formFields[k as String] = v.toString());
          }
        } else if (content.containsKey('multipart/form-data')) {
          headers['Content-Type'] = 'multipart/form-data';
          final bodySchema = content['multipart/form-data']['schema'] as Map<String, dynamic>?;
          final parsedExample = generateExampleFromSchema(bodySchema ?? <String, dynamic>{});
          if (parsedExample is Map) {
            parsedExample.forEach((k, v) {
              final key = k as String;
              if (bodySchema?['properties']?[key]?['type'] == 'string' &&
                  bodySchema?['properties']?[key]?['format'] == 'binary') {
                formFields[key] = '@dummy_file.txt';
              } else {
                formFields[key] = v.toString();
              }
            });
          }
        }
      }
    }

    // Construct URL with query parameters
    if (queryParams.isNotEmpty) {
      final qs = queryParams.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
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
      final parts = <String>[];
      for (final f in formFields.entries) {
        if (isMultipart) {
          parts.add('${f.key}=${f.value}');
        } else {
          parts.add('${Uri.encodeComponent(f.key)}=${Uri.encodeComponent(f.value)}');
        }
      }
      rawBody = parts.join('&');
    }

    return CurlCommand(
      url: '$baseUrl$url',
      method: endpoint.method,
      headers: headers,
      pathParameters: pathParams,
      queryParameters: queryParams,
      body: rawBody,
    );
  }

  dynamic generateExampleFromSchema(Map<String, dynamic> schema) {
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
              example[key] = <dynamic>[generateExampleFromSchema(items)];
            } else {
              example[key] = <dynamic>[];
            }
          } else if (value['type'] == 'object') {
            example[key] = generateExampleFromSchema(value);
          } else {
            example[key] = 'unknown';
          }
        }
      });
      return example;
    } else if (schema['type'] == 'array') {
      final items = schema['items'];
      if (items is Map<String, dynamic>) {
        return <dynamic>[generateExampleFromSchema(items)];
      }
      return <dynamic>[];
    }
    return schema;
  }
}

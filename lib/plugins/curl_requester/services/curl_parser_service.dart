import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/curl_command.dart';
import '../models/form_data_item.dart';

class CurlParserService {
  static CurlCommand parse(String curlString) {
    if (curlString.isEmpty) return const CurlCommand();

    String url = '';
    String method = 'GET';
    final Map<String, String> headers = {};
    final Map<String, String> pathParameters = {};
    final Map<String, String> queryParameters = {};
    String body = '';
    BodyType bodyType = BodyType.raw;
    AuthMethod authMethod = AuthMethod.none;
    final Map<String, String> authData = {};
    final List<FormDataItem> formData = [];
    final List<FormDataItem> urlEncodedData = [];

    // Handle backslashes with potential trailing whitespace as line continuations
    // We do NOT replace all newlines with spaces anymore to preserve multi-line bodies
    final sanitizedCurl = curlString.replaceAll(RegExp(r'\\\s*\n'), ' ');
    final tokens = _tokenize(sanitizedCurl);

    final httpMethods = {
      'GET',
      'POST',
      'PUT',
      'DELETE',
      'PATCH',
      'HEAD',
      'OPTIONS',
    };

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token == '-X' || token == '--request') {
        if (i + 1 < tokens.length) method = tokens[++i].toUpperCase();
      } else if (token == '-H' || token == '--header') {
        if (i + 1 < tokens.length) {
          final header = tokens[++i];
          final parts = header.split(':');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join(':').trim();
            if (key.toLowerCase() == 'authorization') {
              if (value.toLowerCase().startsWith('bearer ')) {
                authMethod = AuthMethod.bearerToken;
                authData['token'] = value.substring(7).trim();
              } else if (value.toLowerCase().startsWith('basic ')) {
                try {
                  final decoded = utf8.decode(
                    base64Decode(value.substring(6).trim()),
                  );
                  final split = decoded.split(':');
                  if (split.length == 2) {
                    authMethod = AuthMethod.basicAuth;
                    authData['username'] = split[0];
                    authData['password'] = split[1];
                  } else {
                    headers[key] = value;
                  }
                } catch (_) {
                  headers[key] = value;
                }
              } else {
                headers[key] = value;
              }
            } else {
              headers[key] = value;
            }
          }
        }
      } else if (token == '-d' ||
          token == '--data' ||
          token == '--data-raw' ||
          token == '--data-binary') {
        if (i + 1 < tokens.length) {
          // Preserve newlines in body
          body = tokens[++i];
          if (token == '--data-binary' && body.startsWith('@')) {
            bodyType = BodyType.binaryFile;
          } else if (bodyType == BodyType.raw &&
              headers.entries.any(
                (e) =>
                    e.key.toLowerCase() == 'content-type' &&
                    e.value.toLowerCase().contains(
                      'application/x-www-form-urlencoded',
                    ),
              )) {
            bodyType = BodyType.urlEncoded;
          }
        }
      } else if (token == '-F' || token == '--form') {
        if (i + 1 < tokens.length) {
          final formStr = tokens[++i];
          final parts = formStr.split('=');
          if (parts.length >= 2) {
            final key = parts[0];
            final valueStr = parts.sublist(1).join('=');
            if (valueStr.startsWith('@')) {
              formData.add(
                FormDataItem(
                  id: const Uuid().v4(),
                  key: key,
                  value: '',
                  filePath: valueStr.substring(1),
                  isFile: true,
                ),
              );
            } else {
              formData.add(
                FormDataItem(
                  id: const Uuid().v4(),
                  key: key,
                  value: valueStr,
                  isFile: false,
                ),
              );
            }
          }
          bodyType = BodyType.multipartFormData;
        }
      } else if (url.isEmpty &&
          !token.startsWith('-') &&
          token != 'curl' &&
          !httpMethods.contains(token.toUpperCase())) {
        // Clean URL of all whitespace and quotes
        url = token
            .replaceAll(RegExp(r'''^["']|["']$'''), '')
            .replaceAll(RegExp(r'\s+'), '');
      }
    }

    // Parse query parameters from URL
    if (url.isNotEmpty) {
      try {
        final uri = Uri.parse(url);
        queryParameters.addAll(uri.queryParameters);
        // Keep the base URL without query params for the model?
        // Actually, CurlCommand usually wants the full URL or just the base.
        // Let's keep base URL and params separate as requested by the UI's structured view.
        url = uri.replace(query: null, queryParameters: {}).toString();
        if (url.endsWith('?')) url = url.substring(0, url.length - 1);
      } catch (_) {
        // Fallback for malformed URLs
      }

      // Extract path variables from URL (e.g., {id} or :id)
      final pathVarRegex = RegExp(r'\{([^}]+)\}|:([a-zA-Z0-9_]+)');
      final matches = pathVarRegex.allMatches(url);
      for (final match in matches) {
        final paramName = match.group(1) ?? match.group(2);
        if (paramName != null && paramName.isNotEmpty) {
          pathParameters[paramName] = '';
        }
      }
    }

    if (bodyType == BodyType.raw && body.isNotEmpty) {
      final contentType = headers.entries
          .firstWhere(
            (e) => e.key.toLowerCase() == 'content-type',
            orElse: () => const MapEntry('', ''),
          )
          .value
          .toLowerCase();

      if (contentType.contains('application/x-www-form-urlencoded')) {
        bodyType = BodyType.urlEncoded;
        final parts = body.split('&');
        for (final part in parts) {
          final kv = part.split('=');
          if (kv.length == 2) {
            urlEncodedData.add(
              FormDataItem(
                id: const Uuid().v4(),
                key: Uri.decodeComponent(kv[0]),
                value: Uri.decodeComponent(kv[1]),
              ),
            );
          } else if (kv.length == 1 && kv[0].isNotEmpty) {
            urlEncodedData.add(
              FormDataItem(
                id: const Uuid().v4(),
                key: Uri.decodeComponent(kv[0]),
                value: '',
              ),
            );
          }
        }
      } else if (contentType.contains('application/json')) {
        bodyType = BodyType.json;
      } else {
        try {
          final decoded = jsonDecode(body);
          if (decoded is Map || decoded is List) {
            bodyType = BodyType.json;
          }
        } catch (_) {}
      }
    }

    return CurlCommand(
      url: url,
      method: method,
      headers: headers,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      body: body,
      bodyType: bodyType,
      authMethod: authMethod,
      authData: authData,
      formData: formData,
      urlEncodedData: urlEncodedData,
    );
  }

  static List<String> _tokenize(String input) {
    final List<String> result = [];
    final RegExp regExp = RegExp(r'''[^\s"']+|"([^"]*)"|'([^']*)''');
    final matches = regExp.allMatches(input);
    for (final match in matches) {
      if (match.group(1) != null) {
        result.add(match.group(1)!);
      } else if (match.group(2) != null) {
        result.add(match.group(2)!);
      } else {
        result.add(match.group(0)!);
      }
    }
    return result;
  }

  static String stringify(CurlCommand command) {
    if (command.url.isEmpty &&
        command.body.isEmpty &&
        command.headers.isEmpty &&
        command.formData.isEmpty &&
        command.urlEncodedData.isEmpty &&
        command.authMethod == AuthMethod.none) {
      return '';
    }

    final buffer = StringBuffer('curl');
    if (command.method != 'GET') {
      buffer.write(' -X ${command.method}');
    }

    // Reconstruct URL with query and path parameters
    String finalUrl = command.url;

    // Inject active path parameters
    final activePathParams = Map<String, String>.from(command.pathParameters)
      ..removeWhere((k, v) => command.inactivePathParameters.contains(k));
    for (final entry in activePathParams.entries) {
      if (entry.value.isNotEmpty) {
        finalUrl = finalUrl.replaceAll(
          '{${entry.key}}',
          Uri.encodeComponent(entry.value),
        );
        finalUrl = finalUrl.replaceAll(
          ':${entry.key}',
          Uri.encodeComponent(entry.value),
        );
      }
    }

    final activeParams = Map<String, String>.from(command.queryParameters)
      ..removeWhere((k, v) => command.inactiveQueryParameters.contains(k));

    if (activeParams.isNotEmpty) {
      try {
        final uri = Uri.parse(finalUrl);
        finalUrl = uri
            .replace(queryParameters: {...uri.queryParameters, ...activeParams})
            .toString();

        // Post-process to ensure {{faker.*}} placeholders are NOT encoded
        // Uri.replace will encode { to %7B and } to %7D
        finalUrl = finalUrl
            .replaceAll('%7B%7B', '{{')
            .replaceAll('%7D%7D', '}}');
      } catch (_) {}
    }

    // Also handle placeholders in the base URL itself
    finalUrl = finalUrl.replaceAll('%7B%7B', '{{').replaceAll('%7D%7D', '}}');

    buffer.write(' "$finalUrl"');

    // Headers
    for (var entry in command.headers.entries) {
      if (command.inactiveHeaders.contains(entry.key)) continue;
      buffer.write(' \\\n  -H "${entry.key}: ${entry.value}"');
    }

    // Auth
    if (command.authMethod == AuthMethod.bearerToken) {
      final token = command.authData['token'] ?? '';
      if (token.isNotEmpty) {
        buffer.write(' \\\n  -H "Authorization: Bearer $token"');
      }
    } else if (command.authMethod == AuthMethod.basicAuth) {
      final username = command.authData['username'] ?? '';
      final password = command.authData['password'] ?? '';
      if (username.isNotEmpty || password.isNotEmpty) {
        final encoded = base64Encode(utf8.encode('$username:$password'));
        buffer.write(' \\\n  -H "Authorization: Basic $encoded"');
      }
    } else if (command.authMethod == AuthMethod.apiKey) {
      final key = command.authData['key'] ?? '';
      final value = command.authData['value'] ?? '';
      final addTo = command.authData['addTo'] ?? 'Header';
      if (key.isNotEmpty && value.isNotEmpty && addTo == 'Header') {
        buffer.write(' \\\n  -H "$key: $value"');
      }
    }

    // Body
    if (command.bodyType == BodyType.multipartFormData) {
      for (final item in command.formData) {
        if (!item.isActive) continue;
        if (item.isFile) {
          buffer.write(" \\\n  -F '${item.key}=@${item.filePath ?? ''}'");
        } else {
          buffer.write(" \\\n  -F '${item.key}=${item.value}'");
        }
      }
    } else if (command.bodyType == BodyType.urlEncoded) {
      final encodedParts = command.urlEncodedData
          .where((i) => i.isActive)
          .map(
            (i) =>
                '${Uri.encodeComponent(i.key)}=${Uri.encodeComponent(i.value)}',
          )
          .join('&');
      if (encodedParts.isNotEmpty) {
        buffer.write(" \\\n  -d '$encodedParts'");
      }
    } else if (command.bodyType == BodyType.binaryFile &&
        command.body.isNotEmpty) {
      buffer.write(" \\\n  --data-binary '${command.body}'");
    } else if (command.body.isNotEmpty) {
      String displayBody = command.body;
      try {
        // Attempt to prettify JSON if it looks like JSON
        final decoded = json.decode(command.body);
        displayBody = const JsonEncoder.withIndent('  ').convert(decoded);
      } catch (_) {
        // Not JSON or already formatted, keep as is
      }

      // Use single quotes for body to handle internal double quotes common in JSON
      buffer.write(" \\\n  -d '$displayBody'");
    }

    return buffer.toString();
  }
}

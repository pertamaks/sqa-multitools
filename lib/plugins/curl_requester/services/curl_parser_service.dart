import 'dart:convert';
import '../models/curl_command.dart';

class CurlParserService {
  static CurlCommand parse(String curlString) {
    if (curlString.isEmpty) return const CurlCommand();

    String url = '';
    String method = 'GET';
    final Map<String, String> headers = {};
    final Map<String, String> queryParameters = {};
    String body = '';

    // Handle backslashes with potential trailing whitespace as line continuations
    // We do NOT replace all newlines with spaces anymore to preserve multi-line bodies
    final sanitizedCurl = curlString.replaceAll(RegExp(r'\\\s*\n'), ' ');
    final tokens = _tokenize(sanitizedCurl);

    final httpMethods = {'GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'};

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (token == '-X' || token == '--request') {
        if (i + 1 < tokens.length) method = tokens[++i].toUpperCase();
      } else if (token == '-H' || token == '--header') {
        if (i + 1 < tokens.length) {
          final header = tokens[++i];
          final parts = header.split(':');
          if (parts.length >= 2) {
            headers[parts[0].trim()] = parts.sublist(1).join(':').trim();
          }
        }
      } else if (token == '-d' || token == '--data' || token == '--data-raw' || token == '--data-binary') {
        if (i + 1 < tokens.length) {
          // Preserve newlines in body
          body = tokens[++i];
        }
      } else if (url.isEmpty && 
                 !token.startsWith('-') && 
                 token != 'curl' && 
                 !httpMethods.contains(token.toUpperCase())) {
        // Clean URL of all whitespace and quotes
        url = token.replaceAll(RegExp(r'''^["']|["']$'''), '').replaceAll(RegExp(r'\s+'), '');
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
    }

    return CurlCommand(
      url: url,
      method: method,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
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
    if (command.url.isEmpty && command.body.isEmpty && command.headers.isEmpty) return '';

    final buffer = StringBuffer('curl');
    if (command.method != 'GET') {
      buffer.write(' -X ${command.method}');
    }

    // Reconstruct URL with query parameters
    String finalUrl = command.url;
    final activeParams = Map<String, String>.from(command.queryParameters)
      ..removeWhere((k, v) => command.inactiveQueryParameters.contains(k));
    
    if (activeParams.isNotEmpty) {
      try {
        final uri = Uri.parse(finalUrl);
        finalUrl = uri.replace(queryParameters: {
          ...uri.queryParameters,
          ...activeParams,
        }).toString();
        
        // Post-process to ensure {{faker.*}} placeholders are NOT encoded
        // Uri.replace will encode { to %7B and } to %7D
        finalUrl = finalUrl.replaceAll('%7B%7B', '{{').replaceAll('%7D%7D', '}}');
      } catch (_) {}
    }
    
    // Also handle placeholders in the base URL itself
    finalUrl = finalUrl.replaceAll('%7B%7B', '{{').replaceAll('%7D%7D', '}}');

    buffer.write(' "$finalUrl"');

    for (var entry in command.headers.entries) {
      if (command.inactiveHeaders.contains(entry.key)) continue;
      buffer.write(' \\\n  -H "${entry.key}: ${entry.value}"');
    }

    if (command.body.isNotEmpty) {
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

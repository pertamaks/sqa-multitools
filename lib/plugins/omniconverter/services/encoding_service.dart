import 'dart:convert';
import 'package:html/parser.dart' as html_parser;

class EncodingService {
  const EncodingService();

  // --- Base64 ---
  String encodeBase64(String input, {bool urlSafe = false}) {
    final bytes = utf8.encode(input);
    return urlSafe ? base64Url.encode(bytes) : base64.encode(bytes);
  }

  String decodeBase64(String input) {
    var sanitized = input.trim().replaceAll('\r', '').replaceAll('\n', '');
    // Handle URL safe replacements and padding
    var normalized = sanitized.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    final bytes = base64.decode(normalized);
    return utf8.decode(bytes);
  }

  // --- URL ---
  String encodeUrl(String input, {bool fullComponent = true}) {
    return fullComponent ? Uri.encodeComponent(input) : Uri.encodeFull(input);
  }

  String decodeUrl(String input) {
    return Uri.decodeComponent(input);
  }

  // --- HTML Entities ---
  String encodeHtml(String input) {
    const htmlEscape = HtmlEscape(HtmlEscapeMode.element);
    return htmlEscape.convert(input);
  }

  String decodeHtml(String input) {
    // Decode HTML entities (e.g. &amp;, &lt;, &#39;, &quot;)
    return html_parser.parse(input).documentElement?.text ?? input;
  }


  // --- Hex ---
  String encodeHex(String input) {
    final bytes = utf8.encode(input);
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  String decodeHex(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (clean.length % 2 != 0) {
      throw const FormatException('Hex string must have an even length.');
    }
    final bytes = <int>[];
    for (var i = 0; i < clean.length; i += 2) {
      final byteHex = clean.substring(i, i + 2);
      final byte = int.parse(byteHex, radix: 16);
      bytes.add(byte);
    }
    return utf8.decode(bytes);
  }

  // --- Binary ---
  String encodeBinary(String input) {
    final bytes = utf8.encode(input);
    return bytes.map((b) => b.toRadixString(2).padLeft(8, '0')).join(' ');
  }

  String decodeBinary(String input) {
    final clean = input.replaceAll(RegExp(r'[^01]'), '');
    if (clean.length % 8 != 0) {
      throw const FormatException('Binary string must be a multiple of 8 bits.');
    }
    final bytes = <int>[];
    for (var i = 0; i < clean.length; i += 8) {
      final byteBin = clean.substring(i, i + 8);
      final byte = int.parse(byteBin, radix: 2);
      bytes.add(byte);
    }
    return utf8.decode(bytes);
  }
}

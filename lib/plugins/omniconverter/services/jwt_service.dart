import 'dart:convert';

class JwtInfo {
  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
  final String signature;
  final DateTime? expiresAt;
  final DateTime? issuedAt;
  final bool isExpired;

  const JwtInfo({
    required this.header,
    required this.payload,
    required this.signature,
    this.expiresAt,
    this.issuedAt,
    required this.isExpired,
  });
}

class JwtService {
  const JwtService();

  /// Decodes a 3-part JSON Web Token string.
  JwtInfo decode(String token) {
    final cleanToken = token.trim();
    final parts = cleanToken.split('.');
    if (parts.length != 3) {
      throw const FormatException('Invalid JWT format. Token must contain 3 parts separated by dots.');
    }

    final headerMap = _decodePart(parts[0]);
    final payloadMap = _decodePart(parts[1]);
    final signature = parts[2];

    DateTime? expiresAt;
    if (payloadMap['exp'] != null) {
      final expVal = payloadMap['exp'];
      if (expVal is num) {
        expiresAt = DateTime.fromMillisecondsSinceEpoch(
          (expVal * 1000).toInt(),
          isUtc: true,
        ).toLocal();
      }
    }

    DateTime? issuedAt;
    if (payloadMap['iat'] != null) {
      final iatVal = payloadMap['iat'];
      if (iatVal is num) {
        issuedAt = DateTime.fromMillisecondsSinceEpoch(
          (iatVal * 1000).toInt(),
          isUtc: true,
        ).toLocal();
      }
    }

    final now = DateTime.now();
    final isExpired = expiresAt != null && now.isAfter(expiresAt);

    return JwtInfo(
      header: headerMap,
      payload: payloadMap,
      signature: signature,
      expiresAt: expiresAt,
      issuedAt: issuedAt,
      isExpired: isExpired,
    );
  }

  Map<String, dynamic> _decodePart(String part) {
    var normalized = part.replaceAll('-', '+').replaceAll('_', '/');
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    final bytes = base64.decode(normalized);
    final jsonStr = utf8.decode(bytes);
    final decoded = json.decode(jsonStr);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    } else if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('JWT part is not a valid JSON object.');
  }

  String formatMap(Map<String, dynamic> map) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(map);
  }
}

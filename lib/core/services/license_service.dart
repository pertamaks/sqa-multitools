import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'preferences_service.dart';

class LicenseInfo {
  final String email;
  final String code;
  final int tier;
  final String signature;

  LicenseInfo({
    required this.email,
    required this.code,
    required this.tier,
    required this.signature,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'code': code,
    'tier': tier,
    'signature': signature,
  };

  factory LicenseInfo.fromJson(Map<String, dynamic> json) => LicenseInfo(
    email: json['email'] as String,
    code: json['code'] as String,
    tier: json['tier'] as int,
    signature: json['signature'] as String,
  );
}

class LicenseService {
  final PreferencesService _prefs;

  // TO THE USER: Replace this with your actual Public Key generated from the script
  static const String _publicKeyBase64 =
      'CRbf+8qOzhkhgJE9QbxxmaqpQRwEPh5hA1SGItHJo2c=';

  // TO THE USER: Set your Cloudflare Worker URL here
  static const String _workerUrl =
      'https://sqa-license-worker.hohok.workers.dev';

  LicenseService(this._prefs);

  /// Verifies a code with the Cloudflare Worker.
  /// If successful, saves the signature and returns the tier.
  Future<int?> verifyWithServer(String email, String code) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_workerUrl/verify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'code': code.trim().toUpperCase(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            jsonDecode(response.body) as Map<String, dynamic>;
        final int tier = data['tier'] as int;
        final String signature = data['signature'].toString();

        // Persist the verified license
        await _prefs.setSupporterTier(tier);
        await _prefs.setSupporterEmail(email.trim().toLowerCase());
        await _prefs.setSupporterSignature(signature);
        await _prefs.setSupporterCode(code.trim().toUpperCase());

        return tier;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          debugPrint(
            'Verification Error (${response.statusCode}): ${errorData['error']}',
          );
        } catch (_) {
          debugPrint('Verification Error: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('License verification failed: $e');
    }
    return null;
  }

  /// Verifies the locally stored license signature.
  /// Returns the tier if valid, 0 otherwise.
  Future<int> verifyLocally() async {
    final tier = _prefs.getSupporterTier();
    if (tier == 0) return 0;

    final email = _prefs.getSupporterEmail();
    final code = _prefs.getSupporterCode();
    final signature = _prefs.getSupporterSignature();

    if (email == null || code == null || signature == null) return 0;

    final isValid = await _checkSignature(email, code, tier, signature);
    return isValid ? tier : 0;
  }

  Future<bool> _checkSignature(
    String email,
    String code,
    int tier,
    String signatureBase64,
  ) async {
    try {
      final algorithm = Ed25519();
      final publicKey = SimplePublicKey(
        base64Decode(_publicKeyBase64),
        type: KeyPairType.ed25519,
      );

      final signature = Signature(
        base64Decode(signatureBase64),
        publicKey: publicKey,
      );

      // The message that was signed: "EMAIL|CODE|TIER"
      final message = utf8.encode('$email|$code|$tier');

      return await algorithm.verify(message, signature: signature);
    } catch (e) {
      return false;
    }
  }
}

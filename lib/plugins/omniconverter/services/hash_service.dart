import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashResult {
  final String algorithm;
  final String value;

  const HashResult({required this.algorithm, required this.value});
}

class HashService {
  const HashService();

  String md5Hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  String sha1Hash(String input) {
    return sha1.convert(utf8.encode(input)).toString();
  }

  String sha256Hash(String input) {
    return sha256.convert(utf8.encode(input)).toString();
  }

  String sha512Hash(String input) {
    return sha512.convert(utf8.encode(input)).toString();
  }

  List<HashResult> computeAll(String input) {
    if (input.isEmpty) return const [];
    return [
      HashResult(algorithm: 'MD5', value: md5Hash(input)),
      HashResult(algorithm: 'SHA-1', value: sha1Hash(input)),
      HashResult(algorithm: 'SHA-256', value: sha256Hash(input)),
      HashResult(algorithm: 'SHA-512', value: sha512Hash(input)),
    ];
  }
}

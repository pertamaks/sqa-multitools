import 'dart:convert';
import 'package:cryptography/cryptography.dart';

void main() async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPair();
  final publicKey = await keyPair.extractPublicKey();
  final privateKey = await keyPair.extract();

  print('--- ED25519 KEY PAIR ---');
  print('PUBLIC KEY (Base64): ${base64Encode(publicKey.bytes)}');
  print('PRIVATE KEY (Base64): ${base64Encode(privateKey.bytes)}');
}

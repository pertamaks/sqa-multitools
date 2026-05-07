import 'package:flutter/services.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../security_payload_models.dart';
import '../utils/payload_parser.dart';

part 'payload_providers.g.dart';

@riverpod
Future<String> securityPayloadRaw(Ref ref) async {
  return await rootBundle.loadString('assets/security_payload.md');
}

@riverpod
Future<List<PayloadCategory>> securityPayloadData(Ref ref) async {
  final raw = await ref.watch(securityPayloadRawProvider.future);
  return PayloadParser.parse(raw);
}

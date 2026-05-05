import 'package:freezed_annotation/freezed_annotation.dart';
import 'curl_command.dart';

part 'curl_transaction.freezed.dart';
part 'curl_transaction.g.dart';

@freezed
abstract class CurlTransaction with _$CurlTransaction {
  const factory CurlTransaction({
    required String id,
    required CurlCommand request,
    required int statusCode,
    required String responseBody,
    required Duration latency,
    required int responseSize,
    required DateTime timestamp,
  }) = _CurlTransaction;

  factory CurlTransaction.fromJson(Map<String, dynamic> json) => _$CurlTransactionFromJson(json);
}

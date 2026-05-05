// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curl_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurlTransaction _$CurlTransactionFromJson(Map<String, dynamic> json) =>
    _CurlTransaction(
      id: json['id'] as String,
      request: CurlCommand.fromJson(json['request'] as Map<String, dynamic>),
      statusCode: (json['statusCode'] as num).toInt(),
      responseBody: json['responseBody'] as String,
      latency: Duration(microseconds: (json['latency'] as num).toInt()),
      responseSize: (json['responseSize'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$CurlTransactionToJson(_CurlTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'request': instance.request,
      'statusCode': instance.statusCode,
      'responseBody': instance.responseBody,
      'latency': instance.latency.inMicroseconds,
      'responseSize': instance.responseSize,
      'timestamp': instance.timestamp.toIso8601String(),
    };

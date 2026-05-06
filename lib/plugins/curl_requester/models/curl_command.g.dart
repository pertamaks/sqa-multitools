// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curl_command.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CurlCommand _$CurlCommandFromJson(Map<String, dynamic> json) => _CurlCommand(
  url: json['url'] as String? ?? '',
  method: json['method'] as String? ?? 'GET',
  headers:
      (json['headers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  queryParameters:
      (json['queryParameters'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  inactiveHeaders:
      (json['inactiveHeaders'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ??
      const {},
  inactiveQueryParameters:
      (json['inactiveQueryParameters'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet() ??
      const {},
  body: json['body'] as String? ?? '',
);

Map<String, dynamic> _$CurlCommandToJson(_CurlCommand instance) =>
    <String, dynamic>{
      'url': instance.url,
      'method': instance.method,
      'headers': instance.headers,
      'queryParameters': instance.queryParameters,
      'inactiveHeaders': instance.inactiveHeaders.toList(),
      'inactiveQueryParameters': instance.inactiveQueryParameters.toList(),
      'body': instance.body,
    };

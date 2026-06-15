import 'package:freezed_annotation/freezed_annotation.dart';
import 'form_data_item.dart';

part 'curl_command.freezed.dart';
part 'curl_command.g.dart';

enum BodyType { none, raw, json, urlEncoded, multipartFormData, binaryFile }
enum AuthMethod { none, bearerToken, basicAuth, apiKey }

@freezed
abstract class CurlCommand with _$CurlCommand {
  const factory CurlCommand({
    @Default('') String url,
    @Default('GET') String method,
    @Default({}) Map<String, String> headers,
    @Default({}) Map<String, String> pathParameters,
    @Default({}) Map<String, String> queryParameters,
    @Default({}) Set<String> inactiveHeaders,
    @Default({}) Set<String> inactivePathParameters,
    @Default({}) Set<String> inactiveQueryParameters,
    @Default('') String body,
    @Default(BodyType.raw) BodyType bodyType,
    @Default(AuthMethod.none) AuthMethod authMethod,
    @Default({}) Map<String, String> authData,
    @Default([]) List<FormDataItem> formData,
    @Default([]) List<FormDataItem> urlEncodedData,
  }) = _CurlCommand;

  factory CurlCommand.fromJson(Map<String, dynamic> json) => _$CurlCommandFromJson(json);
}

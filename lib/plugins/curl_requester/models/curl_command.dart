import 'package:freezed_annotation/freezed_annotation.dart';

part 'curl_command.freezed.dart';
part 'curl_command.g.dart';

@freezed
class CurlCommand with _$CurlCommand {
  const factory CurlCommand({
    @Default('') String url,
    @Default('GET') String method,
    @Default({}) Map<String, String> headers,
    @Default({}) Map<String, String> queryParameters,
    @Default('') String body,
  }) = _CurlCommand;

  factory CurlCommand.fromJson(Map<String, dynamic> json) => _$CurlCommandFromJson(json);
}

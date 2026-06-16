import 'package:freezed_annotation/freezed_annotation.dart';

part 'swagger_state.freezed.dart';
part 'swagger_state.g.dart';

enum SwaggerViewMode { list, detail }

@freezed
abstract class SwaggerSecurityScheme with _$SwaggerSecurityScheme {
  const factory SwaggerSecurityScheme({
    required String type, // apiKey, http, oauth2, openIdConnect, basic
    String? description,
    String? name, // Name of the header, query or cookie parameter
    @JsonKey(name: 'in') String? inLocation, // query, header, cookie
    String? scheme, // bearer, basic, etc.
    String? bearerFormat,
  }) = _SwaggerSecurityScheme;

  factory SwaggerSecurityScheme.fromJson(Map<String, dynamic> json) =>
      _$SwaggerSecuritySchemeFromJson(json);
}

@freezed
abstract class SwaggerEndpoint with _$SwaggerEndpoint {
  const factory SwaggerEndpoint({
    required String path,
    required String method,
    required String summary,
    required List<String> tags,
    List<Map<String, dynamic>>? parameters,
    Map<String, dynamic>? requestBody,
    Map<String, dynamic>? responses,
    List<Map<String, List<String>>>? security,
  }) = _SwaggerEndpoint;

  factory SwaggerEndpoint.fromJson(Map<String, dynamic> json) =>
      _$SwaggerEndpointFromJson(json);
}

@freezed
abstract class SwaggerSchemaInfo with _$SwaggerSchemaInfo {
  const factory SwaggerSchemaInfo({
    required String title,
    required String version,
    String? description,
    String? baseUrl,
    @Default({}) Map<String, SwaggerSecurityScheme> securitySchemes,
    @Default([]) List<Map<String, List<String>>> security,
    @Default([]) List<SwaggerEndpoint> endpoints,
  }) = _SwaggerSchemaInfo;

  factory SwaggerSchemaInfo.fromJson(Map<String, dynamic> json) =>
      _$SwaggerSchemaInfoFromJson(json);
}

@freezed
abstract class SwaggerHistoryItem with _$SwaggerHistoryItem {
  const factory SwaggerHistoryItem({
    required String id,
    required String name,
    String? url,
    String? filePath,
    required DateTime lastAccessed,
  }) = _SwaggerHistoryItem;

  factory SwaggerHistoryItem.fromJson(Map<String, dynamic> json) =>
      _$SwaggerHistoryItemFromJson(json);
}

@freezed
abstract class SwaggerState with _$SwaggerState {
  const factory SwaggerState({
    @Default(SwaggerViewMode.list) SwaggerViewMode viewMode,
    @Default([]) List<SwaggerHistoryItem> history,
    SwaggerSchemaInfo? activeSchema,
    @Default(false) bool isLoading,
    String? errorMessage,
    SwaggerEndpoint? activeEndpoint,
    @Default({}) Map<String, String> activeSecurityValues,
  }) = _SwaggerState;

  factory SwaggerState.fromJson(Map<String, dynamic> json) =>
      _$SwaggerStateFromJson(json);
}

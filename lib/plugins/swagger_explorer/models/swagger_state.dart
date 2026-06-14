import 'package:freezed_annotation/freezed_annotation.dart';

part 'swagger_state.freezed.dart';
part 'swagger_state.g.dart';

enum SwaggerViewMode { list, detail }

@freezed
abstract class SwaggerEndpoint with _$SwaggerEndpoint {
  const factory SwaggerEndpoint({
    required String path,
    required String method,
    required String summary,
    required List<String> tags,
    Map<String, dynamic>? parameters,
    Map<String, dynamic>? requestBody,
    Map<String, dynamic>? responses,
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
  }) = _SwaggerState;

  factory SwaggerState.fromJson(Map<String, dynamic> json) =>
      _$SwaggerStateFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SwaggerEndpoint _$SwaggerEndpointFromJson(Map<String, dynamic> json) =>
    _SwaggerEndpoint(
      path: json['path'] as String,
      method: json['method'] as String,
      summary: json['summary'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      parameters: json['parameters'] as Map<String, dynamic>?,
      requestBody: json['requestBody'] as Map<String, dynamic>?,
      responses: json['responses'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SwaggerEndpointToJson(_SwaggerEndpoint instance) =>
    <String, dynamic>{
      'path': instance.path,
      'method': instance.method,
      'summary': instance.summary,
      'tags': instance.tags,
      'parameters': instance.parameters,
      'requestBody': instance.requestBody,
      'responses': instance.responses,
    };

_SwaggerSchemaInfo _$SwaggerSchemaInfoFromJson(Map<String, dynamic> json) =>
    _SwaggerSchemaInfo(
      title: json['title'] as String,
      version: json['version'] as String,
      description: json['description'] as String?,
      baseUrl: json['baseUrl'] as String?,
      endpoints:
          (json['endpoints'] as List<dynamic>?)
              ?.map((e) => SwaggerEndpoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SwaggerSchemaInfoToJson(_SwaggerSchemaInfo instance) =>
    <String, dynamic>{
      'title': instance.title,
      'version': instance.version,
      'description': instance.description,
      'baseUrl': instance.baseUrl,
      'endpoints': instance.endpoints,
    };

_SwaggerHistoryItem _$SwaggerHistoryItemFromJson(Map<String, dynamic> json) =>
    _SwaggerHistoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String?,
      filePath: json['filePath'] as String?,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
    );

Map<String, dynamic> _$SwaggerHistoryItemToJson(_SwaggerHistoryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'url': instance.url,
      'filePath': instance.filePath,
      'lastAccessed': instance.lastAccessed.toIso8601String(),
    };

_SwaggerState _$SwaggerStateFromJson(Map<String, dynamic> json) =>
    _SwaggerState(
      viewMode:
          $enumDecodeNullable(_$SwaggerViewModeEnumMap, json['viewMode']) ??
          SwaggerViewMode.list,
      history:
          (json['history'] as List<dynamic>?)
              ?.map(
                (e) => SwaggerHistoryItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      activeSchema: json['activeSchema'] == null
          ? null
          : SwaggerSchemaInfo.fromJson(
              json['activeSchema'] as Map<String, dynamic>,
            ),
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      activeEndpoint: json['activeEndpoint'] == null
          ? null
          : SwaggerEndpoint.fromJson(
              json['activeEndpoint'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$SwaggerStateToJson(_SwaggerState instance) =>
    <String, dynamic>{
      'viewMode': _$SwaggerViewModeEnumMap[instance.viewMode]!,
      'history': instance.history,
      'activeSchema': instance.activeSchema,
      'isLoading': instance.isLoading,
      'errorMessage': instance.errorMessage,
      'activeEndpoint': instance.activeEndpoint,
    };

const _$SwaggerViewModeEnumMap = {
  SwaggerViewMode.list: 'list',
  SwaggerViewMode.detail: 'detail',
};

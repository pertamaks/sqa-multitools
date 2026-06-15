// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Environment _$EnvironmentFromJson(Map<String, dynamic> json) => _Environment(
  id: json['id'] as String,
  name: json['name'] as String? ?? 'New Environment',
  variables:
      (json['variables'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
);

Map<String, dynamic> _$EnvironmentToJson(_Environment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'variables': instance.variables,
    };

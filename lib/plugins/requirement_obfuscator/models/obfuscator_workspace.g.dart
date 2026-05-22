// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'obfuscator_workspace.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ObfuscatorWorkspace _$ObfuscatorWorkspaceFromJson(Map<String, dynamic> json) =>
    _ObfuscatorWorkspace(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      strategy:
          $enumDecodeNullable(
            _$SubstitutionStrategyEnumMap,
            json['strategy'],
          ) ??
          SubstitutionStrategy.semantic,
      dictionarySize: (json['dictionarySize'] as num?)?.toInt() ?? 0,
      totalProcessed: (json['totalProcessed'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ObfuscatorWorkspaceToJson(
  _ObfuscatorWorkspace instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'createdAt': instance.createdAt.toIso8601String(),
  'strategy': _$SubstitutionStrategyEnumMap[instance.strategy]!,
  'dictionarySize': instance.dictionarySize,
  'totalProcessed': instance.totalProcessed,
};

const _$SubstitutionStrategyEnumMap = {
  SubstitutionStrategy.semantic: 'semantic',
  SubstitutionStrategy.token: 'token',
  SubstitutionStrategy.codename: 'codename',
};

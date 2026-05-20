// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DictionaryEntry _$DictionaryEntryFromJson(Map<String, dynamic> json) =>
    _DictionaryEntry(
      id: json['id'] as String,
      original: json['original'] as String,
      replacement: json['replacement'] as String,
      category:
          $enumDecodeNullable(_$EntryCategoryEnumMap, json['category']) ??
          EntryCategory.general,
      variants:
          (json['variants'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$DictionaryEntryToJson(_DictionaryEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'original': instance.original,
      'replacement': instance.replacement,
      'category': _$EntryCategoryEnumMap[instance.category]!,
      'variants': instance.variants,
      'enabled': instance.enabled,
    };

const _$EntryCategoryEnumMap = {
  EntryCategory.model: 'model',
  EntryCategory.field: 'field',
  EntryCategory.endpoint: 'endpoint',
  EntryCategory.service: 'service',
  EntryCategory.config: 'config',
  EntryCategory.general: 'general',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'md_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MdDocument _$MdDocumentFromJson(Map<String, dynamic> json) => _MdDocument(
  id: json['id'] as String,
  name: json['name'] as String,
  content: json['content'] as String,
  lastModified: DateTime.parse(json['lastModified'] as String),
  templateType:
      $enumDecodeNullable(_$MdTemplateTypeEnumMap, json['templateType']) ??
      MdTemplateType.empty,
);

Map<String, dynamic> _$MdDocumentToJson(_MdDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'content': instance.content,
      'lastModified': instance.lastModified.toIso8601String(),
      'templateType': _$MdTemplateTypeEnumMap[instance.templateType]!,
    };

const _$MdTemplateTypeEnumMap = {
  MdTemplateType.empty: 'empty',
  MdTemplateType.bugReport: 'bugReport',
  MdTemplateType.devTicket: 'devTicket',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TextDocument _$TextDocumentFromJson(Map<String, dynamic> json) =>
    _TextDocument(
      id: json['id'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
      templateType:
          $enumDecodeNullable(
            _$TextTemplateTypeEnumMap,
            json['templateType'],
          ) ??
          TextTemplateType.empty,
      isPinned: json['isPinned'] as bool? ?? false,
    );

Map<String, dynamic> _$TextDocumentToJson(_TextDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'content': instance.content,
      'lastModified': instance.lastModified.toIso8601String(),
      'templateType': _$TextTemplateTypeEnumMap[instance.templateType]!,
      'isPinned': instance.isPinned,
    };

const _$TextTemplateTypeEnumMap = {
  TextTemplateType.empty: 'empty',
  TextTemplateType.bugReport: 'bugReport',
  TextTemplateType.devTicket: 'devTicket',
};

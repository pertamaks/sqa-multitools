// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'imported_document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImportedDocument _$ImportedDocumentFromJson(Map<String, dynamic> json) =>
    _ImportedDocument(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      content: json['content'] as String,
      importedAt: DateTime.parse(json['importedAt'] as String),
      matchedTerms: (json['matchedTerms'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ImportedDocumentToJson(_ImportedDocument instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fileName': instance.fileName,
      'content': instance.content,
      'importedAt': instance.importedAt.toIso8601String(),
      'matchedTerms': instance.matchedTerms,
    };

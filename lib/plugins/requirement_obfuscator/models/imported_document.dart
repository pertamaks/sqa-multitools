import 'package:freezed_annotation/freezed_annotation.dart';

part 'imported_document.freezed.dart';
part 'imported_document.g.dart';

@freezed
abstract class ImportedDocument with _$ImportedDocument {
  const factory ImportedDocument({
    required String id,
    required String fileName,
    required String content,
    required DateTime importedAt,
    @Default(0) int matchedTerms,
  }) = _ImportedDocument;

  factory ImportedDocument.fromJson(Map<String, dynamic> json) =>
      _$ImportedDocumentFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_document.freezed.dart';
part 'text_document.g.dart';

enum TextTemplateType {
  empty,
  bugReport,
  devTicket,
}

@freezed
abstract class TextDocument with _$TextDocument {
  const factory TextDocument({
    required String id,
    required String name,
    required String content,
    required DateTime lastModified,
    @Default(TextTemplateType.empty) TextTemplateType templateType,
    @Default(false) bool isPinned,
  }) = _TextDocument;

  factory TextDocument.fromJson(Map<String, dynamic> json) =>
      _$TextDocumentFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'md_document.freezed.dart';
part 'md_document.g.dart';

enum MdTemplateType {
  empty,
  bugReport,
  devTicket,
}

@freezed
abstract class MdDocument with _$MdDocument {
  const factory MdDocument({
    required String id,
    required String name,
    required String content,
    required DateTime lastModified,
    @Default(MdTemplateType.empty) MdTemplateType templateType,
  }) = _MdDocument;

  factory MdDocument.fromJson(Map<String, dynamic> json) =>
      _$MdDocumentFromJson(json);
}

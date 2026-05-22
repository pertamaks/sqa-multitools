import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_state.freezed.dart';

enum TextType { bytes, sentence, paragraph, chapter }

extension TextTypeExtension on TextType {
  String get label {
    switch (this) {
      case TextType.bytes: return 'Bytes';
      case TextType.sentence: return 'Sentences';
      case TextType.paragraph: return 'Paragraphs';
      case TextType.chapter: return 'Chapters';
    }
  }
}

@freezed
abstract class TextState with _$TextState {
  const factory TextState({
    @Default(TextType.bytes) TextType selectedType,
    @Default(100) int size,
    @Default(<TextType, List<List<String>>>{})
    Map<TextType, List<List<String>>> resultsMap,
    @Default(true) bool includeFormatting,
  }) = _TextState;
}

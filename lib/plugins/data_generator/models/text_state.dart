import 'package:freezed_annotation/freezed_annotation.dart';

part 'text_state.freezed.dart';

enum TextType { bytes, sentence, paragraph, chapter }

@freezed
abstract class TextState with _$TextState {
  const factory TextState({
    @Default(TextType.bytes) TextType selectedType,
    @Default(100) int size,
    @Default({}) Map<TextType, List<String>> resultsMap,
    @Default(true) bool includeFormatting,
  }) = _TextState;
}

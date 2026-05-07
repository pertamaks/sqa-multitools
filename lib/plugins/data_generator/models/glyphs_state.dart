import 'package:freezed_annotation/freezed_annotation.dart';
import 'text_state.dart';

part 'glyphs_state.freezed.dart';

enum GlyphsCategory { specials, japanese, chinese, arabic, vietnamese }

@freezed
abstract class GlyphsState with _$GlyphsState {
  const factory GlyphsState({
    @Default(GlyphsCategory.specials) GlyphsCategory selectedCategory,
    @Default(TextType.bytes) TextType selectedType,
    @Default(100) int size,
    @Default({}) Map<GlyphsCategory, List<String>> resultsMap,
  }) = _GlyphsState;
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'text_state.dart';

part 'glyphs_state.freezed.dart';

enum GlyphsCategory { specials, japanese, chinese, arabic, vietnamese }

extension GlyphsCategoryExtension on GlyphsCategory {
  String get label {
    switch (this) {
      case GlyphsCategory.specials: return 'Specials';
      case GlyphsCategory.japanese: return 'Japanese';
      case GlyphsCategory.chinese: return 'Chinese';
      case GlyphsCategory.arabic: return 'Arabic';
      case GlyphsCategory.vietnamese: return 'Vietnamese';
    }
  }
}

@freezed
abstract class GlyphsState with _$GlyphsState {
  const factory GlyphsState({
    @Default(GlyphsCategory.specials) GlyphsCategory selectedCategory,
    @Default(TextType.bytes) TextType selectedType,
    @Default(100) int size,
    @Default(<GlyphsCategory, List<List<String>>>{})
    Map<GlyphsCategory, List<List<String>>> resultsMap,
  }) = _GlyphsState;
}

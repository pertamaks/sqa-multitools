import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:faker_dart/faker_dart.dart';
import '../models/glyphs_state.dart';
import '../models/text_state.dart';
import 'identity_provider.dart';
import '../../../core/utils/localized_lorem_data.dart';

part 'glyphs_provider.g.dart';

@Riverpod(keepAlive: true)
class GlyphsGenerator extends _$GlyphsGenerator {
  late Faker _faker;
  final Random _random = Random();

  @override
  GlyphsState build() {
    _faker = Faker.instance;
    return const GlyphsState(resultsMap: <GlyphsCategory, List<List<String>>>{});
  }

  void setCategory(GlyphsCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setType(TextType type) {
    state = state.copyWith(selectedType: type);
  }

  void setSize(int size) {
    state = state.copyWith(size: size);
  }

  void clear() {
    state = state.copyWith(
      resultsMap: <GlyphsCategory, List<List<String>>>{
        ...state.resultsMap,
        state.selectedCategory: <List<String>>[],
      },
    );
  }

  void generate() {
    const count = 1;
    // ignore: unused_local_variable
    final identityState = ref.read(identityProvider);

    final List<String> currentGeneration = [];
    for (int i = 0; i < count; i++) {
      currentGeneration.add(_generateSingle());
    }

    final currentHistory = List<List<String>>.from(state.resultsMap[state.selectedCategory] ?? []);
    final newHistory = [currentGeneration, ...currentHistory];

    if (newHistory.length > 10) {
      newHistory.removeRange(10, newHistory.length);
    }

    state = state.copyWith(
      resultsMap: <GlyphsCategory, List<List<String>>>{
        ...state.resultsMap,
        state.selectedCategory: newHistory,
      },
    );
  }

  void removeHistory(List<String> session) {
    final currentHistory = List<List<String>>.from(state.resultsMap[state.selectedCategory] ?? []);
    currentHistory.remove(session);
    state = state.copyWith(
      resultsMap: <GlyphsCategory, List<List<String>>>{
        ...state.resultsMap,
        state.selectedCategory: currentHistory,
      },
    );
  }

  String _generateSingle() {
    if (state.selectedCategory == GlyphsCategory.specials) {
      return _generateSpecials();
    }

    // Locale-based logic
    if (state.selectedCategory == GlyphsCategory.chinese) {
      return _generateManual(LocalizedLoremData.chineseChars, useSpaces: false);
    }
    if (state.selectedCategory == GlyphsCategory.arabic) {
      return _generateManual(LocalizedLoremData.arabicWords, useSpaces: true);
    }

    final locale = _getLocaleFromCategory(state.selectedCategory);
    _faker.setLocale(locale);

    switch (state.selectedType) {
      case TextType.bytes:
        String buffer = '';
        while (buffer.length < state.size) {
          buffer += '${_faker.lorem.paragraph(sentenceCount: 5)} ';
        }
        return buffer.substring(0, state.size).trim();

      case TextType.sentence:
        return _faker.lorem.sentence(wordCount: state.size);

      case TextType.paragraph:
        return _faker.lorem.paragraph(sentenceCount: state.size);

      case TextType.chapter:
        final List<String> paragraphs = [];
        for (int j = 0; j < state.size; j++) {
          paragraphs.add(_faker.lorem.paragraph(sentenceCount: 5));
        }
        final prefix = _getCategoryPrefix(state.selectedCategory);
        return '$prefix:\n\n${paragraphs.join('\n\n')}';
    }
  }

  String _generateManual(List<String> source, {required bool useSpaces}) {
    switch (state.selectedType) {
      case TextType.bytes:
        String buffer = '';
        while (buffer.length < state.size) {
          buffer += source[_random.nextInt(source.length)];
          if (useSpaces && buffer.length < state.size) buffer += ' ';
        }
        return buffer.substring(0, state.size).trim();

      case TextType.sentence:
        return _generateItems(source, state.size, useSpaces: useSpaces);

      case TextType.paragraph:
        final List<String> sentences = [];
        for (int i = 0; i < state.size; i++) {
          sentences.add(_generateItems(source, 10, useSpaces: useSpaces));
        }
        return sentences.join(useSpaces ? '. ' : '。');

      case TextType.chapter:
        final List<String> paragraphs = [];
        for (int i = 0; i < state.size; i++) {
          final List<String> sentences = [];
          for (int j = 0; j < 5; j++) {
            sentences.add(_generateItems(source, 10, useSpaces: useSpaces));
          }
          paragraphs.add(sentences.join(useSpaces ? '. ' : '。'));
        }
        final prefix = _getCategoryPrefix(state.selectedCategory);
        return '$prefix:\n\n${paragraphs.join('\n\n')}';
    }
  }

  String _generateItems(
    List<String> source,
    int count, {
    required bool useSpaces,
  }) {
    final List<String> items = [];
    for (int i = 0; i < count; i++) {
      items.add(source[_random.nextInt(source.length)]);
    }
    return items.join(useSpaces ? ' ' : '');
  }

  String _generateSpecials() {
    const chars = r"!@#$%^&*()_+{}|:<>?~-=[]\ ;',./";
    if (state.selectedType == TextType.bytes) {
      return List.generate(
        state.size,
        (_) => chars[_random.nextInt(chars.length)],
      ).join();
    } else {
      int count = state.size;
      if (state.selectedType == TextType.sentence) count *= 5;
      if (state.selectedType == TextType.paragraph) count *= 25;
      if (state.selectedType == TextType.chapter) count *= 100;

      return List.generate(
        count,
        (_) => chars[_random.nextInt(chars.length)],
      ).join();
    }
  }

  FakerLocaleType _getLocaleFromCategory(GlyphsCategory category) {
    switch (category) {
      case GlyphsCategory.japanese:
        return FakerLocaleType.ja;
      case GlyphsCategory.chinese:
        return FakerLocaleType.zh_CN;
      case GlyphsCategory.arabic:
        return FakerLocaleType.ar;
      case GlyphsCategory.vietnamese:
        return FakerLocaleType.vi;
      case GlyphsCategory.specials:
        return FakerLocaleType.en_US;
    }
  }

  String _getCategoryPrefix(GlyphsCategory category) {
    switch (category) {
      case GlyphsCategory.japanese:
        return '日本語 (JA)';
      case GlyphsCategory.chinese:
        return '中文 (ZH)';
      case GlyphsCategory.arabic:
        return 'العربية (AR)';
      case GlyphsCategory.vietnamese:
        return 'Tiếng Việt (VI)';
      case GlyphsCategory.specials:
        return 'SPECIALS';
    }
  }
}

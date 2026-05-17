import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:faker_dart/faker_dart.dart';
import '../models/text_state.dart';
import 'identity_provider.dart';

part 'text_provider.g.dart';

@Riverpod(keepAlive: true)
class TextGenerator extends _$TextGenerator {
  late Faker _faker;

  @override
  TextState build() {
    _faker = Faker.instance;
    return const TextState(resultsMap: <TextType, List<List<String>>>{});
  }

  void setType(TextType type) {
    // Default sizes for new types to be sensible
    int newSize = state.size;
    if (type == TextType.bytes && state.selectedType != TextType.bytes) {
      newSize = 500;
    } else if (type == TextType.sentence &&
        state.selectedType != TextType.sentence) {
      newSize = 12; // 12 words
    } else if (type == TextType.paragraph &&
        state.selectedType != TextType.paragraph) {
      newSize = 5; // 5 sentences
    } else if (type == TextType.chapter &&
        state.selectedType != TextType.chapter) {
      newSize = 6; // 6 paragraphs
    }

    state = state.copyWith(selectedType: type, size: newSize);
  }

  void setSize(int size) {
    state = state.copyWith(size: size);
  }

  void clear() {
    state = state.copyWith(
      resultsMap: <TextType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: <List<String>>[],
      },
    );
  }

  void generate() {
    final identityState = ref.read(identityProvider);
    const count = 1;
    final locale = identityState.locale;

    _faker.setLocale(locale);

    final List<String> currentGeneration = [];
    for (int i = 0; i < count; i++) {
      currentGeneration.add(_generateSingle());
    }

    final currentHistory = List<List<String>>.from(state.resultsMap[state.selectedType] ?? []);
    final newHistory = [currentGeneration, ...currentHistory];

    if (newHistory.length > 10) {
      newHistory.removeRange(10, newHistory.length);
    }

    state = state.copyWith(
      resultsMap: <TextType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: newHistory,
      },
    );
  }

  void removeHistory(List<String> session) {
    final currentHistory = List<List<String>>.from(state.resultsMap[state.selectedType] ?? []);
    currentHistory.remove(session);
    state = state.copyWith(
      resultsMap: <TextType, List<List<String>>>{
        ...state.resultsMap,
        state.selectedType: currentHistory,
      },
    );
  }

  String _generateSingle() {
    switch (state.selectedType) {
      case TextType.bytes:
        // Generate enough text to cover the byte count
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
        final title = _faker.lorem
            .sentence(wordCount: 3)
            .replaceAll('.', '')
            .toUpperCase();
        return 'CHAPTER: $title\n\n${paragraphs.join('\n\n')}';
    }
  }
}

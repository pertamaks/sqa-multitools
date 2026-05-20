import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictionary_entry.freezed.dart';
part 'dictionary_entry.g.dart';

enum EntryCategory { model, field, endpoint, service, config, general }

@freezed
abstract class DictionaryEntry with _$DictionaryEntry {
  const factory DictionaryEntry({
    required String id,
    required String original,
    required String replacement,
    @Default(EntryCategory.general) EntryCategory category,
    @Default({}) Map<String, String> variants,
    @Default(true) bool enabled,
  }) = _DictionaryEntry;

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) =>
      _$DictionaryEntryFromJson(json);
}

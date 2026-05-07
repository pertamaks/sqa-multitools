import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/cheatsheet_models.dart';
import '../utils/cheatsheet_parser.dart';

part 'cheatsheet_provider.g.dart';

@riverpod
Future<String> cheatsheetRaw(Ref ref) async {
  return await rootBundle.loadString('assets/qa_cheatsheet_comp.md');
}

@riverpod
Future<List<CheatsheetCategory>> cheatsheetData(Ref ref) async {
  final raw = await ref.watch(cheatsheetRawProvider.future);
  return CheatsheetParser.parse(raw);
}

@Riverpod(keepAlive: true)
class CheatsheetSearch extends _$CheatsheetSearch {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

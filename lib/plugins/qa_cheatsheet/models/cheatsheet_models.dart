import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cheatsheet_models.freezed.dart';

@freezed
abstract class CheatsheetCategory with _$CheatsheetCategory {
  const factory CheatsheetCategory({
    required String name,
    required String description,
    required IconData icon,
    required List<CheatsheetSection> sections,
  }) = _CheatsheetCategory;
}

@freezed
abstract class CheatsheetSection with _$CheatsheetSection {
  const factory CheatsheetSection({
    required String id,
    required String title,
    required IconData icon,
    required String markdown,
  }) = _CheatsheetSection;
}

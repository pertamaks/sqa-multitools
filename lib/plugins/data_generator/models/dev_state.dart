import 'package:freezed_annotation/freezed_annotation.dart';

part 'dev_state.freezed.dart';

enum DevType { uuid, json, date }

extension DevTypeExtension on DevType {
  String get label {
    switch (this) {
      case DevType.uuid: return 'UUID';
      case DevType.json: return 'JSON';
      case DevType.date: return 'Date';
    }
  }
}

enum JsonCategory { simple, medium, complex }

enum DateCategory { past, future }

@freezed
abstract class DevState with _$DevState {
  const factory DevState({
    @Default(DevType.uuid) DevType selectedType,
    @Default(JsonCategory.simple) JsonCategory selectedJsonCategory,
    @Default(DateCategory.past) DateCategory selectedDateCategory,
    @Default(<DevType, List<List<String>>>{})
    Map<DevType, List<List<String>>> resultsMap,
    @Default([]) List<String> uuidHistory,
    @Default(1) int quantity,
    @Default(true) bool includeFormatting,
  }) = _DevState;
}

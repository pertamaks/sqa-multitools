import 'package:freezed_annotation/freezed_annotation.dart';

part 'dev_state.freezed.dart';

enum DevType { uuid, json, date }

enum JsonCategory { simple, medium, complex }

enum DateCategory { past, future }

@freezed
abstract class DevState with _$DevState {
  const factory DevState({
    @Default(DevType.uuid) DevType selectedType,
    @Default(JsonCategory.simple) JsonCategory selectedJsonCategory,
    @Default(DateCategory.past) DateCategory selectedDateCategory,
    @Default({}) Map<DevType, List<String>> resultsMap,
    @Default([]) List<String> uuidHistory,
    @Default(1) int quantity,
  }) = _DevState;
}

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'color_picker_state.freezed.dart';

@freezed
abstract class ColorPickerState with _$ColorPickerState {
  const factory ColorPickerState({
    required Color activeColor,
    @Default([]) List<Color> history,
  }) = _ColorPickerState;
}

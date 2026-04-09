import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqa_multitools/plugins/color_picker/models/color_picker_state.dart';

part 'color_picker_provider.g.dart';

@riverpod
class ColorPickerNotifier extends _$ColorPickerNotifier {
  @override
  ColorPickerState build() {
    return const ColorPickerState(
      activeColor: Color(0xFF2AE4EB),
      history: [
        Color(0xFF2AE4EB),
        Color(0xFF3F4E5B),
        Color(0xFF2A2A2A),
        Color(0xFF3A3A3A),
      ],
    );
  }

  void updateColor(Color color) {
    var newHistory = [state.activeColor, ...state.history];
    if (newHistory.length > 10) {
      newHistory = newHistory.sublist(0, 10);
    }
    state = state.copyWith(activeColor: color, history: newHistory);
  }
}

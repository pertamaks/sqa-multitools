import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/plugins/color_picker/providers/color_picker_provider.dart';

void main() {
  test('ColorPickerNotifier updates color and history', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(colorPickerProvider.notifier);
    final initialState = container.read(colorPickerProvider);

    expect(initialState.activeColor, const Color(0xFF2AE4EB));
    expect(initialState.history.length, 4);

    const newColor = Color(0xFFFF0000);
    notifier.updateColor(newColor);

    final updatedState = container.read(colorPickerProvider);
    expect(updatedState.activeColor, newColor);
    expect(updatedState.history.first, const Color(0xFF2AE4EB));
    expect(updatedState.history.length, 5);
  });
}

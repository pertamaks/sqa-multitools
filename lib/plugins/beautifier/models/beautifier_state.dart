import 'package:freezed_annotation/freezed_annotation.dart';
import '../widgets/beautifier_highlighter.dart';

part 'beautifier_state.freezed.dart';

@freezed
abstract class BeautifierState with _$BeautifierState {
  const factory BeautifierState({
    @Default('') String input,
    @Default('') String output,
    @Default(BeautifierLanguage.json) BeautifierLanguage language,
    @Default(true) bool autoFormat,
    @Default(true) bool inputWrapText,
    @Default(true) bool outputWrapText,
    @Default(false) bool isLoading,
    @Default(2) int indentWidth,
    String? error,
  }) = _BeautifierState;
}

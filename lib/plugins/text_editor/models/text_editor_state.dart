import 'package:freezed_annotation/freezed_annotation.dart';
import 'text_document.dart';

part 'text_editor_state.freezed.dart';

enum TextEditorViewMode { list, editor, viewer }

@freezed
abstract class TextEditorState with _$TextEditorState {
  const factory TextEditorState({
    @Default([]) List<TextDocument> documents,
    TextDocument? activeDocument,
    @Default(TextEditorViewMode.list) TextEditorViewMode viewMode,
    @Default(false) bool isSaving,
    @Default(false) bool isLoading,
    @Default(false) bool hasUnsavedChanges,
    String? errorMessage,
    String? savePath,
    @Default('') String searchQuery,
  }) = _TextEditorState;
}

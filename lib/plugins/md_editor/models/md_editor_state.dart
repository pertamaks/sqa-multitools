import 'package:freezed_annotation/freezed_annotation.dart';
import 'md_document.dart';

part 'md_editor_state.freezed.dart';

enum MdEditorViewMode {
  list,
  editor,
}

@freezed
abstract class MdEditorState with _$MdEditorState {
  const factory MdEditorState({
    @Default([]) List<MdDocument> documents,
    MdDocument? activeDocument,
    @Default(MdEditorViewMode.list) MdEditorViewMode viewMode,
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _MdEditorState;
}

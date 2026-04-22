import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/md_document.dart';
import '../models/md_editor_state.dart';

part 'md_editor_provider.g.dart';

@riverpod
class MdEditor extends _$MdEditor {
  @override
  MdEditorState build() {
    return const MdEditorState();
  }

  void setViewMode(MdEditorViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void openEditor(MdDocument? document) {
    state = state.copyWith(
      activeDocument: document,
      viewMode: MdEditorViewMode.editor,
    );
  }


  void createFromTemplate(MdTemplateType type) {
    final String initialContent;
    final String name;

    switch (type) {
      case MdTemplateType.bugReport:
        name = "Bug Report ${DateTime.now().millisecond}";
        initialContent = """# Bug Report
## Summary
(Brief description)

## Steps to Reproduce
1. 
2. 

## Expected Result
- 

## Actual Result
- 

## Logs/Screenshots
- """;
        break;
      case MdTemplateType.devTicket:
        name = "Dev Ticket ${DateTime.now().millisecond}";
        initialContent = """# Development Ticket
## Summary
(Goal)

## Requirements
- 

## Acceptance Criteria
- [ ] """;
        break;
      case MdTemplateType.empty:
        name = "Untitled ${DateTime.now().millisecond}";
        initialContent = "";
        break;
    }

    final newDoc = MdDocument(
      id: const Uuid().v4(),
      name: name,
      content: initialContent,
      lastModified: DateTime.now(),
      templateType: type,
    );

    state = state.copyWith(
      activeDocument: newDoc,
      viewMode: MdEditorViewMode.editor,
    );
  }

  void updateContent(String content) {
    if (state.activeDocument == null) return;
    state = state.copyWith(
      activeDocument: state.activeDocument!.copyWith(
        content: content,
        lastModified: DateTime.now(),
      ),
    );
  }

  Future<void> saveDocument() async {
    if (state.activeDocument == null) return;
    
    state = state.copyWith(isSaving: true);
    
    // TODO: Implement actual file saving
    await Future<void>.delayed(const Duration(milliseconds: 500));
    
    final updatedDocs = [...state.documents];
    final index = updatedDocs.indexWhere((d) => d.id == state.activeDocument!.id);
    
    if (index != -1) {
      updatedDocs[index] = state.activeDocument!;
    } else {
      updatedDocs.add(state.activeDocument!);
    }

    state = state.copyWith(
      documents: updatedDocs,
      isSaving: false,
    );
    
    setViewMode(MdEditorViewMode.list);
  }

  void deleteDocument(String id) {
    state = state.copyWith(
      documents: state.documents.where((d) => d.id != id).toList(),
    );
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/text_document.dart';
import '../models/text_editor_state.dart';

part 'text_editor_provider.g.dart';

@riverpod
class TextEditor extends _$TextEditor {
  @override
  TextEditorState build() {
    return const TextEditorState();
  }

  void setViewMode(TextEditorViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void openEditor(TextDocument? document) {
    state = state.copyWith(
      activeDocument: document,
      viewMode: TextEditorViewMode.editor,
    );
  }

  void createFromTemplate(TextTemplateType type) {
    final String initialContent;
    final String name;

    switch (type) {
      case TextTemplateType.bugReport:
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
      case TextTemplateType.devTicket:
        name = "Dev Ticket ${DateTime.now().millisecond}";
        initialContent = """# Development Ticket
## Summary
(Goal)

## Requirements
- 

## Acceptance Criteria
- [ ] """;
        break;
      case TextTemplateType.empty:
        name = "Untitled ${DateTime.now().millisecond}";
        initialContent = "";
        break;
    }

    final newDoc = TextDocument(
      id: const Uuid().v4(),
      name: name,
      content: initialContent,
      lastModified: DateTime.now(),
      templateType: type,
    );

    state = state.copyWith(
      activeDocument: newDoc,
      viewMode: TextEditorViewMode.editor,
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

  void updateName(String name) {
    if (state.activeDocument == null) return;
    if (state.activeDocument!.name == name) return;
    state = state.copyWith(
      activeDocument: state.activeDocument!.copyWith(
        name: name,
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
      documents: _sortDocuments(updatedDocs),
      isSaving: false,
    );
    
    setViewMode(TextEditorViewMode.list);
  }

  void deleteDocument(String id) {
    state = state.copyWith(
      documents: state.documents.where((d) => d.id != id).toList(),
    );
  }

  void togglePin(String id) {
    final updatedDocs = state.documents.map((doc) {
      if (doc.id == id) {
        return doc.copyWith(isPinned: !doc.isPinned);
      }
      return doc;
    }).toList();

    state = state.copyWith(documents: _sortDocuments(updatedDocs));
  }

  List<TextDocument> _sortDocuments(List<TextDocument> docs) {
    final sorted = List<TextDocument>.from(docs);
    sorted.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.lastModified.compareTo(a.lastModified);
    });
    return sorted;
  }
}

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/text_document.dart';
import '../models/text_editor_state.dart';
import '../services/storage_service.dart';

part 'text_editor_provider.g.dart';

@riverpod
class TextEditor extends _$TextEditor {
  final _storage = TextEditorStorageService();
  Timer? _autoSaveTimer;

  @override
  TextEditorState build() {
    ref.onDispose(() => _autoSaveTimer?.cancel());
    // Initial data refresh
    Future.microtask(() => initialize());
    return const TextEditorState();
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);
    final docs = await _storage.loadAllDocuments();
    state = state.copyWith(
      documents: _sortDocuments(docs),
      isLoading: false,
    );
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
    if (state.activeDocument!.content == content) return;

    state = state.copyWith(
      activeDocument: state.activeDocument!.copyWith(
        content: content,
        lastModified: DateTime.now(),
      ),
    );
    _debouncedSave();
  }

  void updateName(String name) {
    if (state.activeDocument == null) return;
    if (state.activeDocument!.name == name) return;

    final oldName = state.activeDocument!.name;
    state = state.copyWith(
      activeDocument: state.activeDocument!.copyWith(
        name: name,
        lastModified: DateTime.now(),
      ),
    );
    // Renaming should be saved immediately to avoid file system confusion
    saveDocument(oldName: oldName);
  }

  void _debouncedSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 1), () {
      saveDocument();
    });
  }

  Future<void> saveDocument({String? oldName, bool navigateToList = false}) async {
    final doc = state.activeDocument;
    if (doc == null) return;
    
    state = state.copyWith(isSaving: true);
    
    try {
      await _storage.saveDocument(doc, oldName: oldName);
      
      final updatedDocs = [...state.documents];
      final index = updatedDocs.indexWhere((d) => d.id == doc.id);
      
      if (index != -1) {
        updatedDocs[index] = doc;
      } else {
        updatedDocs.add(doc);
      }

      state = state.copyWith(
        documents: _sortDocuments(updatedDocs),
        isSaving: false,
      );
      
      if (navigateToList) {
        setViewMode(TextEditorViewMode.list);
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save: $e',
      );
    }
  }

  Future<void> deleteDocument(String id) async {
    final doc = state.documents.firstWhere((d) => d.id == id);
    try {
      await _storage.deleteDocument(id, doc.name);
      state = state.copyWith(
        documents: state.documents.where((d) => d.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete: $e');
    }
  }

  Future<void> copyContent(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }

  void togglePin(String id) {
    final updatedDocs = state.documents.map((doc) {
      if (doc.id == id) {
        final newDoc = doc.copyWith(isPinned: !doc.isPinned);
        // Save the pinned status change
        _storage.saveDocument(newDoc);
        return newDoc;
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


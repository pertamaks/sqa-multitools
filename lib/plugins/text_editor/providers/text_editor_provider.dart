import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/preferences_service.dart';
import '../models/text_document.dart';
import '../models/text_editor_state.dart';
import '../services/storage_service.dart';

part 'text_editor_provider.g.dart';

@riverpod
List<TextDocument> filteredDocuments(Ref ref) {
  final TextEditorState state = ref.watch(textEditorProvider);
  final String query = state.searchQuery.toLowerCase();
  if (query.isEmpty) {
    return state.documents;
  }
  return state.documents.where((TextDocument doc) {
    return doc.name.toLowerCase().contains(query) ||
        doc.content.toLowerCase().contains(query);
  }).toList();
}

@riverpod
class TextEditor extends _$TextEditor {
  TextEditorStorageService get _storage =>
      TextEditorStorageService(customBasePath: state.savePath);
  Timer? _autoSaveTimer;
  Timer? _searchDebounce;

  @override
  TextEditorState build() {
    final prefs = ref.watch(preferencesServiceProvider);
    final savedPath = prefs.getTextEditorSaveDir();

    ref.onDispose(() {
      _autoSaveTimer?.cancel();
      _searchDebounce?.cancel();
    });
    // Initial data refresh
    Future.microtask(() => initialize());
    return TextEditorState(savePath: savedPath);
  }

  void setSearchQuery(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      state = state.copyWith(searchQuery: query);
    });
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    // Resolve save path if null (use default from storage service)
    if (state.savePath == null || state.savePath!.isEmpty) {
      final dir = await _storage.storageDir;
      state = state.copyWith(savePath: dir.path);
    }

    final docs = await _storage.loadAllDocuments();
    state = state.copyWith(documents: _sortDocuments(docs), isLoading: false);
  }

  void setViewMode(TextEditorViewMode mode) {
    state = state.copyWith(viewMode: mode);
    if (mode == TextEditorViewMode.list) {
      initialize();
    }
  }

  Future<void> openEditor(TextDocument? document) async {
    state = state.copyWith(isLoading: true);
    // Brief delay to allow the circle loading to be visible and ensure a smooth transition
    await Future<void>.delayed(const Duration(milliseconds: 150));
    state = state.copyWith(
      activeDocument: document,
      viewMode: TextEditorViewMode.editor,
      hasUnsavedChanges: false,
      isLoading: false,
    );
  }

  Future<void> viewDocument(TextDocument document) async {
    state = state.copyWith(isLoading: true);
    // Brief delay for the loading circle to appear during high-fidelity rendering preparation
    await Future<void>.delayed(const Duration(milliseconds: 150));
    state = state.copyWith(
      activeDocument: document,
      viewMode: TextEditorViewMode.viewer,
      hasUnsavedChanges: false,
      isLoading: false,
    );
  }

  void createFromTemplate(TextTemplateType type) {
    if (state.documents.length >= state.maxDocuments) {
      state = state.copyWith(
        errorMessage: 'Maximum of ${state.maxDocuments} documents reached.',
      );
      return;
    }
    final String initialContent;
    final String name;

    switch (type) {
      case TextTemplateType.bugReport:
        name = "";
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
        name = "";
        initialContent = """# Development Ticket
## Summary
(Goal)

## Requirements
- 

## Acceptance Criteria
- [ ] """;
        break;
      case TextTemplateType.empty:
        name = "";
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
      hasUnsavedChanges: true,
    );
  }

  void updateContent(String content) {
    if (state.activeDocument == null) return;
    if (state.activeDocument!.content == content) return;

    String name = state.activeDocument!.name;

    // R1: Parse title if the first line is H1
    final lines = content.split('\n');
    if (lines.isNotEmpty) {
      final firstLine = lines.first.trim();
      if (firstLine.startsWith('# ')) {
        final extractedName = firstLine.substring(2).trim();
        if (extractedName.isNotEmpty && extractedName != name) {
          name = extractedName;
        }
      }
    }

    state = state.copyWith(
      activeDocument: state.activeDocument!.copyWith(
        name: name,
        content: content,
        lastModified: DateTime.now(),
      ),
      hasUnsavedChanges: true,
    );
    _debouncedSave();
  }

  void updateName(String name) {
    if (state.activeDocument == null) return;
    final doc = state.activeDocument!;
    if (doc.name == name) return;

    final oldName = doc.name;
    String content = doc.content;

    // R3: Handle H1 at the very top. If we change the name in header, update the H1 in content.
    final lines = content.split('\n');
    if (lines.isNotEmpty && lines.first.trim().startsWith('# ')) {
      lines[0] = '# $name';
      content = lines.join('\n');
    } else {
      // If no H1 at top, we prepend it to "integrate" them as requested
      content = '# $name\n\n$content';
    }

    state = state.copyWith(
      activeDocument: doc.copyWith(
        name: name,
        content: content,
        lastModified: DateTime.now(),
      ),
      hasUnsavedChanges: true,
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

  Future<void> saveDocument({
    String? oldName,
    bool navigateToList = false,
  }) async {
    final doc = state.activeDocument;
    if (doc == null) return;

    state = state.copyWith(isSaving: true);

    try {
      // R2: Force "Document (n)" if name is empty or handle duplicates
      String finalName = doc.name;
      final isNew = !state.documents.any((d) => d.id == doc.id);

      if (isNew && state.documents.length >= state.maxDocuments) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Maximum of ${state.maxDocuments} documents reached.',
        );
        return;
      }

      if (finalName.isEmpty || isNew || oldName != null) {
        finalName = await _storage.getNextAvailableName(finalName);
      }

      final updatedDoc = doc.copyWith(name: finalName);
      await _storage.saveDocument(updatedDoc, oldName: oldName);

      final updatedDocs = [...state.documents];
      final index = updatedDocs.indexWhere((d) => d.id == updatedDoc.id);

      if (index != -1) {
        updatedDocs[index] = updatedDoc;
      } else {
        updatedDocs.add(updatedDoc);
      }

      state = state.copyWith(
        activeDocument: updatedDoc,
        documents: _sortDocuments(updatedDocs),
        isSaving: false,
        hasUnsavedChanges: false,
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

  Future<void> changeSavePath(String path) async {
    state = state.copyWith(savePath: path);
    await ref.read(preferencesServiceProvider).setTextEditorSaveDir(path);
    await initialize(); // Reload from new path
  }

  Future<void> openSaveFolder() async {
    final dir = await _storage.storageDir;
    final path = dir.path;
    if (Platform.isWindows) {
      await Process.run('explorer.exe', [path]);
    }
  }

  Future<String> saveImageAttachment(String originalPath) async {
    return await _storage.saveImageAttachment(originalPath);
  }

  Future<String> saveImageBytes(Uint8List bytes, String extension) async {
    return await _storage.saveImageBytes(bytes, extension);
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

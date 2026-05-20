import 'dart:async';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/platform_utils.dart';
import '../models/obfuscator_state.dart';
import '../models/obfuscator_workspace.dart';
import '../models/imported_document.dart';
import '../models/dictionary_entry.dart';
import '../services/obfuscator_storage_service.dart';
import '../engine/variant_resolver.dart';
import '../engine/alias_generator.dart';
import '../engine/substitution_engine.dart';
import '../engine/term_scanner.dart';

part 'obfuscator_provider.g.dart';

@riverpod
List<ImportedDocument> filteredObfuscatorDocuments(Ref ref) {
  final ObfuscatorState state = ref.watch(obfuscatorProvider);
  final String query = state.searchQuery.toLowerCase();
  if (query.isEmpty) {
    return state.documents;
  }
  return state.documents.where((ImportedDocument doc) {
    return doc.fileName.toLowerCase().contains(query) ||
        doc.content.toLowerCase().contains(query);
  }).toList();
}

@riverpod
List<DictionaryEntry> filteredObfuscatorDictionary(Ref ref) {
  final ObfuscatorState state = ref.watch(obfuscatorProvider);
  final String query = state.searchQuery.toLowerCase();
  if (query.isEmpty) {
    return state.dictionary;
  }
  return state.dictionary.where((DictionaryEntry entry) {
    return entry.original.toLowerCase().contains(query) ||
        entry.replacement.toLowerCase().contains(query);
  }).toList();
}

@riverpod
class Obfuscator extends _$Obfuscator {
  ObfuscatorStorageService get _storage =>
      ObfuscatorStorageService(customBasePath: state.savePath);
  Timer? _searchDebounce;

  @override
  ObfuscatorState build() {
    // TODO(Logic): Load saved path from preferences
    ref.onDispose(() {
      _searchDebounce?.cancel();
    });
    Future.microtask(() => initialize());
    return const ObfuscatorState();
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

    final workspaces = await _storage.loadWorkspaces();

    // If there are workspaces but no active one, select the first
    ObfuscatorWorkspace? active = state.activeWorkspace;
    if (active == null && workspaces.isNotEmpty) {
      active = workspaces.first;
    }

    // Load documents and dictionary for the active workspace
    List<ImportedDocument> documents = [];
    List<DictionaryEntry> dictionary = [];
    if (active != null) {
      documents = await _storage.loadDocuments(active.id);
      dictionary = await _storage.loadDictionary(active.id);
    }

    state = state.copyWith(
      workspaces: workspaces,
      activeWorkspace: active,
      documents: documents,
      dictionary: dictionary,
      isLoading: false,
    );
  }

  void setViewMode(ObfuscatorViewMode mode) {
    state = state.copyWith(viewMode: mode);
    if (mode == ObfuscatorViewMode.list) {
      initialize();
    }
  }

  void setMode(ObfuscatorMode mode) {
    state = state.copyWith(mode: mode);
  }

  void toggleObfuscatedPreview() {
    final nextState = !state.showObfuscatedPreview;
    state = state.copyWith(showObfuscatedPreview: nextState);
    if (nextState && state.dictionary.isEmpty) {
      scanAndPopulateDictionary();
    }
  }

  Future<void> viewDocument(ImportedDocument document) async {
    state = state.copyWith(isLoading: true);
    // Brief delay for the loading circle to appear
    await Future<void>.delayed(const Duration(milliseconds: 150));
    state = state.copyWith(
      activeDocument: document,
      viewMode: ObfuscatorViewMode.viewer,
      isLoading: false,
    );
  }

  Future<void> createWorkspace(String name) async {
    final workspace = ObfuscatorWorkspace(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now(),
    );
    final updated = [...state.workspaces, workspace];
    await _storage.saveWorkspaces(updated);
    state = state.copyWith(
      workspaces: updated,
      activeWorkspace: workspace,
      documents: [],
      dictionary: [],
    );
  }

  Future<void> selectWorkspace(ObfuscatorWorkspace workspace) async {
    state = state.copyWith(isLoading: true);
    final documents = await _storage.loadDocuments(workspace.id);
    final dictionary = await _storage.loadDictionary(workspace.id);
    state = state.copyWith(
      activeWorkspace: workspace,
      documents: documents,
      dictionary: dictionary,
      activeDocument: null,
      viewMode: ObfuscatorViewMode.list,
      isLoading: false,
    );
  }

  Future<void> updateWorkspaceStrategy(SubstitutionStrategy strategy) async {
    final active = state.activeWorkspace;
    if (active == null) return;

    final updatedWorkspace = active.copyWith(strategy: strategy);
    final updatedWorkspaces = state.workspaces
        .map((w) => w.id == active.id ? updatedWorkspace : w)
        .toList();

    // Regenerate existing dictionary entries with the new strategy
    final List<DictionaryEntry> updatedDictionary = [];
    final Map<EntryCategory, int> categoryIndices = {};
    for (final category in EntryCategory.values) {
      categoryIndices[category] = 1;
    }

    for (final entry in state.dictionary) {
      final idx = categoryIndices[entry.category] ?? 1;
      categoryIndices[entry.category] = idx + 1;

      final newReplacement = AliasGenerator.generate(
        original: entry.original,
        category: entry.category,
        strategy: strategy,
        index: idx,
      );

      updatedDictionary.add(
        entry.copyWith(
          replacement: newReplacement,
          variants: VariantResolver.generateVariants(
            entry.original,
            newReplacement,
          ),
        ),
      );
    }

    await _storage.saveWorkspaces(updatedWorkspaces);
    await _storage.saveDictionary(active.id, updatedDictionary);

    state = state.copyWith(
      workspaces: updatedWorkspaces,
      activeWorkspace: updatedWorkspace,
      dictionary: updatedDictionary,
    );
  }

  Future<void> importDocument(String filePath) async {
    if (state.activeWorkspace == null) return;
    state = state.copyWith(isSaving: true);
    try {
      final doc = await _storage.importDocument(
        state.activeWorkspace!.id,
        filePath,
      );
      state = state.copyWith(
        documents: [...state.documents, doc],
        isSaving: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Failed to import: $e',
      );
    }
  }

  Future<void> deleteDocument(String docId) async {
    if (state.activeWorkspace == null) return;
    try {
      await _storage.deleteDocument(state.activeWorkspace!.id, docId);
      state = state.copyWith(
        documents: state.documents.where((d) => d.id != docId).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete: $e');
    }
  }

  Future<void> copyContent(String content) async {
    await Clipboard.setData(ClipboardData(text: content));
  }

  Future<void> openSaveFolder() async {
    final dir = await _storage.storageDir;
    await PlatformUtils.openPath(dir.path);
  }

  Future<void> addDictionaryEntry({
    required String original,
    required String replacement,
    EntryCategory category = EntryCategory.general,
  }) async {
    if (state.activeWorkspace == null) return;

    final entry = DictionaryEntry(
      id: const Uuid().v4(),
      original: original,
      replacement: replacement,
      category: category,
      variants: VariantResolver.generateVariants(original, replacement),
      enabled: true,
    );

    final updated = [...state.dictionary, entry];
    await _storage.saveDictionary(state.activeWorkspace!.id, updated);

    state = state.copyWith(dictionary: updated);
  }

  Future<void> toggleDictionaryEntry(String entryId) async {
    if (state.activeWorkspace == null) return;

    final updated = state.dictionary.map((entry) {
      if (entry.id == entryId) {
        return entry.copyWith(enabled: !entry.enabled);
      }
      return entry;
    }).toList();

    await _storage.saveDictionary(state.activeWorkspace!.id, updated);
    state = state.copyWith(dictionary: updated);
  }

  Future<void> deleteDictionaryEntry(String entryId) async {
    if (state.activeWorkspace == null) return;

    final updated = state.dictionary
        .where((entry) => entry.id != entryId)
        .toList();
    await _storage.saveDictionary(state.activeWorkspace!.id, updated);
    state = state.copyWith(dictionary: updated);
  }

  Future<void> clearDictionary() async {
    if (state.activeWorkspace == null) return;

    await _storage.saveDictionary(state.activeWorkspace!.id, []);
    state = state.copyWith(dictionary: []);
  }

  Future<int> scanAndPopulateDictionary() async {
    if (state.activeWorkspace == null) return 0;
    final doc = state.activeDocument;
    if (doc == null || doc.content.isEmpty) return 0;

    // Strict Guard 1: Prevent automatic scanning if workspace dictionary is already very large
    // to preserve rendering performance, prevent UI clutter, and keep dictionaries clean and focused.
    const int maxAutoScanDictionarySize = 150;
    if (state.dictionary.length >= maxAutoScanDictionarySize) {
      return 0;
    }

    // Use TermScanner to scan the document for new candidates
    var candidates = TermScanner.scan(doc.content, state.dictionary);
    if (candidates.isEmpty) return 0;

    // Strict Guard 2: Cap the number of new candidates that can be added in a single scan session
    // to prevent automatic dictionary growth explosion when opening very large files.
    const int maxNewCandidatesPerScan = 40;
    if (candidates.length > maxNewCandidatesPerScan) {
      candidates = candidates.take(maxNewCandidatesPerScan).toList();
    }

    final strategy =
        state.activeWorkspace?.strategy ?? SubstitutionStrategy.semantic;
    final List<DictionaryEntry> newEntries = [];

    // Helper map to track token index counters per category
    final Map<EntryCategory, int> categoryIndices = {};
    for (final category in EntryCategory.values) {
      categoryIndices[category] =
          state.dictionary.where((e) => e.category == category).length + 1;
    }

    for (final candidate in candidates) {
      final idx = categoryIndices[candidate.category] ?? 1;
      categoryIndices[candidate.category] = idx + 1;

      final replacement = AliasGenerator.generate(
        original: candidate.term,
        category: candidate.category,
        strategy: strategy,
        index: idx,
      );

      newEntries.add(
        DictionaryEntry(
          id: const Uuid().v4(),
          original: candidate.term,
          replacement: replacement,
          category: candidate.category,
          variants: VariantResolver.generateVariants(
            candidate.term,
            replacement,
          ),
          enabled: true,
        ),
      );
    }

    if (newEntries.isNotEmpty) {
      final updated = [...state.dictionary, ...newEntries];
      await _storage.saveDictionary(state.activeWorkspace!.id, updated);
      state = state.copyWith(dictionary: updated);
    }
    return newEntries.length;
  }

  Future<void> deobfuscateText(String obfuscatedText) async {
    state = state.copyWith(isLoading: true);
    try {
      final activeEntries = state.dictionary.where((e) => e.enabled).toList();
      final result = SubstitutionEngine.deobfuscate(
        obfuscatedText,
        activeEntries,
      );

      // Calculate how many replacements actually occurred
      int matchCount = 0;
      for (final entry in activeEntries) {
        if (obfuscatedText.contains(entry.replacement)) {
          matchCount++;
        }
      }

      state = state.copyWith(
        deobfuscatedContent: result,
        lastRestoredCount: matchCount,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'De-obfuscation failed: $e',
      );
    }
  }

  void clearDeobfuscatedContent() {
    state = state.copyWith(deobfuscatedContent: null, lastRestoredCount: 0);
  }
}

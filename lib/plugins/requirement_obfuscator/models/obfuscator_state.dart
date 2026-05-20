import 'package:freezed_annotation/freezed_annotation.dart';
import 'dictionary_entry.dart';
import 'imported_document.dart';
import 'obfuscator_workspace.dart';

part 'obfuscator_state.freezed.dart';

enum ObfuscatorViewMode { list, viewer }

enum ObfuscatorMode { obfuscate, deobfuscate, dictionary }

@freezed
abstract class ObfuscatorState with _$ObfuscatorState {
  const factory ObfuscatorState({
    @Default(null) ObfuscatorWorkspace? activeWorkspace,
    @Default([]) List<ObfuscatorWorkspace> workspaces,
    @Default([]) List<ImportedDocument> documents,
    @Default([]) List<DictionaryEntry> dictionary,
    @Default(null) ImportedDocument? activeDocument,
    @Default(ObfuscatorViewMode.list) ObfuscatorViewMode viewMode,
    @Default(ObfuscatorMode.obfuscate) ObfuscatorMode mode,
    @Default(false) bool showObfuscatedPreview,
    @Default(null) String? deobfuscatedContent,
    @Default(0) int lastRestoredCount,
    @Default(false) bool isLoading,
    @Default(false) bool isSaving,
    String? errorMessage,
    String? savePath,
    @Default('') String searchQuery,
  }) = _ObfuscatorState;
}

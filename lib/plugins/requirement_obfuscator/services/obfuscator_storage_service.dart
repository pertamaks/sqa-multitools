import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/imported_document.dart';
import '../models/dictionary_entry.dart';
import '../models/obfuscator_workspace.dart';
import '../models/obfuscator_settings.dart';
import '../../../core/utils/platform_utils.dart';

class ObfuscatorStorageService {
  static const String _folderName = 'SQA_Obfuscator';
  static const String _workspacesFile = 'workspaces.json';
  static const String _settingsFile = 'settings.json';

  final String? customBasePath;

  ObfuscatorStorageService({this.customBasePath});

  Future<Directory> get storageDir => _storageDir;

  Future<Directory> get _storageDir async {
    if (customBasePath != null && customBasePath!.isNotEmpty) {
      final dir = Directory(customBasePath!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory(
      '${docsDir.path}${Platform.pathSeparator}$_folderName',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> _workspaceDir(String workspaceId) async {
    final base = await _storageDir;
    final dir = Directory(
      '${base.path}${Platform.pathSeparator}workspaces${Platform.pathSeparator}$workspaceId',
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  // --- Workspace CRUD ---

  Future<List<ObfuscatorWorkspace>> loadWorkspaces() async {
    try {
      final dir = await _storageDir;
      final file = File('${dir.path}${Platform.pathSeparator}$_workspacesFile');
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> list = jsonDecode(content) as List<dynamic>;
      return list
          .map((e) => ObfuscatorWorkspace.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWorkspaces(List<ObfuscatorWorkspace> workspaces) async {
    final dir = await _storageDir;
    final file = File('${dir.path}${Platform.pathSeparator}$_workspacesFile');
    final json = workspaces.map((w) => w.toJson()).toList();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  // --- Dictionary CRUD ---

  Future<List<DictionaryEntry>> loadDictionary(String workspaceId) async {
    try {
      final dir = await _workspaceDir(workspaceId);
      final file = File('${dir.path}${Platform.pathSeparator}dictionary.json');
      if (!await file.exists()) return [];

      final content = await file.readAsString();
      final List<dynamic> list = jsonDecode(content) as List<dynamic>;
      return list
          .map((e) => DictionaryEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDictionary(
    String workspaceId,
    List<DictionaryEntry> entries,
  ) async {
    final dir = await _workspaceDir(workspaceId);
    final file = File('${dir.path}${Platform.pathSeparator}dictionary.json');
    final json = entries.map((e) => e.toJson()).toList();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));
  }

  // --- Document CRUD ---

  Future<List<ImportedDocument>> loadDocuments(String workspaceId) async {
    try {
      final dir = await _workspaceDir(workspaceId);
      final sourcesDir = Directory(
        '${dir.path}${Platform.pathSeparator}sources',
      );
      if (!await sourcesDir.exists()) return [];

      final registryFile = File(
        '${dir.path}${Platform.pathSeparator}sources_registry.json',
      );
      if (!await registryFile.exists()) return [];

      final content = await registryFile.readAsString();
      final List<dynamic> list = jsonDecode(content) as List<dynamic>;
      final List<ImportedDocument> docs = [];

      for (final entry in list) {
        final meta = ImportedDocument.fromJson(entry as Map<String, dynamic>);
        final sourceFile = File(
          '${sourcesDir.path}${Platform.pathSeparator}${_safeFilename(meta.fileName)}',
        );
        if (await sourceFile.exists()) {
          final fileContent = await sourceFile.readAsString();
          docs.add(meta.copyWith(content: fileContent));
        }
      }
      return docs;
    } catch (_) {
      return [];
    }
  }

  Future<ImportedDocument> importDocument(
    String workspaceId,
    String filePath,
  ) async {
    final sourceFile = File(filePath);
    if (!await sourceFile.exists()) {
      throw Exception('Source file not found: $filePath');
    }

    final content = await sourceFile.readAsString();
    final fileName = sourceFile.uri.pathSegments.last;

    final dir = await _workspaceDir(workspaceId);
    final sourcesDir = Directory('${dir.path}${Platform.pathSeparator}sources');
    if (!await sourcesDir.exists()) {
      await sourcesDir.create(recursive: true);
    }

    // Copy source file
    final safeFileName = _safeFilename(fileName);
    await sourceFile.copy(
      '${sourcesDir.path}${Platform.pathSeparator}$safeFileName',
    );

    final doc = ImportedDocument(
      id: const Uuid().v4(),
      fileName: fileName,
      content: content,
      importedAt: DateTime.now(),
    );

    // Update registry
    final registryFile = File(
      '${dir.path}${Platform.pathSeparator}sources_registry.json',
    );
    List<dynamic> registry = [];
    if (await registryFile.exists()) {
      try {
        registry =
            jsonDecode(await registryFile.readAsString()) as List<dynamic>;
      } catch (_) {
        registry = [];
      }
    }
    registry.add(doc.copyWith(content: '').toJson());
    await registryFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(registry),
    );

    return doc;
  }

  Future<void> deleteDocument(String workspaceId, String docId) async {
    final dir = await _workspaceDir(workspaceId);
    final registryFile = File(
      '${dir.path}${Platform.pathSeparator}sources_registry.json',
    );
    if (!await registryFile.exists()) return;

    try {
      final List<dynamic> registry =
          jsonDecode(await registryFile.readAsString()) as List<dynamic>;

      // Find and remove from registry
      final entry = registry.firstWhere(
        (e) => (e as Map<String, dynamic>)['id'] == docId,
        orElse: () => null,
      );
      if (entry != null) {
        final fileName = (entry as Map<String, dynamic>)['fileName'] as String;
        final sourcesDir = Directory(
          '${dir.path}${Platform.pathSeparator}sources',
        );
        final sourceFile = File(
          '${sourcesDir.path}${Platform.pathSeparator}${_safeFilename(fileName)}',
        );
        if (await sourceFile.exists()) await sourceFile.delete();
      }

      registry.removeWhere((e) => (e as Map<String, dynamic>)['id'] == docId);
      await registryFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(registry),
      );
    } catch (_) {}
  }

  // --- Settings ---

  Future<ObfuscatorSettings> loadSettings() async {
    try {
      final dir = await _storageDir;
      final file = File('${dir.path}${Platform.pathSeparator}$_settingsFile');
      if (!await file.exists()) return const ObfuscatorSettings();

      final content = await file.readAsString();
      return ObfuscatorSettings.fromJson(
        jsonDecode(content) as Map<String, dynamic>,
      );
    } catch (_) {
      return const ObfuscatorSettings();
    }
  }

  Future<void> saveSettings(ObfuscatorSettings settings) async {
    final dir = await _storageDir;
    final file = File('${dir.path}${Platform.pathSeparator}$_settingsFile');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(settings.toJson()),
    );
  }

  String _safeFilename(String name) {
    if (name.trim().isEmpty) return 'Untitled';
    return name
        .trim()
        .replaceAll(PlatformUtils.prohibitedFilenameRegex, '_')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

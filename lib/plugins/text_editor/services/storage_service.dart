import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/text_document.dart';

class TextEditorStorageService {
  static const String _folderName = 'SQA_Notes';
  static const String _registryFile = 'registry.json';

  Future<Directory> get _storageDir async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docsDir.path}${Platform.pathSeparator}$_folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<TextDocument>> loadAllDocuments() async {
    try {
      final dir = await _storageDir;
      final registryFile = File('${dir.path}${Platform.pathSeparator}$_registryFile');
      
      List<dynamic> registry = [];
      if (await registryFile.exists()) {
        try {
          registry = jsonDecode(await registryFile.readAsString()) as List<dynamic>;
        } catch (_) {
          registry = [];
        }
      }

      // Phase 1: Load documents from registry
      final List<TextDocument> docs = [];
      final Set<String> registeredFilenames = {};

      for (var entry in registry) {
        final docMeta = TextDocument.fromJson(entry as Map<String, dynamic>);
        final filename = _safeFilename(docMeta.name);
        registeredFilenames.add('$filename.txt');
        final file = File('${dir.path}${Platform.pathSeparator}$filename.txt');
        
        if (await file.exists()) {
          final content = await file.readAsString();
          docs.add(docMeta.copyWith(content: content));
        } else {
          // File missing from disk but in registry — keep with empty content
          docs.add(docMeta.copyWith(content: ''));
        }
      }

      // Phase 2: Scan filesystem for orphan .txt files not in registry
      bool registryDirty = false;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final basename = entity.uri.pathSegments.last;
        // Skip the registry file itself and any non-.txt files
        if (basename == _registryFile || !basename.endsWith('.txt')) continue;
        // Skip files already tracked by the registry
        if (registeredFilenames.contains(basename)) continue;

        // Orphan file found — import it
        final content = await entity.readAsString();
        final rawName = basename.substring(0, basename.length - 4); // strip .txt

        // Try to extract a title from the first H1 line
        String docName = rawName;
        final lines = content.split('\n');
        if (lines.isNotEmpty && lines.first.trim().startsWith('# ')) {
          final extracted = lines.first.trim().substring(2).trim();
          if (extracted.isNotEmpty) docName = extracted;
        }

        final newDoc = TextDocument(
          id: const Uuid().v4(),
          name: docName,
          content: content,
          lastModified: await entity.lastModified(),
        );
        docs.add(newDoc);

        // Auto-register in the registry so it persists
        registry.add(newDoc.copyWith(content: '').toJson());
        registeredFilenames.add(basename);

        // If imported name differs from filename, rename the file to match
        final expectedFilename = '${_safeFilename(docName)}.txt';
        if (expectedFilename != basename) {
          final newPath = '${dir.path}${Platform.pathSeparator}$expectedFilename';
          // Only rename if target doesn't already exist
          if (!await File(newPath).exists()) {
            await entity.rename(newPath);
          }
        }
        registryDirty = true;
      }

      // Persist updated registry if new files were imported
      if (registryDirty) {
        await registryFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(registry),
        );
      }

      return docs;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveDocument(TextDocument doc, {String? oldName}) async {
    final dir = await _storageDir;
    
    // 1. Handle Rename: If name changed, delete/rename old file
    if (oldName != null && oldName != doc.name) {
      final oldFile = File('${dir.path}${Platform.pathSeparator}${_safeFilename(oldName)}.txt');
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }

    // 2. Save content to .txt
    final file = File('${dir.path}${Platform.pathSeparator}${_safeFilename(doc.name)}.txt');
    await file.writeAsString(doc.content);

    // 3. Update registry metadata
    final registryFile = File('${dir.path}${Platform.pathSeparator}$_registryFile');
    List<dynamic> registry = [];
    if (await registryFile.exists()) {
      try {
        registry = jsonDecode(await registryFile.readAsString()) as List<dynamic>;
      } catch (_) {
        registry = [];
      }
    }

    final index = registry.indexWhere((item) => item['id'] == doc.id);
    // Store metadata without the large content blob
    final metaJson = doc.copyWith(content: '').toJson();
    
    if (index != -1) {
      registry[index] = metaJson;
    } else {
      registry.add(metaJson);
    }

    await registryFile.writeAsString(const JsonEncoder.withIndent('  ').convert(registry));
  }

  Future<void> deleteDocument(String id, String name) async {
    final dir = await _storageDir;
    
    // 1. Delete .txt file
    final file = File('${dir.path}${Platform.pathSeparator}${_safeFilename(name)}.txt');
    if (await file.exists()) await file.delete();

    // 2. Update registry
    final registryFile = File('${dir.path}${Platform.pathSeparator}$_registryFile');
    if (await registryFile.exists()) {
      try {
        final List<dynamic> registry = jsonDecode(await registryFile.readAsString()) as List<dynamic>;
        registry.removeWhere((item) => item['id'] == id);
        await registryFile.writeAsString(const JsonEncoder.withIndent('  ').convert(registry));
      } catch (_) {}
    }
  }

  Future<String> getNextAvailableName(String baseName) async {
    final dir = await _storageDir;
    String candidate = baseName.isEmpty ? 'Document' : baseName;
    String safeCandidate = _safeFilename(candidate);
    
    // Check if the file exists
    int counter = 1;
    File file = File('${dir.path}${Platform.pathSeparator}$safeCandidate.txt');
    
    while (await file.exists()) {
      safeCandidate = _safeFilename('$candidate ($counter)');
      file = File('${dir.path}${Platform.pathSeparator}$safeCandidate.txt');
      counter++;
    }
    
    return candidate == baseName ? (counter == 1 ? baseName : '$candidate (${counter - 1})') : (counter == 1 ? candidate : '$candidate (${counter - 1})');
  }

  // Refined helper to get the actual safe name for filesystem operations
  String getSafeFilename(String name) => _safeFilename(name);

  String _safeFilename(String name) {
    if (name.trim().isEmpty) return 'Untitled';
    // Remove or replace OS-prohibited characters
    return name.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').replaceAll(RegExp(r'\s+'), ' ');
  }
}

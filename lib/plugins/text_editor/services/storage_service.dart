import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/text_document.dart';

class TextEditorStorageService {
  static const String _folderName = 'SQA_Notes';
  static const String _registryFile = 'registry.json';

  final String? customBasePath;

  TextEditorStorageService({this.customBasePath});

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

  Future<Directory> get attachmentsDir async {
    final dir = await _storageDir;
    final attachments = Directory(
      '${dir.path}${Platform.pathSeparator}attachments',
    );
    if (!await attachments.exists()) {
      await attachments.create(recursive: true);
    }
    return attachments;
  }

  /// Copies an external image into the local attachments folder.
  /// Returns the relative path for use in Markdown.
  Future<String> saveImageAttachment(String originalPath) async {
    final attachments = await attachmentsDir;
    final file = File(originalPath);
    if (!await file.exists()) throw Exception('Source file not found');

    final extension = file.path.split('.').last.toLowerCase();
    final newName = 'img_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final newPath = '${attachments.path}${Platform.pathSeparator}$newName';

    await file.copy(newPath);
    return 'attachments/$newName';
  }

  /// Saves raw image bytes into the local attachments folder.
  /// Returns the relative path for use in Markdown.
  Future<String> saveImageBytes(Uint8List bytes, String extension) async {
    final attachments = await attachmentsDir;
    final newName =
        'img_${DateTime.now().millisecondsSinceEpoch}.${extension.toLowerCase()}';
    final newPath = '${attachments.path}${Platform.pathSeparator}$newName';

    await File(newPath).writeAsBytes(bytes);
    return 'attachments/$newName';
  }

  Future<List<TextDocument>> loadAllDocuments() async {
    try {
      final dir = await _storageDir;
      final registryFile = File(
        '${dir.path}${Platform.pathSeparator}$_registryFile',
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

      final List<TextDocument> validDocs = [];
      final List<dynamic> updatedRegistry = [];
      final Set<String> registeredFilenames = {};
      bool registryDirty = false;

      // Phase 1: Validate registry against disk (with deduplication)
      for (var entry in registry) {
        final docMeta = TextDocument.fromJson(entry as Map<String, dynamic>);
        final filename = '${_safeFilename(docMeta.name)}.txt';
        final file = File('${dir.path}${Platform.pathSeparator}$filename');

        if (await file.exists() && !registeredFilenames.contains(filename)) {
          final content = await file.readAsString();
          validDocs.add(docMeta.copyWith(content: content));
          updatedRegistry.add(entry);
          registeredFilenames.add(filename);
        } else {
          // File missing from disk OR duplicate name in registry claiming same file
          registryDirty = true;
        }
      }

      // Phase 2: Scan filesystem for orphan .txt files not in registry
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final basename = entity.uri.pathSegments.last;
        if (basename == _registryFile || !basename.endsWith('.txt')) continue;
        if (registeredFilenames.contains(basename)) continue;

        // Orphan found — import it
        String content = await entity.readAsString();
        final rawName = basename.substring(0, basename.length - 4);

        // Extract title from H1
        String docName = rawName;
        final lines = content.split('\n');
        if (lines.isNotEmpty && lines.first.trim().startsWith('# ')) {
          final extracted = lines.first.trim().substring(2).trim();
          if (extracted.isNotEmpty) docName = extracted;
        }

        // Handle naming collisions and sync disk
        final finalName = await getNextAvailableName(docName);
        final finalFilename = '${_safeFilename(finalName)}.txt';

        if (finalFilename != basename) {
          final newPath = '${dir.path}${Platform.pathSeparator}$finalFilename';
          await entity.rename(newPath);
        }

        final newDoc = TextDocument(
          id: const Uuid().v4(),
          name: finalName,
          content: content,
          lastModified: await File(
            '${dir.path}${Platform.pathSeparator}$finalFilename',
          ).lastModified(),
        );

        validDocs.add(newDoc);
        updatedRegistry.add(newDoc.copyWith(content: '').toJson());
        registeredFilenames.add(finalFilename);
        registryDirty = true;
      }

      if (registryDirty) {
        await registryFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(updatedRegistry),
        );
      }

      return validDocs;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveDocument(TextDocument doc, {String? oldName}) async {
    final dir = await _storageDir;

    // 1. Handle Rename: If name changed, delete/rename old file
    if (oldName != null && oldName != doc.name) {
      final oldFile = File(
        '${dir.path}${Platform.pathSeparator}${_safeFilename(oldName)}.txt',
      );
      if (await oldFile.exists()) {
        await oldFile.delete();
      }
    }

    // 2. Save content to .txt
    final file = File(
      '${dir.path}${Platform.pathSeparator}${_safeFilename(doc.name)}.txt',
    );
    await file.writeAsString(doc.content);

    // 3. Update registry metadata
    final registryFile = File(
      '${dir.path}${Platform.pathSeparator}$_registryFile',
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

    final index = registry.indexWhere((item) => item['id'] == doc.id);
    // Store metadata without the large content blob
    final metaJson = doc.copyWith(content: '').toJson();

    if (index != -1) {
      registry[index] = metaJson;
    } else {
      registry.add(metaJson);
    }

    await registryFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(registry),
    );
  }

  Future<void> deleteDocument(String id, String name) async {
    final dir = await _storageDir;

    // 1. Delete .txt file
    final file = File(
      '${dir.path}${Platform.pathSeparator}${_safeFilename(name)}.txt',
    );
    if (await file.exists()) await file.delete();

    // 2. Update registry
    final registryFile = File(
      '${dir.path}${Platform.pathSeparator}$_registryFile',
    );
    if (await registryFile.exists()) {
      try {
        final List<dynamic> registry =
            jsonDecode(await registryFile.readAsString()) as List<dynamic>;
        registry.removeWhere((item) => item['id'] == id);
        await registryFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(registry),
        );
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

    return candidate == baseName
        ? (counter == 1 ? baseName : '$candidate (${counter - 1})')
        : (counter == 1 ? candidate : '$candidate (${counter - 1})');
  }

  // Refined helper to get the actual safe name for filesystem operations
  String getSafeFilename(String name) => _safeFilename(name);

  String _safeFilename(String name) {
    if (name.trim().isEmpty) return 'Untitled';
    // Remove or replace OS-prohibited characters
    return name
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ');
  }
}

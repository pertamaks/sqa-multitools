import 'package:flutter/foundation.dart';
import 'package:collection/collection.dart'; // For list equality

@immutable
class ClipboardItem {
  final String id;
  final String? content;
  final Uint8List? imageBytes;
  final String? fileUri;
  final List<String> formats;
  final DateTime timestamp;
  final bool isPinned;

  const ClipboardItem({
    required this.id,
    this.content,
    this.imageBytes,
    this.fileUri,
    this.formats = const [],
    required this.timestamp,
    this.isPinned = false,
  });

  ClipboardItem copyWith({
    String? id,
    String? content,
    Uint8List? imageBytes,
    String? fileUri,
    List<String>? formats,
    DateTime? timestamp,
    bool? isPinned,
  }) {
    return ClipboardItem(
      id: id ?? this.id,
      content: content ?? this.content,
      imageBytes: imageBytes ?? this.imageBytes,
      fileUri: fileUri ?? this.fileUri,
      formats: formats ?? this.formats,
      timestamp: timestamp ?? this.timestamp,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipboardItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          fileUri == other.fileUri &&
          const ListEquality<int>().equals(imageBytes, other.imageBytes) &&
          const ListEquality<String>().equals(formats, other.formats) &&
          timestamp == other.timestamp &&
          isPinned == other.isPinned;

  @override
  int get hashCode =>
      id.hashCode ^
      content.hashCode ^
      (imageBytes != null ? const ListEquality<int>().hash(imageBytes) : 0) ^
      fileUri.hashCode ^
      const ListEquality<String>().hash(formats) ^
      timestamp.hashCode ^
      isPinned.hashCode;
}

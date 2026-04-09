import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:uuid/uuid.dart';
import '../models/clipboard_item.dart';
import '../utils/clipboard_extensions.dart';

class ClipboardHistoryNotifier extends Notifier<List<ClipboardItem>> {
  Timer? _pollingTimer;
  Object? _lastEvent;
  bool _isDisposed = false;
  static const int _maxHistory = 50;

  @override
  List<ClipboardItem> build() {
    _isDisposed = false;
    ref.onDispose(() {
      _isDisposed = true;
      _pollingTimer?.cancel();
    });

    _startPolling();

    return [];
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      Timer timer,
    ) async {
      if (_isDisposed) return;

      final clipboard = SystemClipboard.instance;
      if (clipboard == null) return;

      final reader = await clipboard.read();
      final items = reader.items;
      if (items.isEmpty) return;

      final item = items.first;

      // Determine what to capture based on priority: Image > File > Text
      if (item.canProvide(Formats.png)) {
        item.readFileValue(Formats.png).then((value) {
          if (value != null && _isNewContent(value)) {
            _lastEvent = value;
            addItem(imageBytes: value, formats: item.platformFormats);
          }
        });
      } else if (item.canProvide(Formats.fileUri)) {
        item.readValue(Formats.fileUri).then((value) {
          if (value != null && _isNewContent(value.toString())) {
            _lastEvent = value.toString();
            addItem(
              fileUri: value.toString(),
              content: value.path,
              formats: item.platformFormats,
            );
          }
        });
      } else if (item.canProvide(Formats.plainText)) {
        item.readValue(Formats.plainText).then((value) {
          if (value != null && value.isNotEmpty && _isNewContent(value)) {
            _lastEvent = value;
            addItem(content: value, formats: item.platformFormats);
          }
        });
      }
    });
  }

  bool _isNewContent(Object content) {
    return content != _lastEvent;
  }

  void addItem({
    String? content,
    Uint8List? imageBytes,
    String? fileUri,
    List<String> formats = const [],
  }) {
    // Check if it already exists to avoid duplicates
    final existingIndex = state.indexWhere((ClipboardItem item) {
      if (imageBytes != null && item.imageBytes != null) {
        return item.imageBytes.toString() ==
            imageBytes.toString(); // Crude check for image equality
      }
      if (fileUri != null) return item.fileUri == fileUri;
      if (content != null) return item.content == content;
      return false;
    });

    if (existingIndex != -1) {
      final existing = state[existingIndex];
      // Move to top if not pinned
      if (!existing.isPinned) {
        state = [
          existing.copyWith(timestamp: DateTime.now()),
          ...state.where((ClipboardItem item) => item.id != existing.id),
        ];
      }
      return;
    }

    final newItem = ClipboardItem(
      id: const Uuid().v4(),
      content: content,
      imageBytes: imageBytes,
      fileUri: fileUri,
      formats: formats,
      timestamp: DateTime.now(),
    );

    var newState = <ClipboardItem>[newItem, ...state];

    // Enforce 50 item limit, but keep pinned items
    if (newState.length > _maxHistory) {
      final pinned = newState.where((item) => item.isPinned).toList();
      final unpinned = newState
          .where((item) => !item.isPinned)
          .take(_maxHistory - pinned.length)
          .toList();
      newState = [...pinned, ...unpinned];
      // Sort by timestamp to keep order consistent if needed, but usually we just want latest on top
      newState.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }

    state = newState;
  }

  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void togglePin(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isPinned: !item.isPinned);
      }
      return item;
    }).toList();
  }

  void clearAll() {
    state = state.where((item) => item.isPinned).toList();
  }
}

final clipboardHistoryProvider =
    NotifierProvider<ClipboardHistoryNotifier, List<ClipboardItem>>(() {
      return ClipboardHistoryNotifier();
    });

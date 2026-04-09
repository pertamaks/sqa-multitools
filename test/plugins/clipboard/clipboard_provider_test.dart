import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/clipboard/providers/clipboard_provider.dart';

void main() {
  group('ClipboardHistoryNotifier Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty', () {
      final history = container.read(clipboardHistoryProvider);
      expect(history, isEmpty);
    });

    test('addItem adds a new text item to the top', () {
      final notifier = container.read(clipboardHistoryProvider.notifier);

      notifier.addItem(content: 'Test Content 1');

      var history = container.read(clipboardHistoryProvider);
      expect(history.length, 1);
      expect(history.first.content, 'Test Content 1');

      notifier.addItem(content: 'Test Content 2');

      history = container.read(clipboardHistoryProvider);
      expect(history.length, 2);
      expect(history.first.content, 'Test Content 2');
    });

    test('addItem deduplicates and moves existing item to top', () {
      final notifier = container.read(clipboardHistoryProvider.notifier);

      notifier.addItem(content: 'Item 1');
      notifier.addItem(content: 'Item 2');

      var history = container.read(clipboardHistoryProvider);
      expect(history[0].content, 'Item 2');
      expect(history[1].content, 'Item 1');

      // Add Item 1 again
      notifier.addItem(content: 'Item 1');

      history = container.read(clipboardHistoryProvider);
      expect(history.length, 2);
      expect(history[0].content, 'Item 1');
      expect(history[1].content, 'Item 2');
    });

    test('addItem handles image bytes', () {
      final notifier = container.read(clipboardHistoryProvider.notifier);
      final bytes = Uint8List.fromList([1, 2, 3, 4]);

      notifier.addItem(imageBytes: bytes);

      final history = container.read(clipboardHistoryProvider);
      expect(history.first.imageBytes, bytes);
      expect(history.first.content, isNull);
    });

    test('togglePin toggles the isPinned state', () {
      final notifier = container.read(clipboardHistoryProvider.notifier);
      notifier.addItem(content: 'Pin Me');

      final id = container.read(clipboardHistoryProvider).first.id;
      expect(container.read(clipboardHistoryProvider).first.isPinned, isFalse);

      notifier.togglePin(id);
      expect(container.read(clipboardHistoryProvider).first.isPinned, isTrue);

      notifier.togglePin(id);
      expect(container.read(clipboardHistoryProvider).first.isPinned, isFalse);
    });

    test('deleteItem removes the item', () {
      final notifier = container.read(clipboardHistoryProvider.notifier);
      notifier.addItem(content: 'Delete Me');

      final id = container.read(clipboardHistoryProvider).first.id;
      expect(container.read(clipboardHistoryProvider).length, 1);

      notifier.deleteItem(id);
      expect(container.read(clipboardHistoryProvider), isEmpty);
    });

    test('clearAll removes only unpinned items', () {
      final notifier = container.read(clipboardHistoryProvider.notifier);
      notifier.addItem(content: 'Pinned');
      notifier.addItem(content: 'Unpinned');

      final pinnedId = container
          .read(clipboardHistoryProvider)
          .last
          .id; // Item 1 (Pinned)
      notifier.togglePin(pinnedId);

      expect(container.read(clipboardHistoryProvider).length, 2);

      notifier.clearAll();

      final history = container.read(clipboardHistoryProvider);
      expect(history.length, 1);
      expect(history.first.content, 'Pinned');
    });

    test('history size is limited to 50 items (preserving pinned items)', () {
      final notifier = container.read(clipboardHistoryProvider.notifier);

      // Pin the very first item
      notifier.addItem(content: 'Legacy Pinned');
      final pinnedId = container.read(clipboardHistoryProvider).first.id;
      notifier.togglePin(pinnedId);

      // Add 55 more items
      for (var i = 0; i < 55; i++) {
        notifier.addItem(content: 'Item $i');
      }

      final history = container.read(clipboardHistoryProvider);
      // Limit is 50, but we have 1 pinned + 49 latest unpinned
      expect(history.length, 50);

      // Ensure the pinned item is still there
      expect(history.any((item) => item.id == pinnedId), isTrue);
    });
  });
}

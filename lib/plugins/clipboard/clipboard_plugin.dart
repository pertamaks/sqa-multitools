import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_icon_container.dart';
import '../../ui/widgets/sqa_toast.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_button.dart';
import 'providers/clipboard_provider.dart';
import 'models/clipboard_item.dart';
import 'utils/clipboard_extensions.dart';

class ClipboardPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.clipboard';
  @override
  String get name => 'Clipboard Manager';
  @override
  String get description => 'Manage clipboard history.';
  @override
  IconData get icon => Symbols.content_paste;
  @override
  String? get badge => 'BETA';
  @override
  List<PermissionRequirement> get requiredPermissions => [
    PermissionRequirement.clipboard,
  ];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _ClipboardPluginView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Clipboard Manager Settings'));
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _ClipboardPluginView extends ConsumerWidget {
  const _ClipboardPluginView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(clipboardHistoryProvider);
    final theme = Theme.of(context);

    return DropRegion(
      formats: Formats.standardFormats,
      onDropOver: (event) => DropOperation.copy,
      onPerformDrop: (PerformDropEvent event) async {
        final items = event.session.items;
        if (items.isEmpty) return;
        final DataReader? reader = items.first.dataReader;
        if (reader == null) return;

        if (reader.canProvide(Formats.png)) {
          final bytes = await reader.readFileValue(Formats.png);
          if (bytes != null) {
            ref
                .read(clipboardHistoryProvider.notifier)
                .addItem(imageBytes: bytes, formats: reader.platformFormats);
          }
        } else if (reader.canProvide(Formats.fileUri)) {
          final uri = await reader.readValue(Formats.fileUri);
          if (uri != null) {
            ref
                .read(clipboardHistoryProvider.notifier)
                .addItem(
                  fileUri: uri.toString(),
                  content: uri.path,
                  formats: reader.platformFormats,
                );
          }
        } else if (reader.canProvide(Formats.plainText)) {
          final text = await reader.readValue(Formats.plainText);
          if (text != null) {
            ref
                .read(clipboardHistoryProvider.notifier)
                .addItem(content: text, formats: reader.platformFormats);
          }
        }
      },
      child: SqaPluginLayout(
        icon: Symbols.content_paste,
        title: 'Clipboard',
        description:
            'History of recently copied items (supports Images & Files)',
        trailing: SqaButton.tonal(
          onPressed: () =>
              ref.read(clipboardHistoryProvider.notifier).clearAll(),
          icon: Symbols.clear_all,
          label: 'Clear all',
          width: 110,
        ),
        child: history.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SqaIconContainer(
                      icon: Symbols.content_paste_off,
                      size: 64,
                      iconSize: 32,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'History is empty',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try dragging or copying an image/text',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _ClipboardItemTile(item: item);
                },
              ),
      ),
    );
  }
}

class _ClipboardItemTile extends ConsumerStatefulWidget {
  final ClipboardItem item;
  const _ClipboardItemTile({required this.item});

  @override
  ConsumerState<_ClipboardItemTile> createState() => _ClipboardItemTileState();
}

class _ClipboardItemTileState extends ConsumerState<_ClipboardItemTile> {
  bool _isHovered = false;

  Future<void> _copyToClipboard() async {
    final clipboard = SystemClipboard.instance;
    if (clipboard == null) return;

    final dataWriter = DataWriterItem();
    if (widget.item.imageBytes != null) {
      dataWriter.add(Formats.png.lazy(() => widget.item.imageBytes!));
    }
    if (widget.item.fileUri != null) {
      dataWriter.add(
        Formats.fileUri.lazy(() => Uri.parse(widget.item.fileUri!)),
      );
    }
    if (widget.item.content != null) {
      dataWriter.add(Formats.plainText.lazy(() => widget.item.content!));
    }

    await clipboard.write([dataWriter]);
    if (mounted) {
      SqaToast.show(context, 'Copied to clipboard', type: SqaToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DragItemWidget(
      dragItemProvider: (request) async {
        final item = DragItem();
        if (widget.item.imageBytes != null) {
          item.add(Formats.png.lazy(() => widget.item.imageBytes!));
        }
        if (widget.item.fileUri != null) {
          item.add(Formats.fileUri.lazy(() => Uri.parse(widget.item.fileUri!)));
        }
        if (widget.item.content != null) {
          item.add(Formats.plainText.lazy(() => widget.item.content!));
        }
        return item;
      },
      allowedOperations: () => [DropOperation.copy],
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: SqaCard(
          margin: const EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.zero,
          onTap: _copyToClipboard,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        _buildPreview(theme),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.item.content ??
                                    (widget.item.imageBytes != null
                                        ? 'Image Data'
                                        : 'Unknown Data'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.item.formats.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: widget.item.formats
                                          .take(3)
                                          .map(
                                            (String f) => Container(
                                              margin: const EdgeInsets.only(
                                                right: 4,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                    vertical: 1,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: theme
                                                    .colorScheme
                                                    .surfaceContainerHighest,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                f.split('.').last.toUpperCase(),
                                                style: theme
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(fontSize: 8),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isHovered) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: 'Copy again',
                          child: SqaButton.tonal(
                            label: '',
                            icon: Symbols.content_copy,
                            width: 32,
                            onPressed: _copyToClipboard,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: widget.item.isPinned ? 'Unpin' : 'Pin',
                          child: SqaButton.tonal(
                            label: '',
                            icon: widget.item.isPinned
                                ? Symbols.keep
                                : Symbols.push_pin,
                            width: 32,
                            color: widget.item.isPinned
                                ? theme.colorScheme.primary
                                : null,
                            onPressed: () => ref
                                .read(clipboardHistoryProvider.notifier)
                                .togglePin(widget.item.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: 'Delete',
                          child: SqaButton.tonal(
                            label: '',
                            icon: Symbols.delete,
                            width: 32,
                            onPressed: () => ref
                                .read(clipboardHistoryProvider.notifier)
                                .deleteItem(widget.item.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (widget.item.isPinned) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0, right: 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Tooltip(
                          message: 'Unpin',
                          child: SqaButton.tonal(
                            label: '',
                            icon: Symbols.keep,
                            width: 32,
                            color: theme.colorScheme.primary,
                            onPressed: () => ref
                                .read(clipboardHistoryProvider.notifier)
                                .togglePin(widget.item.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    if (widget.item.imageBytes != null) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: MemoryImage(widget.item.imageBytes!),
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    IconData icon = Symbols.description;
    if (widget.item.fileUri != null) icon = Symbols.file_present;

    return SqaIconContainer(
      icon: icon,
      size: 40,
      iconSize: 20,
      color: theme.colorScheme.primary.withValues(alpha: 0.1),
    );
  }
}

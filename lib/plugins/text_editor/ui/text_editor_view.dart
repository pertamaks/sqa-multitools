import 'dart:async';
import 'widgets/text_editor_toolbar.dart';
import 'widgets/text_editor_link_menu.dart';
import 'widgets/text_editor_save_status.dart';
import 'widgets/table_block_builder.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_smart_text.dart';
import '../../../ui/widgets/sqa_window_size_toggle.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../providers/text_editor_provider.dart';
import '../models/text_editor_state.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/code_block_builder.dart';
import 'widgets/code_block_encoder_parser.dart';
import 'widgets/table_node_encoder_parser.dart';
import 'widgets/table_node_loader_parser.dart';
import 'widgets/html_node_loader_parser.dart';
import 'widgets/html_node_encoder_parser.dart';
import 'widgets/html_block_builder.dart';
import 'widgets/text_node_encoder_parsers.dart';
import 'widgets/quote_block_builder.dart';
import 'widgets/sqa_span_inline_syntax.dart';
import 'widgets/list_node_encoder_parsers.dart';
import 'widgets/image_block_builder.dart';
import 'widgets/image_node_encoder_parser.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../../clipboard/utils/clipboard_extensions.dart';
import '../../../ui/widgets/sqa_markdown_viewer.dart';
import '../../../ui/widgets/sqa_button.dart';

class TextEditorView extends ConsumerStatefulWidget {
  const TextEditorView({super.key});

  @override
  ConsumerState<TextEditorView> createState() => _TextEditorViewState();
}

class _TextEditorViewState extends ConsumerState<TextEditorView> {
  late TextEditingController _nameController;
  late EditorState _editorState;
  late EditorScrollController _editorScrollController;
  StreamSubscription<EditorTransactionValue>? _editorSubscription;
  Timer? _syncTimer;
  bool _isDisposed = false;
  final ValueNotifier<int> _formattingNotifier = ValueNotifier<int>(0);
  late FocusNode _titleFocusNode;
  late FocusNode _editorFocusNode;
  bool _isEditingTitle = false;
  final MenuController _linkMenuController = MenuController();
  final FocusNode _linkMenuFocusNode = FocusNode();
  Selection? _selectionBeforeLinkMenu;

  @override
  void initState() {
    super.initState();
    forceShowBlockAction = false;
    final doc = ref.read(textEditorProvider).activeDocument;
    _nameController = TextEditingController(text: doc?.name ?? '');

    // Initialize EditorState from Markdown
    final initialContent = doc?.content ?? '';
    final Document document;

    if (initialContent.isEmpty) {
      document = Document.blank(withInitialText: true);
    } else {
      document = markdownToDocument(
        initialContent,
        markdownParsers: [
          const SqaMarkdownCodeBlockParser(),
          const SqaMarkdownTableParser(),
          const SqaMarkdownHtmlParser(),
          const SqaMarkdownImageParser(),
        ],
        inlineSyntaxes: [SqaSpanInlineSyntax()],
      );
      // Ensure the document has at least one paragraph node for editing
      if (document.root.children.isEmpty) {
        document.root.children.add(paragraphNode());
      }
    }

    _editorState = EditorState(document: document);
    _editorScrollController = EditorScrollController(
      editorState: _editorState,
      shrinkWrap:
          true, // Required for standard ScrollController & Scrollbar support
    );

    _titleFocusNode = FocusNode();
    _titleFocusNode.addListener(_onTitleFocusChange);
    _editorFocusNode = FocusNode();

    // Listen for changes in the editor to sync with provider
    _editorSubscription = _editorState.transactionStream.listen((event) {
      if (event.$1 == TransactionTime.after) {
        _onEditorChanged();
        // Bump formatting notifier to trigger toolbar rebuild
        if (!_isDisposed && mounted) {
          _formattingNotifier.value++;
        }
      }
    });
  }

  String _exportToMarkdown() {
    return documentToMarkdown(
      _editorState.document,
      customParsers: [
        const SqaHeadingNodeParser(),
        const SqaParagraphNodeParser(),
        const SqaCodeBlockNodeParser(),
        const SqaQuoteNodeParser(),
        const SqaTableNodeParser(),
        const SqaHtmlNodeParser(),
        const SqaBulletedListNodeParser(),
        const SqaNumberedListNodeParser(),
        const SqaTodoListNodeParser(),
        const SqaImageNodeParser(),
      ],
    );
  }

  List<CommandShortcutEvent> _buildCommandShortcuts() {
    return [
      // 1. Standard Paste with SQA Markdown Support (The "Smart Paste")
      CommandShortcutEvent(
        key: 'smart_paste',
        command: 'ctrl+v',
        macOSCommand: 'cmd+v',
        getDescription: () => 'Smart Paste',
        handler: (editorState) {
          final selection = editorState.selection;
          if (selection == null) return KeyEventResult.ignored;

          () async {
            // 1. Handle Image Paste via super_clipboard
            final reader = await SystemClipboard.instance?.read();
            if (reader != null) {
              for (final item in reader.items) {
                if (item.canProvide(Formats.png)) {
                  if (_isSelectionInTable()) {
                    _showTableImageBlockMessage();
                    return;
                  }
                  final bytes = await item.readFileValue(Formats.png);
                  if (bytes != null) {
                    final storageNotifier = ref.read(
                      textEditorProvider.notifier,
                    );
                    final relativePath = await storageNotifier.saveImageBytes(
                      bytes,
                      'png',
                    );

                    final transaction = editorState.transaction;
                    final imageNode = Node(
                      type: ImageBlockKeys.type,
                      attributes: {
                        ImageBlockKeys.url: relativePath,
                        'alt': 'Pasted Image',
                      },
                    );
                    transaction.insertNode(selection.end.path, imageNode);
                    await editorState.apply(transaction);
                    return; // Handled as image
                  }
                }
              }
            }

            // 2. Handle Text Paste
            final data = await AppFlowyClipboard.getData();
            final text = data.text;
            if (text != null && text.isNotEmpty) {
              // Check if it looks like Markdown
              final isMarkdown =
                  text.contains('```') ||
                  text.contains('# ') ||
                  text.contains('> ') ||
                  text.contains('* ') ||
                  text.contains('- ') ||
                  text.contains('1. ') ||
                  text.contains('![');

              if (isMarkdown) {
                final document = markdownToDocument(
                  text,
                  markdownParsers: [
                    const SqaMarkdownCodeBlockParser(),
                    const SqaMarkdownTableParser(),
                    const SqaMarkdownHtmlParser(),
                    const SqaMarkdownImageParser(),
                  ],
                  inlineSyntaxes: [SqaSpanInlineSyntax()],
                );
                final nodes = document.root.children.toList();
                if (nodes.isNotEmpty) {
                  final transaction = editorState.transaction;

                  // Perform a structural insertion at the current cursor
                  transaction.insertNodes(selection.end.path, nodes);

                  // Calculate the new selection (at the end of the inserted nodes)
                  var newPath = selection.end.path;
                  for (var i = 0; i < nodes.length - 1; i++) {
                    newPath = newPath.next;
                  }
                  final lastNodeLen = nodes.lastOrNull?.delta?.length ?? 0;
                  transaction.afterSelection = Selection.collapsed(
                    Position(path: newPath, offset: lastNodeLen),
                  );

                  await editorState.apply(transaction);
                  return;
                }
              }

              // Fallback: Insert as plain text paragraphs
              final transaction = editorState.transaction;
              final lines = text.split('\n');
              final nodes = lines
                  .map((line) => paragraphNode(delta: Delta()..insert(line)))
                  .toList();
              transaction.insertNodes(selection.end.path, nodes);
              await editorState.apply(transaction);
            }
          }();
          return KeyEventResult.handled;
        },
      ),

      ...tableCommands,
      ...standardCommandShortcutEvents,
    ];
  }

  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders(
    String? storagePath,
  ) {
    final theme = Theme.of(context);
    final map = <String, BlockComponentBuilder>{
      ...standardBlockComponentBuilderMap,
    };

    // 1. Standard Paragraph Builder (Refined)
    map[ParagraphBlockKeys.type] = ParagraphBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
    )..showActions = (_) => false;

    // 2. Standard Heading Builder (Refined)
    map[HeadingBlockKeys.type] = HeadingBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
      textStyleBuilder: (level) {
        final fontSizes = [24.0, 20.0, 18.0, 16.0, 14.0, 14.0];
        return GoogleFonts.inter(
          fontSize: fontSizes[level - 1],
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );
      },
    )..showActions = (_) => false;

    // 3. Table Builders
    // MAINTENANCE NOTE: The appflowy_editor split table handling across two builders:
    // - TableBlockComponentBuilder: Handles the table container and COLUMN handles (via TableCol).
    // - TableCellBlockComponentBuilder: Handles individual cells and ROW handles (via TableCellBlockWidget).
    // We override both to inject our standardized MenuAnchor system.

    map[TableBlockKeys.type] = SqaTableBlockComponentBuilder(
      tableStyle: TableStyle(
        borderWidth: 1.0,
        borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        borderHoverColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        addIcon: Icon(
          Symbols.add,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      menuBuilder: _buildTableMenu,
    );
    map[TableCellBlockKeys.type] = SqaTableCellBlockComponentBuilder(
      menuBuilder: _buildTableMenu,
    );

    // 4. Custom Code Block Builder
    final codeBlockBuilder = SqaCodeBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
    );
    map['code'] = codeBlockBuilder;
    map['code_block'] = codeBlockBuilder;

    // 5. Custom Quote Block Builder
    map[QuoteBlockKeys.type] = SqaQuoteBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
    );

    // Hide handles for all other blocks
    for (final entry in map.entries) {
      if (entry.key != HeadingBlockKeys.type &&
          entry.key != ParagraphBlockKeys.type &&
          entry.key != TableBlockKeys.type &&
          entry.key != 'code' &&
          entry.key != 'code_block' &&
          entry.key != QuoteBlockKeys.type) {
        entry.value.showActions = (_) => false;
      }
    }

    // 13. SQA HTML Safety Net Builder
    map['raw_html'] = RawHtmlBlockComponentBuilder();

    // 14. Custom Image Builder
    map[ImageBlockKeys.type] = SqaImageBlockComponentBuilder(
      storagePath: storagePath,
    );

    return map;
  }

  Widget _buildTableMenu(
    Node node,
    EditorState editorState,
    int position,
    TableDirection direction,
    VoidCallback? onShow,
    VoidCallback? onDismiss,
  ) {
    final theme = Theme.of(context);
    final isRow = direction == TableDirection.row;
    final isCol = direction == TableDirection.col;

    return MenuAnchor(
      style: _sqaMenuStyle(context),
      onOpen: onShow,
      onClose: onDismiss,
      builder: (context, controller, child) {
        return SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                borderRadius: SqaStyles.radiusSmall,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: controller.isOpen
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface.withValues(alpha: 0.9),
                    borderRadius: SqaStyles.radiusSmall,
                    border: Border.all(
                      color: controller.isOpen
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      width: 1.0,
                    ),
                    boxShadow: [
                      if (!controller.isOpen)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: isCol ? 1.5708 : 0,
                      child: Icon(
                        Symbols.drag_indicator,
                        size: 16,
                        color: controller.isOpen
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      menuChildren: [
        _buildTableMenuItem(
          icon: Transform.rotate(
            angle: isRow ? -1.5708 : 3.14159,
            child: const Icon(Symbols.keyboard_tab, size: 18),
          ),
          label: isRow ? 'Add Row Above' : 'Add Column Left',
          onTap: () => TableActions.add(node, position, editorState, direction),
        ),
        _buildTableMenuItem(
          icon: Transform.rotate(
            angle: isRow ? 1.5708 : 0,
            child: const Icon(Symbols.keyboard_tab, size: 18),
          ),
          label: isRow ? 'Add Row Below' : 'Add Column Right',
          onTap: () =>
              TableActions.add(node, position + 1, editorState, direction),
        ),
        const Divider(height: 8, thickness: 0.5),
        _buildTableMenuItem(
          icon: const Icon(Symbols.content_copy, size: 18),
          label: isRow ? 'Duplicate Row' : 'Duplicate Column',
          onTap: () =>
              TableActions.duplicate(node, position, editorState, direction),
        ),
        _buildTableMenuItem(
          icon: const Icon(Symbols.backspace, size: 18),
          label: 'Clear Content',
          onTap: () =>
              TableActions.clear(node, position, editorState, direction),
        ),
        const Divider(height: 8, thickness: 0.5),
        SubmenuButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
            ),
          ),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
            surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
            ),
          ),
          menuChildren: [
            _buildColorOption(
              context,
              'None',
              null,
              node,
              position,
              editorState,
              direction,
            ),
            const Divider(height: 4),
            _buildColorOption(
              context,
              'Warm Sand',
              '#D7CCC8',
              node,
              position,
              editorState,
              direction,
            ),
            _buildColorOption(
              context,
              'Slate',
              '#B0BEC5',
              node,
              position,
              editorState,
              direction,
            ),
            _buildColorOption(
              context,
              'Soft Peach',
              '#FFCCBC',
              node,
              position,
              editorState,
              direction,
            ),
            _buildColorOption(
              context,
              'Dusty Sage',
              '#C8E6C9',
              node,
              position,
              editorState,
              direction,
            ),
            _buildColorOption(
              context,
              'Soft Lilac',
              '#D1C4E9',
              node,
              position,
              editorState,
              direction,
            ),
            _buildColorOption(
              context,
              'Pale Teal',
              '#B2DFDB',
              node,
              position,
              editorState,
              direction,
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(
                  Symbols.format_color_fill,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  'Background Color',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
        const Divider(height: 8, thickness: 0.5),
        _buildTableMenuItem(
          icon: Icon(Symbols.delete, size: 18, color: theme.colorScheme.error),
          label: isRow ? 'Delete Row' : 'Delete Column',
          color: theme.colorScheme.error,
          onTap: () =>
              TableActions.delete(node, position, editorState, direction),
        ),
      ],
    );
  }

  Widget _buildColorOption(
    BuildContext context,
    String name,
    String? hexColor,
    Node node,
    int position,
    EditorState editorState,
    TableDirection direction,
  ) {
    final theme = Theme.of(context);
    final color = hexColor != null
        ? Color(int.parse(hexColor.replaceFirst('#', '0xFF')))
        : null;

    return MenuItemButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
        ),
      ),
      onPressed: () => TableActions.setBgColor(
        node,
        position,
        editorState,
        hexColor,
        direction,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color ?? Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                  width: color == null ? 1.5 : 0.5,
                ),
              ),
              child: color == null
                  ? Center(
                      child: Transform.rotate(
                        angle: 0.785,
                        child: Container(
                          width: 1.2,
                          height: 14,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableMenuItem({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return MenuItemButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
        ),
      ),
      onPressed: onTap,
      leadingIcon: IconTheme(
        data: IconThemeData(color: color ?? theme.colorScheme.onSurfaceVariant),
        child: icon,
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color ?? theme.colorScheme.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  MenuStyle _sqaMenuStyle(BuildContext context) {
    final theme = Theme.of(context);
    return MenuStyle(
      backgroundColor: WidgetStateProperty.all(theme.colorScheme.surface),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      elevation: WidgetStateProperty.all(8.0),
      padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: SqaStyles.radiusLarge,
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _syncTimer?.cancel();
    _formattingNotifier.dispose();
    _nameController.dispose();
    _editorSubscription?.cancel();
    _editorState.dispose();
    _editorScrollController.dispose();
    _titleFocusNode.removeListener(_onTitleFocusChange);
    _titleFocusNode.dispose();
    _editorFocusNode.dispose();
    _linkMenuFocusNode.dispose();
    _closeLinkMenu();
    super.dispose();
  }

  void _onEditorChanged() {
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 300), () {
      if (_isDisposed || !mounted) return;

      // Structural changes (like deleting a column) can leave the table in a
      // transitional state for a micro-beat. We wait for the post-frame callback
      // to ensure the internal re-indexing is complete before encoding.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isDisposed || !mounted) return;

        try {
          final currentContent =
              ref.read(textEditorProvider).activeDocument?.content ?? '';
          final newContent = _exportToMarkdown();
          if (newContent != currentContent) {
            ref.read(textEditorProvider.notifier).updateContent(newContent);
          }
        } catch (e) {
          // Silently catch temporary encoding errors during structural transitions
          debugPrint(
            'Text Editor: Encoding skipped due to transitional state: $e',
          );
        }
      });
    });
  }

  void _onTitleFocusChange() {
    if (_isDisposed || !mounted) return;
    if (!_titleFocusNode.hasFocus && _isEditingTitle) {
      _submitTitle();
    }
  }

  void _submitTitle() {
    if (_isDisposed || !mounted || !_isEditingTitle) return;
    ref.read(textEditorProvider.notifier).updateName(_nameController.text);
    if (mounted) setState(() => _isEditingTitle = false);
  }

  Future<void> _handleBack() async {
    final hasUnsavedChanges = ref.read(textEditorProvider).hasUnsavedChanges;
    if (hasUnsavedChanges) {
      final confirm = await SqaModal.showDanger(
        context,
        title: 'Discard Changes?',
        message:
            'You have unsaved changes. Are you sure you want to discard them?',
        confirmLabel: 'Discard',
      );
      if (confirm != true) return;
    }

    // Cancel all pending background syncs before switching view
    _syncTimer?.cancel();
    _isDisposed = true;

    ref.read(textEditorProvider.notifier).setViewMode(TextEditorViewMode.list);
  }

  bool _isSelectionInTable() {
    final selection = _editorState.selection;
    if (selection == null) return false;

    Node? node = _editorState.getNodeAtPath(selection.start.path);
    while (node != null) {
      if (node.type == TableBlockKeys.type ||
          node.type == TableCellBlockKeys.type) {
        return true;
      }
      node = node.parent;
    }
    return false;
  }

  void _showTableImageBlockMessage() {
    if (!mounted) return;
    SqaToast.show(
      context,
      'Image insertion inside tables is not supported yet.',
      type: SqaToastType.warning,
    );
  }

  bool _isAttributeToggled(String key) {
    final selection = _editorState.selection;
    if (selection == null) return false;

    if (selection.isCollapsed) {
      final toggledValue = _editorState.toggledStyle[key];
      if (toggledValue != null) return toggledValue == true;

      return _editorState.getDeltaAttributesInSelectionStart()?[key] == true;
    }

    final nodes = _editorState.getNodesInSelection(selection);
    return nodes.allSatisfyInSelection(selection, (delta) {
      return delta.everyAttributes((attributes) => attributes[key] == true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(textEditorProvider);
    final notifier = ref.read(textEditorProvider.notifier);

    // Sync title controller with state if not actively editing
    ref.listen(textEditorProvider.select((s) => s.activeDocument?.name), (
      prev,
      next,
    ) {
      if (next != null && next != _nameController.text && !_isEditingTitle) {
        _nameController.text = next;
      }
    });

    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 20,
      color: theme.colorScheme.primary,
      letterSpacing: -0.5,
    );

    final isViewer = state.viewMode == TextEditorViewMode.viewer;

    if (isViewer) {
      return SqaPluginLayout(
        title: _nameController.text.isEmpty ? 'Document' : _nameController.text,
        onBack: _handleBack,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SqaButton(
              label: 'Edit Mode',
              icon: Symbols.edit,
              onPressed: () => notifier.openEditor(state.activeDocument),
              type: SqaButtonType.tonal,
            ),
          ],
        ),
        child: SqaMarkdownViewer(
          markdown: state.activeDocument?.content ?? '',
        ),
      );
    }

    return SqaPluginLayout(
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: _isEditingTitle
            ? Align(
                key: const ValueKey('editing'),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: _nameController,
                  focusNode: _titleFocusNode,
                  autofocus: true,
                  style: titleStyle,
                  decoration: InputDecoration(
                    hintText: 'Document Title',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() {}),
                  onSubmitted: (_) => _submitTitle(),
                  onTapOutside: (_) {
                    _titleFocusNode.unfocus();
                  },
                ),
              )
            : Align(
                key: const ValueKey('viewing'),
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: double.infinity,
                  child: SqaSmartText(
                    text: _nameController.text.isEmpty
                        ? 'Document Title'
                        : _nameController.text,
                    style: _nameController.text.isEmpty
                        ? titleStyle?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.2,
                            ),
                          )
                        : titleStyle,
                    onTap: () {
                      setState(() => _isEditingTitle = true);
                      _titleFocusNode.requestFocus();
                    },
                  ),
                ),
              ),
      ),
      onBack: _handleBack,
      useMask: false, // Disable global mask to keep toolbar opaque
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Status Indicator (Always visible, changes color)
          TextEditorSaveStatus(state: state),
          const SizedBox(width: 4),
          // 2. Manual Save Button
          SqaHoverIconButton(
            icon: Symbols.save,
            onPressed: state.isSaving
                ? () {} // Disabled handled internally or by provider
                : () async {
                    await notifier.saveDocument();
                    if (context.mounted) {
                      SqaToast.show(
                        context,
                        'Document Saved',
                        type: SqaToastType.success,
                      );
                    }
                  },
            tooltip: 'Save document',
            iconSize: 20,
            hoverColor: theme.colorScheme.primary,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SqaFadeWrapper(
              child: Theme(
                data: theme.copyWith(
                  // 1. Theme Selection Handles & Cursors
                  textSelectionTheme: TextSelectionThemeData(
                    selectionHandleColor: theme.colorScheme.primary,
                    selectionColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    cursorColor: theme.colorScheme.primary,
                  ),
                  // 2. Theme Menus (Table Context Menus, etc.)
                  menuTheme: MenuThemeData(
                    style: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(
                        theme.colorScheme.surface,
                      ),
                      surfaceTintColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      elevation: WidgetStateProperty.all(8.0),
                      padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: SqaStyles.radiusLarge,
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 3. Theme Popup Menus (Alternative menu system)
                  popupMenuTheme: PopupMenuThemeData(
                    color: theme.colorScheme.surface,
                    surfaceTintColor: Colors.transparent,
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: SqaStyles.radiusLarge,
                      side: BorderSide(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // 4. Theme Icons (Handles/Buttons)
                  iconTheme: theme.iconTheme.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                // NOTE: Do NOT wrap with an external Scrollbar here.
                // In shrinkWrap mode, AppFlowy's PageBlockComponent creates its own
                // internal SingleChildScrollView with an unshared ScrollController.
                // The global ScrollbarThemeData handles scrollbar visibility instead.
                child: Stack(
                  children: [
                    AppFlowyEditor(
                      key: ValueKey(_editorState.hashCode),
                      editorState: _editorState,
                      autoFocus: true,
                      focusNode: _editorFocusNode,
                      blockComponentBuilders: _buildBlockComponentBuilders(
                        state.savePath,
                      ),
                      commandShortcutEvents: _buildCommandShortcuts(),
                      editorScrollController: _editorScrollController,
                      shrinkWrap: true,
                      editorStyle: EditorStyle.desktop(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 48.0,
                          vertical: 12.0,
                        ),
                        maxWidth: 800.0,
                        textScaleFactor: 14.0 / 16.0,
                        cursorColor: theme.colorScheme.primary,
                        selectionColor: theme.colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                        textSpanDecorator: _sqaTextSpanDecorator,
                        textStyleConfiguration: TextStyleConfiguration(
                          text: GoogleFonts.inter(
                            fontSize: 16.0,
                            height: 1.5,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    // Position-locked anchor for the hyperlink menu
                    _buildSelectionLinkMenuAnchor(),
                  ],
                ),
              ),
            ),
          ),
          TextEditorToolbar(
            editorState: _editorState,
            formattingNotifier: _formattingNotifier,
            onShowLinkMenu: _showLinkMenuAtSelection,
            exportToMarkdown: _exportToMarkdown,
            isAttributeToggled: _isAttributeToggled,
            isLinkMenuOpen: _linkMenuController.isOpen,
          ),
          const Positioned(bottom: 4, right: 4, child: SqaWindowSizeToggle()),
        ],
      ),
    );
  }

  void _showLinkMenuAtSelection() {
    if (_editorState.selection != null) {
      _selectionBeforeLinkMenu = _editorState.selection;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_linkMenuController.isOpen) {
        _linkMenuController.open();
      }
    });
  }

  void _closeLinkMenu() {
    _linkMenuController.close();
    if (!_isDisposed && mounted) {
      setState(() {}); // Update toolbar button state
    }
  }

  Widget _buildSelectionLinkMenuAnchor() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        _editorState.selectionNotifier,
        _editorScrollController.offsetNotifier,
      ]),
      builder: (context, _) {
        // Use cached selection if menu is open to prevent "blinking" during focus transitions
        final selection = _linkMenuController.isOpen
            ? (_selectionBeforeLinkMenu ?? _editorState.selection)
            : _editorState.selection;

        if (selection == null) return const SizedBox.shrink();

        final rects = _getSelectionRects(selection);
        if (rects.isEmpty) return const SizedBox.shrink();

        final firstRect = rects.first;

        return Positioned(
          top: firstRect.bottom,
          left: firstRect.left,
          child: MenuAnchor(
            key: const GlobalObjectKey('unified_link_menu_anchor'),
            controller: _linkMenuController,
            alignmentOffset: const Offset(0, 8),
            style: _sqaMenuStyle(context),
            onOpen: () {
              keepEditorFocusNotifier.increase();
              setState(() {});
            },
            onClose: () {
              keepEditorFocusNotifier.decrease();
              setState(() {});
            },
            menuChildren: [_buildLinkMenu(context)],
            child: const SizedBox(width: 1, height: 1),
          ),
        );
      },
    );
  }

  TextSpan _sqaTextSpanDecorator(
    BuildContext context,
    Node node,
    int index,
    TextInsert text,
    TextSpan before,
    TextSpan after,
  ) {
    final attributes = text.attributes;
    if (attributes == null) {
      return before;
    }
    final href = attributes[AppFlowyRichTextKeys.href] as String?;
    if (href != null) {
      Timer? timer;
      int tapCount = 0;

      final tapGestureRecognizer = TapGestureRecognizer()
        ..onTap = () {
          tapCount += 1;
          timer?.cancel();

          if (tapCount == 2 ||
              !_editorState.editable ||
              HardwareKeyboard.instance.isControlPressed ||
              HardwareKeyboard.instance.isMetaPressed) {
            tapCount = 0;
            launchUrl(Uri.parse(href));
            return;
          }

          timer = Timer(const Duration(milliseconds: 200), () async {
            tapCount = 0;
            final selection = Selection.single(
              path: node.path,
              startOffset: index,
              endOffset: index + text.text.length,
            );
            await _editorState.updateSelectionWithReason(
              selection,
              reason: SelectionUpdateReason.uiEvent,
            );

            _selectionBeforeLinkMenu = selection;
            // Show our custom link menu at this selection
            _showLinkMenuAtSelection();
          });
        };

      return TextSpan(
        style: before.style,
        text: text.text,
        recognizer: tapGestureRecognizer,
        mouseCursor: SystemMouseCursors.click,
      );
    }

    return before;
  }

  List<Rect> _getSelectionRects(Selection selection) {
    final nodes = _editorState.getNodesInSelection(selection);
    final rects = <Rect>[];

    if (selection.isCollapsed && nodes.length == 1) {
      final selectable = nodes.first.selectable;
      if (selectable != null) {
        final rect = selectable.getCursorRectInPosition(
          selection.end,
          shiftWithBaseOffset: true,
        );
        if (rect != null) {
          rects.add(
            selectable.transformRectToGlobal(rect, shiftWithBaseOffset: true),
          );
        }
      }
    } else {
      for (final node in nodes) {
        final selectable = node.selectable;
        if (selectable == null) {
          continue;
        }
        final nodeRects = selectable.getRectsInSelection(
          selection,
          shiftWithBaseOffset: true,
        );
        if (nodeRects.isEmpty) {
          continue;
        }
        final renderBox = node.renderBox;
        if (renderBox == null) {
          continue;
        }
        for (final rect in nodeRects) {
          final globalOffset = renderBox.localToGlobal(rect.topLeft);
          rects.add(globalOffset & rect.size);
        }
      }
    }

    // Convert global rects to local Stack coordinates
    final stackBox = context.findRenderObject() as RenderBox?;
    if (stackBox == null) return rects;

    return rects.map((rect) {
      final localTopLeft = stackBox.globalToLocal(rect.topLeft);
      return localTopLeft & rect.size;
    }).toList();
  }

  Widget _buildLinkMenu(BuildContext context) {
    final editorState = _editorState;
    final selection = _selectionBeforeLinkMenu ?? editorState.selection;

    String? initialUrl;
    if (selection != null) {
      final node = editorState.getNodeAtPath(selection.start.path);
      final delta = node?.delta;
      if (delta != null) {
        final start = selection.startIndex;
        final end = selection.endIndex;
        var currentOffset = 0;
        for (final op in delta.whereType<TextInsert>()) {
          final length = op.length;
          final opEnd = currentOffset + length;

          // Check if op overlaps with selection
          if (!(opEnd <= start ||
              currentOffset >= (selection.isCollapsed ? start + 1 : end))) {
            final href = op.attributes?[AppFlowyRichTextKeys.href] as String?;
            if (href != null && href.isNotEmpty) {
              initialUrl = href;
              break;
            }
          }
          currentOffset = opEnd;
        }
      }
    }

    return SizedBox(
      width: 300,
      child: SqaLinkMenuWidget(
        initialUrl: initialUrl,
        onSubmitted: (url) {
          final targetSelection =
              _selectionBeforeLinkMenu ?? editorState.selection;
          if (targetSelection == null) return;

          if (url.isEmpty) {
            editorState.formatDelta(targetSelection, {
              AppFlowyRichTextKeys.href: null,
            });
          } else {
            // Ensure protocol
            var finalUrl = url;
            if (!finalUrl.startsWith('http://') &&
                !finalUrl.startsWith('https://') &&
                !finalUrl.startsWith('mailto:')) {
              finalUrl = 'https://$finalUrl';
            }
            editorState.formatDelta(targetSelection, {
              AppFlowyRichTextKeys.href: finalUrl,
            });
          }
          // Focus back to editor
          _editorFocusNode.requestFocus();
          _closeLinkMenu();
        },
        onRemove: () {
          final targetSelection =
              _selectionBeforeLinkMenu ?? editorState.selection;
          if (targetSelection == null) return;

          editorState.formatDelta(targetSelection, {
            AppFlowyRichTextKeys.href: null,
          });
          _editorFocusNode.requestFocus();
          _closeLinkMenu();
        },
      ),
    );
  }
}

/// A custom Table builder that wraps the table in a themed environment for handles.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_smart_text.dart';
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
import 'widgets/sqa_block_component_wrapper.dart';
import 'package:file_selector/file_selector.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../../clipboard/utils/clipboard_extensions.dart';
import '../../../ui/widgets/sqa_color_picker.dart';

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
        inlineSyntaxes: [
          SqaSpanInlineSyntax(),
        ],
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
                    final storageNotifier =
                        ref.read(textEditorProvider.notifier);
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
                  inlineSyntaxes: [
                    SqaSpanInlineSyntax(),
                  ],
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
    final map = <String, BlockComponentBuilder>{...standardBlockComponentBuilderMap};

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

  void _toggleAttribute(String key) {
    _editorState.toggleAttribute(key);
    if (!_isDisposed && mounted) {
      _formattingNotifier.value++;
    }
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
      final confirm = await SqaModal.showConfirm(
        context,
        title: 'Discard Changes?',
        message:
            'You have unsaved changes. Are you sure you want to discard them?',
        confirmLabel: 'Discard',
        confirmColor: Theme.of(context).colorScheme.error,
        icon: Symbols.warning,
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
          _buildSaveStatus(context, state),
          const SizedBox(width: 4),
          // 2. Manual Save Button
          IconButton(
            icon: const Icon(Symbols.save, size: 20),
            onPressed: state.isSaving
                ? null
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
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
              shape: RoundedRectangleBorder(
                borderRadius: SqaStyles.radiusLarge,
              ),
            ),
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
          _buildFloatingToolbar(context),
        ],
      ),
    );
  }

  Widget _buildSaveStatus(BuildContext context, TextEditorState state) {
    final theme = Theme.of(context);
    final hasUnsavedChanges = state.hasUnsavedChanges;
    final isSaving = state.isSaving;

    // Logic:
    // - Colored check ONLY if NOT dirty AND NOT saving
    final bool isSaved = !hasUnsavedChanges && !isSaving;

    return Tooltip(
      message: isSaved
          ? 'All changes saved'
          : (isSaving ? 'Saving...' : 'Unsaved changes'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Symbols.check_circle,
          size: 20,
          color: isSaved
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildFloatingToolbar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = (screenWidth - 140).clamp(0.0, 800.0);

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: barWidth),
          child: ListenableBuilder(
            listenable: Listenable.merge([
              _editorState.selectionNotifier,
              _formattingNotifier,
            ]),
            builder: (context, _) {
              return SqaFloatingBar(
                children: [
                  // Group 1: History
                  SqaFloatingBarButton(
                    icon: Symbols.undo,
                    tooltip: 'Undo',
                    onPressed: _editorState.undoManager.undoStack.isNonEmpty
                        ? () => _editorState.undoManager.undo()
                        : null,
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.redo,
                    tooltip: 'Redo',
                    onPressed: _editorState.undoManager.redoStack.isNonEmpty
                        ? () => _editorState.undoManager.redo()
                        : null,
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 2: Block Identity (Action-First)
                  SqaFloatingBarButton(
                    icon: Symbols.format_h1,
                    tooltip: 'Heading 1',
                    onPressed: () => _editorState.formatNode(
                      _editorState.selection,
                      (node) => node.copyWith(
                        type: HeadingBlockKeys.type,
                        attributes: {
                          HeadingBlockKeys.level: 1,
                          HeadingBlockKeys.delta: node.delta?.toJson() ?? [],
                        },
                      ),
                    ),
                    secondaryActions: [
                      SqaFloatingSubAction(
                        icon: Symbols.format_h2,
                        tooltip: 'Heading 2',
                        onPressed: () => _editorState.formatNode(
                          _editorState.selection,
                          (node) => node.copyWith(
                            type: HeadingBlockKeys.type,
                            attributes: {
                              HeadingBlockKeys.level: 2,
                              HeadingBlockKeys.delta:
                                  node.delta?.toJson() ?? [],
                            },
                          ),
                        ),
                      ),
                      SqaFloatingSubAction(
                        icon: Symbols.format_h3,
                        tooltip: 'Heading 3',
                        onPressed: () => _editorState.formatNode(
                          _editorState.selection,
                          (node) => node.copyWith(
                            type: HeadingBlockKeys.type,
                            attributes: {
                              HeadingBlockKeys.level: 3,
                              HeadingBlockKeys.delta:
                                  node.delta?.toJson() ?? [],
                            },
                          ),
                        ),
                      ),
                      SqaFloatingSubAction(
                        icon: Symbols.text_fields,
                        tooltip: 'Standard Text',
                        onPressed: () => _editorState.formatNode(
                          _editorState.selection,
                          (node) => node.copyWith(
                            type: ParagraphBlockKeys.type,
                            attributes: {
                              ParagraphBlockKeys.delta:
                                  node.delta?.toJson() ?? [],
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_quote,
                    tooltip: 'Quote',
                    onPressed: () => _editorState.formatNode(
                      _editorState.selection,
                      (node) => node.copyWith(
                        type: QuoteBlockKeys.type,
                        attributes: {
                          QuoteBlockKeys.delta: node.delta?.toJson() ?? [],
                        },
                      ),
                    ),
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 3: Typography
                  SqaFloatingBarButton(
                    icon: Symbols.format_bold,
                    tooltip: 'Bold',
                    isSelected: _isAttributeToggled(AppFlowyRichTextKeys.bold),
                    onPressed: () => _toggleAttribute(AppFlowyRichTextKeys.bold),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_italic,
                    tooltip: 'Italic',
                    isSelected: _isAttributeToggled(
                      AppFlowyRichTextKeys.italic,
                    ),
                    onPressed: () => _toggleAttribute(
                      AppFlowyRichTextKeys.italic,
                    ),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_underlined,
                    tooltip: 'Underline',
                    isSelected: _isAttributeToggled(
                      AppFlowyRichTextKeys.underline,
                    ),
                    onPressed: () => _toggleAttribute(
                      AppFlowyRichTextKeys.underline,
                    ),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_strikethrough,
                    tooltip: 'Strikethrough',
                    isSelected: _isAttributeToggled(
                      AppFlowyRichTextKeys.strikethrough,
                    ),
                    onPressed: () => _toggleAttribute(
                      AppFlowyRichTextKeys.strikethrough,
                    ),
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 4: Colors
                  SqaColorPicker(
                    activeColor: _editorState
                        .getDeltaAttributesInSelectionStart()?[
                      AppFlowyRichTextKeys.textColor
                    ] as String?,
                    onColorSelected: (color) {
                      final selection = _editorState.selection;
                      if (selection != null) {
                        _editorState.formatDelta(selection, {
                          AppFlowyRichTextKeys.textColor: color,
                        });
                        if (!_isDisposed && mounted) {
                          _formattingNotifier.value++;
                        }
                      }
                    },
                    child: SqaFloatingBarButton(
                      icon: Symbols.format_color_text,
                      tooltip: 'Text Color',
                      isSelected:
                          _isAttributeToggled(AppFlowyRichTextKeys.textColor),
                      onPressed: () {},
                    ),
                  ),
                  SqaColorPicker(
                    isBackground: true,
                    activeColor: _editorState
                        .getDeltaAttributesInSelectionStart()?[
                      AppFlowyRichTextKeys.backgroundColor
                    ] as String?,
                    onColorSelected: (color) {
                      final selection = _editorState.selection;
                      if (selection != null) {
                        _editorState.formatDelta(selection, {
                          AppFlowyRichTextKeys.backgroundColor: color,
                        });
                        if (!_isDisposed && mounted) {
                          _formattingNotifier.value++;
                        }
                      }
                    },
                    child: SqaFloatingBarButton(
                      icon: Symbols.format_color_fill,
                      tooltip: 'Highlight Color',
                      isSelected: _isAttributeToggled(
                        AppFlowyRichTextKeys.backgroundColor,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 4: Lists (Action-First)
                  SqaFloatingBarButton(
                    icon: Symbols.format_list_bulleted,
                    tooltip: 'Bulleted List',
                    onPressed: () => _editorState.formatNode(
                      _editorState.selection,
                      (node) => node.copyWith(
                        type: BulletedListBlockKeys.type,
                        attributes: {
                          BulletedListBlockKeys.delta:
                              node.delta?.toJson() ?? [],
                        },
                      ),
                    ),
                    secondaryActions: [
                      SqaFloatingSubAction(
                        icon: Symbols.format_list_numbered,
                        tooltip: 'Numbered List',
                        onPressed: () => _editorState.formatNode(
                          _editorState.selection,
                          (node) => node.copyWith(
                            type: NumberedListBlockKeys.type,
                            attributes: {
                              NumberedListBlockKeys.delta:
                                  node.delta?.toJson() ?? [],
                              NumberedListBlockKeys.number: 1,
                            },
                          ),
                        ),
                      ),
                      SqaFloatingSubAction(
                        icon: Symbols.checklist,
                        tooltip: 'Todo List',
                        onPressed: () => _editorState.formatNode(
                          _editorState.selection,
                          (node) => node.copyWith(
                            type: TodoListBlockKeys.type,
                            attributes: {
                              TodoListBlockKeys.delta:
                                  node.delta?.toJson() ?? [],
                              TodoListBlockKeys.checked: false,
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 5: Layout & Objects
                  SqaFloatingBarButton(
                    icon: Symbols.code_blocks,
                    tooltip: 'Code Block',
                    isSelected:
                        _editorState.selection != null &&
                        _editorState
                            .getNodesInSelection(_editorState.selection!)
                            .any((n) => n.type == 'code'),
                    onPressed: () {
                      final selection = _editorState.selection;
                      if (selection == null) return;

                      final nodes = _editorState.getNodesInSelection(selection);
                      final isCodeBlock = nodes.any((n) => n.type == 'code');

                      if (isCodeBlock) {
                        _editorState.formatNode(
                          selection,
                          (node) => node.copyWith(
                            type: ParagraphBlockKeys.type,
                            attributes: {
                              ParagraphBlockKeys.delta:
                                  node.delta?.toJson() ?? [],
                            },
                          ),
                        );
                      } else {
                        _editorState.formatNode(
                          selection,
                          (node) => node.copyWith(
                            type: 'code',
                            attributes: {
                              'delta': node.delta?.toJson() ?? [],
                              'language': 'javascript', // Default
                            },
                          ),
                        );
                      }
                    },
                    secondaryActions: [
                      SqaFloatingSubAction(
                        icon: Symbols.code,
                        tooltip: 'Inline Code',
                        onPressed: () => _editorState.toggleAttribute(
                          AppFlowyRichTextKeys.code,
                        ),
                      ),
                    ],
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.link,
                    tooltip: 'Hyperlink',
                    isSelected:
                        _isAttributeToggled(AppFlowyRichTextKeys.href) ||
                        _linkMenuController.isOpen,
                    onPressed: _showLinkMenuAtSelection,
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.table_chart,
                    tooltip: 'Insert Table',
                    onPressed: () {
                      final selection = _editorState.selection;
                      if (selection != null) {
                        final transaction = _editorState.transaction;
                        final table = TableNode.fromList([
                          ['', ''],
                          ['', ''],
                          ['', ''],
                        ]);
                        transaction.insertNode(selection.end.path, table.node);
                        _editorState.apply(transaction);
                      }
                    },
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.image,
                    tooltip: 'Insert Image',
                    onPressed: () async {
                      final selection = _editorState.selection;
                      if (selection == null) return;

                      if (_isSelectionInTable()) {
                        _showTableImageBlockMessage();
                        return;
                      }

                      const XTypeGroup typeGroup = XTypeGroup(
                        label: 'images',
                        extensions: <String>['jpg', 'png', 'jpeg', 'gif'],
                      );
                      final XFile? file = await openFile(
                        acceptedTypeGroups: <XTypeGroup>[typeGroup],
                      );

                      if (file != null) {
                        final storageNotifier =
                            ref.read(textEditorProvider.notifier);
                        final relativePath =
                            await storageNotifier.saveImageAttachment(
                              file.path,
                            );

                        final transaction = _editorState.transaction;
                        final imageNode = Node(
                          type: ImageBlockKeys.type,
                          attributes: {
                            ImageBlockKeys.url: relativePath,
                            'alt': file.name,
                          },
                        );
                        transaction.insertNode(selection.end.path, imageNode);
                        await _editorState.apply(transaction);
                      }
                    },
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 6: Clipboard Actions
                  SqaFloatingBarButton(
                    icon: Symbols.content_copy,
                    tooltip: 'Copy Markdown',
                    onPressed: () async {
                      final md = _exportToMarkdown();
                      await Clipboard.setData(ClipboardData(text: md));
                      if (!context.mounted) return;
                      SqaToast.show(
                        context,
                        'Markdown copied to clipboard',
                        type: SqaToastType.success,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
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
          if (!(opEnd <= start || currentOffset >= (selection.isCollapsed ? start + 1 : end))) {
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
      child: _SqaLinkMenuWidget(
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
class SqaTableBlockComponentBuilder extends TableBlockComponentBuilder {
  SqaTableBlockComponentBuilder({
    super.configuration,
    super.tableStyle,
    super.menuBuilder,
  });

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final widget = super.build(blockComponentContext);
    final theme = Theme.of(blockComponentContext.buildContext);

    return SqaBlockComponentWrapper(
      node: widget.node,
      configuration: widget.configuration,
      showActions: widget.showActions,
      actionBuilder: widget.actionBuilder,
      actionTrailingBuilder: widget.actionTrailingBuilder,
      child: SqaFadeWrapper(
        axis: Axis.horizontal,
        showStart: true,
        showEnd: true,
        child: Theme(
          data: theme.copyWith(
            iconTheme: IconThemeData(
              color: theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            // MAINTENANCE: Standardize the hardcoded Card widgets in appflowy_editor's TableActionButton
            cardTheme: CardThemeData(
              color: theme.colorScheme.surfaceContainerHigh,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                  width: 1,
                ),
              ),
            ),
          ),
          child: widget,
        ),
      ),
    );
  }
}

/// A customized TableCellBlockComponentBuilder that injects SQA-standard row handles.
/// In appflowy_editor, the row-level interaction handles are provided by the cell builder.
class SqaTableCellBlockComponentBuilder extends TableCellBlockComponentBuilder {
  SqaTableCellBlockComponentBuilder({super.menuBuilder});

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final widget = super.build(blockComponentContext);

    // Standardize the row handle behavior via the block wrapper pattern
    return SqaBlockComponentWrapper(
      node: widget.node,
      configuration: widget.configuration,
      child: widget,
    );
  }
}

/// A concrete wrapper for BlockComponentWidget that allows themed child wrapping.
class _SqaLinkMenuWidget extends StatefulWidget {
  final String? initialUrl;
  final void Function(String) onSubmitted;
  final VoidCallback onRemove;

  const _SqaLinkMenuWidget({
    this.initialUrl,
    required this.onSubmitted,
    required this.onRemove,
  });

  @override
  State<_SqaLinkMenuWidget> createState() => _SqaLinkMenuWidgetState();
}

class _SqaLinkMenuWidgetState extends State<_SqaLinkMenuWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Symbols.link, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                widget.initialUrl == null ? 'Add Link' : 'Edit Link',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Paste or type a link...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              border: OutlineInputBorder(
                borderRadius: SqaStyles.radiusMedium,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SqaStyles.radiusMedium,
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Symbols.check_circle,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => widget.onSubmitted(_controller.text),
              ),
            ),
            onSubmitted: widget.onSubmitted,
          ),
          if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: 8),
            _buildLinkMenuItem(
              icon: Symbols.open_in_new,
              label: 'Open Link',
              onTap: () async {
                final uri = Uri.tryParse(widget.initialUrl!);
                if (uri != null) {
                  await launchUrl(uri);
                }
              },
            ),
            _buildLinkMenuItem(
              icon: Symbols.content_copy,
              label: 'Copy Link',
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.initialUrl!));
                SqaToast.show(context, 'Link copied to clipboard');
              },
            ),
            _buildLinkMenuItem(
              icon: Symbols.link_off,
              label: 'Remove Link',
              color: theme.colorScheme.error,
              onTap: widget.onRemove,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: SqaStyles.radiusMedium,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: color ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color ?? theme.colorScheme.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


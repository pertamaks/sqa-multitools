import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_smart_text.dart';
import '../providers/text_editor_provider.dart';
import '../models/text_editor_state.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:google_fonts/google_fonts.dart';

class TextEditorView extends ConsumerStatefulWidget {
  const TextEditorView({super.key});

  @override
  ConsumerState<TextEditorView> createState() => _TextEditorViewState();
}

class _TextEditorViewState extends ConsumerState<TextEditorView> {
  late TextEditingController _nameController;
  late EditorState _editorState;
  StreamSubscription<EditorTransactionValue>? _editorSubscription;
  late FocusNode _titleFocusNode;
  late FocusNode _editorFocusNode;
  bool _isEditingTitle = false;

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
      document = markdownToDocument(initialContent);
      // Ensure the document has at least one paragraph node for editing
      if (document.root.children.isEmpty) {
        document.root.children.add(paragraphNode());
      }
    }
    
    _editorState = EditorState(document: document);
    
    _titleFocusNode = FocusNode();
    _titleFocusNode.addListener(_onTitleFocusChange);
    _editorFocusNode = FocusNode();
    
    // Listen for changes in the editor to sync with provider
    _editorSubscription = _editorState.transactionStream.listen((event) {
      if (event.$1 == TransactionTime.after) {
        _onEditorChanged();
      }
    });
  }

  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final map = {...standardBlockComponentBuilderMap};
    final theme = Theme.of(context);

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

    // Hide handles for all other blocks
    for (final entry in map.entries) {
      if (entry.key != HeadingBlockKeys.type && entry.key != ParagraphBlockKeys.type) {
        entry.value.showActions = (_) => false;
      }
    }

    return map;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _editorSubscription?.cancel();
    _editorState.dispose();
    _titleFocusNode.removeListener(_onTitleFocusChange);
    _titleFocusNode.dispose();
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _onEditorChanged() {
    final currentContent = ref.read(textEditorProvider).activeDocument?.content ?? '';
    final newContent = documentToMarkdown(_editorState.document);
    if (newContent != currentContent) {
      ref.read(textEditorProvider.notifier).updateContent(newContent);
    }
  }

  void _onTitleFocusChange() {
    if (!_titleFocusNode.hasFocus && _isEditingTitle) {
      _submitTitle();
    }
  }

  void _submitTitle() {
    if (!_isEditingTitle) return;
    ref.read(textEditorProvider.notifier).updateName(_nameController.text);
    setState(() => _isEditingTitle = false);
  }

  bool get _isDirty {
    final doc = ref.read(textEditorProvider).activeDocument;
    if (doc == null) return false;
    final currentContent = documentToMarkdown(_editorState.document);
    return _nameController.text != doc.name ||
        currentContent != doc.content;
  }

  Future<void> _handleBack() async {
    if (_isDirty) {
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
    ref.read(textEditorProvider.notifier).setViewMode(TextEditorViewMode.list);
  }

  bool _isAttributeToggled(String key) {
    final selection = _editorState.selection;
    if (selection == null) return false;
    
    if (selection.isCollapsed) {
      return _editorState.toggledStyle[key] == true || 
             (_editorState.getDeltaAttributesInSelectionStart()?[key] == true);
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
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.2),
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
      trailing: IconButton(
        icon: state.isSaving
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.primary,
                ),
              )
            : const Icon(Symbols.check, size: 20),
        onPressed: state.isSaving
            ? null
            : () {
                notifier.updateContent(documentToMarkdown(_editorState.document));
                notifier.saveDocument();
              },
        tooltip: 'Save document',
        style: IconButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.all(8),
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SqaFadeWrapper(
              child: AppFlowyEditor(
                key: ValueKey(_editorState.hashCode),
                editorState: _editorState,
                autoFocus: true,
                focusNode: _editorFocusNode,
                blockComponentBuilders: _buildBlockComponentBuilders(),
                commandShortcutEvents: [
                  CommandShortcutEvent(
                    key: 'paste markdown refresh',
                    getDescription: () => 'Paste and Refresh',
                    command: 'ctrl+v',
                    macOSCommand: 'cmd+v',
                    handler: (editorState) {
                      () async {
                        final data = await AppFlowyClipboard.getData();
                        final text = data.text;
                        if (text != null && text.isNotEmpty) {
                          final selection = editorState.selection;
                          if (selection == null) return;

                          final document = markdownToDocument(text);
                          final transaction = editorState.transaction;
                          
                          // Perform a structural insertion at the current cursor
                          transaction.insertNodes(selection.end.path, document.root.children);
                          
                          // Calculate the new selection (at the end of the inserted nodes)
                          var newPath = selection.end.path;
                          for (var i = 0; i < document.root.children.length - 1; i++) {
                            newPath = newPath.next;
                          }
                          final lastNodeLen = document.root.children.lastOrNull?.delta?.length ?? 0;
                          transaction.afterSelection = Selection.collapsed(
                            Position(path: newPath, offset: lastNodeLen)
                          );

                          await editorState.apply(transaction);
                        }
                      }();
                      return KeyEventResult.handled;
                    },
                  ),
                  ...standardCommandShortcutEvents,
                ],
                editorStyle: EditorStyle.desktop(
                  padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 12.0),
                  maxWidth: 800.0,
                  textScaleFactor: 14.0 / 16.0,
                  cursorColor: theme.colorScheme.primary,
                  selectionColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  textStyleConfiguration: TextStyleConfiguration(
                    text: GoogleFonts.inter(
                      fontSize: 16.0,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildFloatingToolbar(context),
        ],
      ),
    );
  }

  Widget _buildFloatingToolbar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = (screenWidth - 160).clamp(0.0, 800.0);

    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: barWidth),
          child: ListenableBuilder(
            listenable: _editorState.selectionNotifier,
            builder: (context, _) {
              return SqaFloatingBar(
                children: [
                  // Group 1: History
                  SqaFloatingBarButton(
                    icon: Symbols.undo,
                    tooltip: 'Undo',
                    onPressed: _editorState.undoManager.undoStack.isNonEmpty ? () => _editorState.undoManager.undo() : null,
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.redo,
                    tooltip: 'Redo',
                    onPressed: _editorState.undoManager.redoStack.isNonEmpty ? () => _editorState.undoManager.redo() : null,
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
                              HeadingBlockKeys.delta: node.delta?.toJson() ?? [],
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
                              HeadingBlockKeys.delta: node.delta?.toJson() ?? [],
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
                              ParagraphBlockKeys.delta: node.delta?.toJson() ?? [],
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SqaFloatingBarDivider(),
                  
                  // Group 3: Typography
                  SqaFloatingBarButton(
                    icon: Symbols.format_bold,
                    tooltip: 'Bold',
                    isSelected: _isAttributeToggled(AppFlowyRichTextKeys.bold),
                    onPressed: () => _editorState.toggleAttribute(AppFlowyRichTextKeys.bold),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_italic,
                    tooltip: 'Italic',
                    isSelected: _isAttributeToggled(AppFlowyRichTextKeys.italic),
                    onPressed: () => _editorState.toggleAttribute(AppFlowyRichTextKeys.italic),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_underlined,
                    tooltip: 'Underline',
                    isSelected: _isAttributeToggled(AppFlowyRichTextKeys.underline),
                    onPressed: () => _editorState.toggleAttribute(AppFlowyRichTextKeys.underline),
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
                          BulletedListBlockKeys.delta: node.delta?.toJson() ?? [],
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
                              NumberedListBlockKeys.delta: node.delta?.toJson() ?? [],
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
                              TodoListBlockKeys.delta: node.delta?.toJson() ?? [],
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
                    icon: Symbols.code,
                    tooltip: 'Code Block',
                    isSelected: _isAttributeToggled(AppFlowyRichTextKeys.code),
                    onPressed: () => _editorState.toggleAttribute(AppFlowyRichTextKeys.code),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.link,
                    tooltip: 'Hyperlink',
                    onPressed: () {
                      // Link toggle logic
                    },
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 6: Clipboard Actions
                  SqaFloatingBarButton(
                    icon: Symbols.content_copy,
                    tooltip: 'Copy Markdown',
                    onPressed: () {
                      final md = documentToMarkdown(_editorState.document);
                      Clipboard.setData(ClipboardData(text: md));
                    },
                    secondaryActions: [
                      SqaFloatingSubAction(
                        icon: Symbols.text_snippet,
                        tooltip: 'Copy as Rich Text',
                        onPressed: () {
                          // Placeholder for Rich Text implementation
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

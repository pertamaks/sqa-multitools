import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_smart_text.dart';
import '../../../ui/widgets/sqa_toast.dart';
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

    // 3. Table Builder
    map[TableBlockKeys.type] = SqaTableBlockComponentBuilder(
      tableStyle: TableStyle(
        borderWidth: 1.0,
        borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        borderHoverColor: theme.colorScheme.primary.withValues(alpha: 0.5),
      ),
      menuBuilder: _buildTableMenu,
    );

    // Hide handles for all other blocks
    for (final entry in map.entries) {
      if (entry.key != HeadingBlockKeys.type && entry.key != ParagraphBlockKeys.type && entry.key != TableBlockKeys.type) {
        entry.value.showActions = (_) => false;
      }
    }

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
      style: MenuStyle(
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
      ),
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
          onTap: () => TableActions.add(node, position + 1, editorState, direction),
        ),
        const Divider(height: 8, thickness: 0.5),
        _buildTableMenuItem(
          icon: const Icon(Symbols.content_copy, size: 18),
          label: isRow ? 'Duplicate Row' : 'Duplicate Column',
          onTap: () => TableActions.duplicate(node, position, editorState, direction),
        ),
        _buildTableMenuItem(
          icon: const Icon(Symbols.backspace, size: 18),
          label: 'Clear Content',
          onTap: () => TableActions.clear(node, position, editorState, direction),
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
            _buildColorOption(context, 'None', null, node, position, editorState, direction),
            const Divider(height: 4),
            _buildColorOption(context, 'Light Grey', '#F5F5F5', node, position, editorState, direction),
            _buildColorOption(context, 'Sky Blue', '#E3F2FD', node, position, editorState, direction),
            _buildColorOption(context, 'Mint Green', '#E8F5E9', node, position, editorState, direction),
            _buildColorOption(context, 'Pale Yellow', '#FFFDE7', node, position, editorState, direction),
            _buildColorOption(context, 'Rose', '#FFEBEE', node, position, editorState, direction),
            _buildColorOption(context, 'Lavender', '#F3E5F5', node, position, editorState, direction),
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
          icon: Icon(
            Symbols.delete,
            size: 18,
            color: theme.colorScheme.error,
          ),
          label: isRow ? 'Delete Row' : 'Delete Column',
          color: theme.colorScheme.error,
          onTap: () => TableActions.delete(node, position, editorState, direction),
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
      onPressed: () => TableActions.setBgColor(node, position, editorState, hexColor, direction),
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
        data: IconThemeData(
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
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
    // Structural changes (like deleting a column) can leave the table in a 
    // transitional state for a micro-beat. We wait for the post-frame callback
    // to ensure the internal re-indexing is complete before encoding.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      
      try {
        final currentContent = ref.read(textEditorProvider).activeDocument?.content ?? '';
        final newContent = documentToMarkdown(_editorState.document);
        if (newContent != currentContent) {
          ref.read(textEditorProvider.notifier).updateContent(newContent);
        }
      } catch (e) {
        // Silently catch temporary encoding errors during structural transitions
        debugPrint('Text Editor: Encoding skipped due to transitional state: $e');
      }
    });
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

    // Sync title controller with state if not actively editing
    ref.listen(textEditorProvider.select((s) => s.activeDocument?.name), (prev, next) {
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
              shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
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
                    selectionColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    cursorColor: theme.colorScheme.primary,
                  ),
                  // 2. Theme Menus (Table Context Menus, etc.)
                  menuTheme: MenuThemeData(
                    style: MenuStyle(
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
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  // 4. Theme Icons (Handles/Buttons)
                  iconTheme: theme.iconTheme.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
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
                    ...tableCommands,
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
      message: isSaved ? 'All changes saved' : (isSaving ? 'Saving...' : 'Unsaved changes'),
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
                        transaction.insertNode(
                          selection.end.path,
                          table.node,
                        );
                        _editorState.apply(transaction);
                      }
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
      child: Theme(
        data: theme.copyWith(
          iconTheme: IconThemeData(
            color: theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
        ),
        child: widget,
      ),
    );
  }
}

/// A concrete wrapper for BlockComponentWidget that allows themed child wrapping.
class SqaBlockComponentWrapper extends BlockComponentStatelessWidget {
  final Widget child;

  const SqaBlockComponentWrapper({
    super.key,
    required super.node,
    required super.configuration,
    super.showActions = false,
    super.actionBuilder,
    super.actionTrailingBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => child;
}

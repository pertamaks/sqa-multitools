import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_md_text_controller.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../providers/md_editor_provider.dart';
import '../models/md_editor_state.dart';
import 'package:flutter/services.dart';

class MdEditorView extends ConsumerStatefulWidget {
  const MdEditorView({super.key});

  @override
  ConsumerState<MdEditorView> createState() => _MdEditorViewState();
}

class _MdEditorViewState extends ConsumerState<MdEditorView> {
  late TextEditingController _nameController;
  late SqaMdTextController _contentController;
  late UndoHistoryController _undoController;

  @override
  void initState() {
    super.initState();
    final doc = ref.read(mdEditorProvider).activeDocument;
    _nameController = TextEditingController(text: doc?.name ?? '');
    _contentController = SqaMdTextController(text: doc?.content ?? '');
    _undoController = UndoHistoryController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _undoController.dispose();
    super.dispose();
  }

  void _toggleStyle(String prefix, [String? suffix]) {
    final selection = _contentController.selection;
    if (!selection.isValid) return;

    final text = _contentController.text;
    final selectedText = selection.textInside(text);
    final s = suffix ?? prefix;

    final newText = text.replaceRange(selection.start, selection.end, '$prefix$selectedText$s');
    _contentController.value = _contentController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.start + prefix.length + selectedText.length + s.length,
      ),
    );
  }

  void _insertBlock(String content) {
    final selection = _contentController.selection;
    final text = _contentController.text;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final newText = text.replaceRange(start, end, content);
    _contentController.value = _contentController.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + content.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(mdEditorProvider);
    final notifier = ref.read(mdEditorProvider.notifier);

    return SqaPluginLayout(
      icon: Symbols.edit_note,
      title: 'Editor',
      description: 'Document Editor',
      onBack: () => notifier.setViewMode(MdEditorViewMode.list),
      useMask: false, // Disable global mask to keep toolbar opaque
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Symbols.close, size: 20),
            onPressed: () => notifier.setViewMode(MdEditorViewMode.list),
            tooltip: 'Discard changes',
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.outline,
              padding: const EdgeInsets.all(8),
              minimumSize: const Size(40, 40),
              shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
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
                    notifier.updateContent(_contentController.text);
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
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SqaFadeWrapper(
              child: SqaPluginScrollableContent(
                center: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    // Unified Modern Title
                    TextField(
                      controller: _nameController,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Document Title',
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.2),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onChanged: (val) {
                        setState(() {}); 
                      },
                    ),
                    const SizedBox(height: 16),
                    // Seamless Markdown Content
                    SqaField(
                      label: '', // Not shown
                      showLabel: false,
                      isTransparent: true,
                      controller: _contentController,
                      undoController: _undoController,
                      isMultiline: true,
                      minLines: 25,
                      isMonospace: false, // Standard text editor feel
                      showLineNumbers: false,
                      showCopyButton: false,
                      hintText: 'Start writing your story...',
                    ),
                    const SizedBox(height: 100), // Space for floating bar
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

  Widget _buildFloatingToolbar(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Center(
        child: ListenableBuilder(
          listenable: _undoController,
          builder: (context, _) {
            return SqaFloatingBar(
              children: [
                // Group 1: History
                SqaFloatingBarButton(
                  icon: Symbols.undo,
                  tooltip: 'Undo',
                  onPressed: _undoController.value.canUndo ? () => _undoController.undo() : null,
                ),
                SqaFloatingBarButton(
                  icon: Symbols.redo,
                  tooltip: 'Redo',
                  onPressed: _undoController.value.canRedo ? () => _undoController.redo() : null,
                ),
                const SqaFloatingBarDivider(),
                
                // Group 2: Typography
                SqaFloatingBarButton(
                  icon: Symbols.format_bold,
                  tooltip: 'Bold',
                  onPressed: () => _toggleStyle('**'),
                ),
                SqaFloatingBarButton(
                  icon: Symbols.format_italic,
                  tooltip: 'Italic',
                  onPressed: () => _toggleStyle('*'),
                ),
                SqaFloatingBarButton(
                  icon: Symbols.format_underlined,
                  tooltip: 'Underline',
                  onPressed: () => _toggleStyle('<u>', '</u>'),
                ),
                const SqaFloatingBarDivider(),

                // Group 3: Layout & Objects
                SqaFloatingBarButton(
                  icon: Symbols.table_chart,
                  tooltip: 'Table',
                  onPressed: () => _insertBlock('\n| Header | Header |\n| --- | --- |\n| Cell | Cell |\n'),
                ),
                SqaFloatingBarButton(
                  icon: Symbols.code,
                  tooltip: 'Code Block',
                  onPressed: () => _toggleStyle('\n```\n', '\n```\n'),
                ),
                SqaFloatingBarButton(
                  icon: Symbols.image,
                  tooltip: 'Image',
                  onPressed: () => _insertBlock('![alt text](url)'),
                ),
                const SqaFloatingBarDivider(),

                // Group 4: Hyperlink
                SqaFloatingBarButton(
                  icon: Symbols.link,
                  tooltip: 'Hyperlink',
                  onPressed: () => _toggleStyle('[', '](url)'),
                ),
                const SqaFloatingBarDivider(),

                // Group 5: Clipboard Actions (Final Position)
                SqaFloatingBarButton(
                  icon: Symbols.content_copy,
                  tooltip: 'Copy Markdown',
                  secondaryIcon: Symbols.text_snippet,
                  secondaryTooltip: 'Copy as Rich Text',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _contentController.text));
                  },
                  secondaryOnPressed: () {
                    // Placeholder for Rich Text implementation
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

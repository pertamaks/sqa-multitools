import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_text_controller.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_smart_text.dart';
import '../providers/text_editor_provider.dart';
import '../models/text_editor_state.dart';
import 'package:flutter/services.dart';

class TextEditorView extends ConsumerStatefulWidget {
  const TextEditorView({super.key});

  @override
  ConsumerState<TextEditorView> createState() => _TextEditorViewState();
}

class _TextEditorViewState extends ConsumerState<TextEditorView> {
  late TextEditingController _nameController;
  late SqaTextController _contentController;
  late UndoHistoryController _undoController;
  late FocusNode _titleFocusNode;
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    final doc = ref.read(textEditorProvider).activeDocument;
    _nameController = TextEditingController(text: doc?.name ?? '');
    _contentController = SqaTextController(text: doc?.content ?? '');
    _undoController = UndoHistoryController();
    _titleFocusNode = FocusNode();
    _titleFocusNode.addListener(_onTitleFocusChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    _undoController.dispose();
    _titleFocusNode.removeListener(_onTitleFocusChange);
    _titleFocusNode.dispose();
    super.dispose();
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
    return _nameController.text != doc.name ||
        _contentController.text != doc.content;
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
      child: Stack(
        children: [
          Positioned.fill(
            child: SqaFadeWrapper(
              child: SqaPluginScrollableContent(
                center: false,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      onTapOutside: (_) {
                        notifier.updateContent(_contentController.text);
                      },
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
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = (screenWidth - 160).clamp(0.0, 800.0);
    final leftOffset = (screenWidth - barWidth) / 2;

    return Positioned(
      bottom: 24,
      left: leftOffset,
      width: barWidth,
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
    );
  }
}

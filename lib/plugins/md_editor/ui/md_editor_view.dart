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

class MdEditorView extends ConsumerStatefulWidget {
  const MdEditorView({super.key});

  @override
  ConsumerState<MdEditorView> createState() => _MdEditorViewState();
}

class _MdEditorViewState extends ConsumerState<MdEditorView> {
  late TextEditingController _nameController;
  late SqaMdTextController _contentController;

  @override
  void initState() {
    super.initState();
    final doc = ref.read(mdEditorProvider).activeDocument;
    _nameController = TextEditingController(text: doc?.name ?? '');
    _contentController = SqaMdTextController(text: doc?.content ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
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
      left: 0,
      right: 0,
      child: Center(
        child: SqaFloatingBar(
          children: [
            SqaFloatingBarButton(
              icon: Symbols.format_bold,
              tooltip: 'Bold',
              onPressed: () {},
            ),
            SqaFloatingBarButton(
              icon: Symbols.format_italic,
              tooltip: 'Italic',
              onPressed: () {},
            ),
            SqaFloatingBarButton(
              icon: Symbols.format_list_bulleted,
              tooltip: 'List',
              onPressed: () {},
            ),
            const SqaFloatingBarDivider(),
            SqaFloatingBarButton(
              icon: Symbols.link,
              tooltip: 'Link',
              onPressed: () {},
            ),
            SqaFloatingBarButton(
              icon: Symbols.image,
              tooltip: 'Image',
              onPressed: () {},
            ),
            const SqaFloatingBarDivider(),
            SqaFloatingBarButton(
              icon: Symbols.content_copy,
              tooltip: 'Copy Markdown',
              secondaryIcon: Symbols.text_snippet,
              secondaryTooltip: 'Copy as Rich Text',
              onPressed: () {
                // TODO: Implement Raw MD Copy
              },
              secondaryOnPressed: () {
                // TODO: Implement Rich Text Copy
              },
            ),
          ],
        ),
      ),
    );
  }
}

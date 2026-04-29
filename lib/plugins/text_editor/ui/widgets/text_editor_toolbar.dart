import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_floating_bar.dart';
import '../../../../ui/widgets/sqa_toast.dart';
import '../../providers/text_editor_provider.dart';
import 'package:flutter/services.dart';
import 'package:file_selector/file_selector.dart';

import '../../../../ui/widgets/sqa_color_picker.dart';

class TextEditorToolbar extends ConsumerWidget {
  final EditorState editorState;
  final ValueNotifier<int> formattingNotifier;
  final VoidCallback onShowLinkMenu;
  final String Function() exportToMarkdown;
  final bool Function(String) isAttributeToggled;
  final bool isLinkMenuOpen;

  const TextEditorToolbar({
    super.key,
    required this.editorState,
    required this.formattingNotifier,
    required this.onShowLinkMenu,
    required this.exportToMarkdown,
    required this.isAttributeToggled,
    required this.isLinkMenuOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              editorState.selectionNotifier,
              formattingNotifier,
            ]),
            builder: (context, _) {
              return SqaFloatingBar(
                children: [
                  // Group 1: History
                  SqaFloatingBarButton(
                    icon: Symbols.undo,
                    tooltip: 'Undo',
                    onPressed: editorState.undoManager.undoStack.isNonEmpty
                        ? () => editorState.undoManager.undo()
                        : null,
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.redo,
                    tooltip: 'Redo',
                    onPressed: editorState.undoManager.redoStack.isNonEmpty
                        ? () => editorState.undoManager.redo()
                        : null,
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 2: Block Identity (Action-First)
                  SqaFloatingBarButton(
                    icon: Symbols.format_h1,
                    tooltip: 'Heading 1',
                    onPressed: () => editorState.formatNode(
                      editorState.selection,
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
                        onPressed: () => editorState.formatNode(
                          editorState.selection,
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
                        onPressed: () => editorState.formatNode(
                          editorState.selection,
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
                        onPressed: () => editorState.formatNode(
                          editorState.selection,
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
                    onPressed: () => editorState.formatNode(
                      editorState.selection,
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
                    isSelected: isAttributeToggled(AppFlowyRichTextKeys.bold),
                    onPressed: () =>
                        editorState.toggleAttribute(AppFlowyRichTextKeys.bold),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_italic,
                    tooltip: 'Italic',
                    isSelected: isAttributeToggled(AppFlowyRichTextKeys.italic),
                    onPressed: () =>
                        editorState.toggleAttribute(AppFlowyRichTextKeys.italic),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_underlined,
                    tooltip: 'Underline',
                    isSelected: isAttributeToggled(
                      AppFlowyRichTextKeys.underline,
                    ),
                    onPressed: () =>
                        editorState.toggleAttribute(AppFlowyRichTextKeys.underline),
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.format_strikethrough,
                    tooltip: 'Strikethrough',
                    isSelected: isAttributeToggled(
                      AppFlowyRichTextKeys.strikethrough,
                    ),
                    onPressed: () =>
                        editorState.toggleAttribute(AppFlowyRichTextKeys.strikethrough),
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 4: Colors
                  SqaColorPicker(
                    activeColor:
                        editorState
                                .getDeltaAttributesInSelectionStart()?[AppFlowyRichTextKeys
                                .textColor]
                            as String?,
                    onColorSelected: (String? hex) {
                      final selection = editorState.selection;
                      if (selection != null) {
                        editorState.formatDelta(selection, {
                          AppFlowyRichTextKeys.textColor: hex,
                        });
                      }
                    },
                    child: SqaFloatingBarButton(
                      icon: Symbols.format_color_text,
                      tooltip: 'Text Color',
                      isSelected: isAttributeToggled(
                        AppFlowyRichTextKeys.textColor,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  SqaColorPicker(
                    isBackground: true,
                    activeColor:
                        editorState
                                .getDeltaAttributesInSelectionStart()?[AppFlowyRichTextKeys
                                .backgroundColor]
                            as String?,
                    onColorSelected: (String? hex) {
                      final selection = editorState.selection;
                      if (selection != null) {
                        editorState.formatDelta(selection, {
                          AppFlowyRichTextKeys.backgroundColor: hex,
                        });
                      }
                    },
                    child: SqaFloatingBarButton(
                      icon: Symbols.format_color_fill,
                      tooltip: 'Highlight Color',
                      isSelected: isAttributeToggled(
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
                    onPressed: () => editorState.formatNode(
                      editorState.selection,
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
                        onPressed: () => editorState.formatNode(
                          editorState.selection,
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
                        onPressed: () => editorState.formatNode(
                          editorState.selection,
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
                        editorState.selection != null &&
                        editorState
                            .getNodesInSelection(editorState.selection!)
                            .any((n) => n.type == 'code'),
                    onPressed: () {
                      final selection = editorState.selection;
                      if (selection == null) return;

                      final nodes = editorState.getNodesInSelection(selection);
                      final isCodeBlock = nodes.any((n) => n.type == 'code');

                      if (isCodeBlock) {
                        editorState.formatNode(
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
                        editorState.formatNode(
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
                        onPressed: () => editorState.toggleAttribute(
                          AppFlowyRichTextKeys.code,
                        ),
                      ),
                    ],
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.link,
                    tooltip: 'Hyperlink',
                    isSelected:
                        isAttributeToggled(AppFlowyRichTextKeys.href) ||
                        isLinkMenuOpen,
                    onPressed: onShowLinkMenu,
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.table_chart,
                    tooltip: 'Insert Table',
                    onPressed: () {
                      final selection = editorState.selection;
                      if (selection != null) {
                        final transaction = editorState.transaction;
                        final table = TableNode.fromList([
                          ['', ''],
                          ['', ''],
                          ['', ''],
                        ]);
                        transaction.insertNode(selection.end.path, table.node);
                        editorState.apply(transaction);
                      }
                    },
                  ),
                  SqaFloatingBarButton(
                    icon: Symbols.image,
                    tooltip: 'Insert Image',
                    onPressed: () async {
                      final selection = editorState.selection;
                      if (selection == null) return;

                      final bool _isSelectionInTable = false; // TODO: implement isSelectionInTable
                      if (_isSelectionInTable) {
                        SqaToast.show(
                          context,
                          "Cannot insert image inside a table cell",
                          type: SqaToastType.error,
                        );
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
                        final storageNotifier = ref.read(
                          textEditorProvider.notifier,
                        );
                        final relativePath = await storageNotifier
                            .saveImageAttachment(file.path);

                        final transaction = editorState.transaction;
                        final imageNode = Node(
                          type: ImageBlockKeys.type,
                          attributes: {
                            ImageBlockKeys.url: relativePath,
                            'alt': file.name,
                          },
                        );
                        transaction.insertNode(selection.end.path, imageNode);
                        await editorState.apply(transaction);
                      }
                    },
                  ),
                  const SqaFloatingBarDivider(),

                  // Group 6: Clipboard Actions
                  SqaFloatingBarButton(
                    icon: Symbols.content_copy,
                    tooltip: 'Copy Markdown',
                    onPressed: () async {
                      final md = exportToMarkdown();
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

    
}

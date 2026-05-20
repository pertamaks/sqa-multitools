import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_popup_menu.dart';
import '../../../ui/widgets/sqa_toast.dart';
import '../../../ui/widgets/sqa_floating_bar.dart';

import '../../text_editor/ui/widgets/code_block_builder.dart';
import '../../text_editor/ui/widgets/table_block_builder.dart';
import '../../text_editor/ui/widgets/quote_block_builder.dart';
import '../../text_editor/ui/widgets/html_block_builder.dart';
import '../../text_editor/ui/widgets/image_block_builder.dart';
import '../../text_editor/ui/widgets/table_node_loader_parser.dart';
import '../../text_editor/ui/widgets/html_node_loader_parser.dart';
import '../../text_editor/ui/widgets/image_node_encoder_parser.dart';

import '../providers/obfuscator_provider.dart';
import '../models/obfuscator_state.dart';
import '../models/dictionary_entry.dart';
import '../models/obfuscator_workspace.dart';
import '../engine/substitution_engine.dart';
import '../engine/alias_generator.dart';

/// The AppFlowy-based document viewer for the Obfuscator plugin.
/// This is a direct clone of the Text Editor's viewer architecture,
/// adapted for read-only document display with future obfuscation highlighting.
class ObfuscatorDocumentView extends ConsumerStatefulWidget {
  const ObfuscatorDocumentView({super.key});

  @override
  ConsumerState<ObfuscatorDocumentView> createState() =>
      _ObfuscatorDocumentViewState();
}

class _ObfuscatorDocumentViewState
    extends ConsumerState<ObfuscatorDocumentView> {
  EditorState? _editorState;
  late EditorScrollController _editorScrollController;
  final ScrollController _scrollController = ScrollController();
  bool _isInitializing = true;
  Map<String, BlockComponentBuilder>? _cachedBuilders;
  Brightness? _cachedBrightness;

  @override
  void initState() {
    super.initState();
    forceShowBlockAction = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewer();
    });
  }

  Future<void> _initializeViewer() async {
    if (!mounted) return;

    final state = ref.read(obfuscatorProvider);
    final doc = state.activeDocument;
    var initialContent = doc?.content ?? '';

    if (state.showObfuscatedPreview) {
      initialContent = SubstitutionEngine.obfuscate(
        initialContent,
        state.dictionary,
      );
    }

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
      );
      if (document.root.children.isEmpty) {
        document.root.children.add(paragraphNode());
      }
    }

    if (!mounted) return;

    final double previousOffset = _scrollController.hasClients
        ? _scrollController.offset
        : 0.0;

    // Discard old editor controller to prevent memory leaks or stale state
    _editorState?.dispose();

    setState(() {
      _editorState = EditorState(document: document);
      _editorState!.editable = false; // Read-only mode

      _editorScrollController = EditorScrollController(
        editorState: _editorState!,
        shrinkWrap: true,
        scrollController: _scrollController,
      );

      _isInitializing = false;
    });

    if (previousOffset > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          final maxExtent = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(
            previousOffset > maxExtent ? maxExtent : previousOffset,
          );
        }
      });
    }
  }

  TextSpan _obfuscatorTextSpanDecorator(
    BuildContext context,
    Node node,
    int index,
    TextInsert text,
    TextSpan before,
    TextSpan after,
    List<DictionaryEntry> dictionary,
    bool showObfuscated,
  ) {
    final textStr = text.text;
    if (!showObfuscated || textStr.isEmpty || dictionary.isEmpty) return before;

    final activeEntries = dictionary.where((e) => e.enabled).toList();
    if (activeEntries.isEmpty) return before;

    final Map<String, DictionaryEntry> replacementToEntry = {};
    for (final entry in activeEntries) {
      replacementToEntry[entry.replacement.toLowerCase()] = entry;
      for (final v in entry.variants.values) {
        replacementToEntry[v.toLowerCase()] = entry;
      }
    }

    final replacements = replacementToEntry.keys.toList();
    if (replacements.isEmpty) return before;

    replacements.sort((a, b) => b.length.compareTo(a.length));
    final escapedReplacements = replacements.map(RegExp.escape).join('|');
    final regex = RegExp('\\b($escapedReplacements)\\b', caseSensitive: false);

    final matches = regex.allMatches(textStr).toList();
    if (matches.isEmpty) return before;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final highlightBg = isDark
        ? const Color(0xFF00ADB5).withValues(alpha: 0.35)
        : const Color(0xFFFFB300).withValues(alpha: 0.28);

    final List<InlineSpan> children = [];
    var lastIdx = 0;

    for (final match in matches) {
      if (match.start > lastIdx) {
        children.add(
          TextSpan(
            text: textStr.substring(lastIdx, match.start),
            style: before.style,
          ),
        );
      }

      final matchedText = match.group(0)!;
      children.add(
        TextSpan(
          text: matchedText,
          style:
              before.style?.copyWith(backgroundColor: highlightBg) ??
              TextStyle(backgroundColor: highlightBg),
        ),
      );

      lastIdx = match.end;
    }

    if (lastIdx < textStr.length) {
      children.add(
        TextSpan(text: textStr.substring(lastIdx), style: before.style),
      );
    }

    return TextSpan(style: before.style, children: children);
  }

  Map<String, BlockComponentBuilder> _buildBlockComponentBuilders() {
    final theme = Theme.of(context);
    final map = <String, BlockComponentBuilder>{
      ...standardBlockComponentBuilderMap,
    };

    // 1. Standard Paragraph Builder
    map[ParagraphBlockKeys.type] = ParagraphBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
    )..showActions = (_) => false;

    // 2. Standard Heading Builder
    map[HeadingBlockKeys.type] = HeadingBlockComponentBuilder(
      configuration: BlockComponentConfiguration(
        padding: (node) => EdgeInsets.zero,
      ),
      textStyleBuilder: (level) {
        final fontSizes = [
          SqaTokens.fontSizeXXLarge,
          SqaTokens.fontSizeXLarge,
          SqaTokens.fontSizeLarge,
          SqaTokens.spacingLarge,
          SqaTokens.fontSizeSmall + 2,
          SqaTokens.fontSizeSmall + 2,
        ];
        return GoogleFonts.inter(
          fontSize: fontSizes[level - 1],
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );
      },
    )..showActions = (_) => false;

    // 3. Table Builders (read-only — no menu builder needed)
    map[TableBlockKeys.type] = SqaTableBlockComponentBuilder(
      tableStyle: TableStyle(
        borderWidth: 1.0,
        borderColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        borderHoverColor: theme.colorScheme.primary.withValues(alpha: 0.5),
        addIcon: Icon(
          Symbols.add,
          size: SqaTokens.spacingLarge + SqaTokens.spacingTiny,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
    map[TableCellBlockKeys.type] = SqaTableCellBlockComponentBuilder();

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

    // Hide handles for all blocks (read-only mode)
    for (final entry in map.entries) {
      entry.value.showActions = (_) => false;
    }

    // 6. SQA HTML Safety Net Builder
    map['raw_html'] = RawHtmlBlockComponentBuilder();

    // 7. Custom Image Builder
    map[ImageBlockKeys.type] = SqaImageBlockComponentBuilder();

    return map;
  }

  @override
  void dispose() {
    _editorState?.dispose();
    if (!_isInitializing) {
      _editorScrollController.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Invalidate cached block builders ONLY if the theme brightness (dark vs light mode)
    // actually changes, preventing layout thrashing during text selection or focus shifts.
    if (_cachedBrightness != theme.brightness) {
      _cachedBrightness = theme.brightness;
      _cachedBuilders = null;
    }

    final state = ref.watch(obfuscatorProvider);
    final notifier = ref.read(obfuscatorProvider.notifier);

    // Watch showObfuscatedPreview, strategy, and dictionary changes to reinitialize the editor when they update!
    ref.listen<ObfuscatorState>(obfuscatorProvider, (previous, next) {
      final previewToggled =
          previous?.showObfuscatedPreview != next.showObfuscatedPreview;
      final strategyChanged =
          previous?.activeWorkspace?.strategy != next.activeWorkspace?.strategy;
      final dictChanged =
          next.showObfuscatedPreview &&
          (previous?.dictionary != next.dictionary);

      if (previewToggled || strategyChanged || dictChanged) {
        _initializeViewer();
      }
    });

    if (_isInitializing || _editorState == null) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = (screenWidth - (SqaTokens.spacingXXXLarge * 3)).clamp(
      0.0,
      500.0,
    );

    return SqaPluginLayout(
      title: state.activeDocument?.fileName ?? 'Document',
      onBack: () => notifier.setViewMode(ObfuscatorViewMode.list),
      child: Stack(
        children: [
          Positioned.fill(
            child: SqaFadeWrapper(
              child: Theme(
                data: theme.copyWith(
                  textSelectionTheme: TextSelectionThemeData(
                    selectionHandleColor: theme.colorScheme.primary,
                    selectionColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    cursorColor: theme.colorScheme.primary,
                  ),
                  menuTheme: MenuThemeData(
                    style: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(
                        theme.colorScheme.surface,
                      ),
                      surfaceTintColor: WidgetStateProperty.all(
                        Colors.transparent,
                      ),
                      elevation: WidgetStateProperty.all(8.0),
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.all(SqaTokens.spacingXSmall),
                      ),
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
                  iconTheme: theme.iconTheme.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                child: Focus(
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    // Permit standard navigation and copy/select-all shortcuts (Ctrl/Cmd based)
                    final isControlPressed =
                        HardwareKeyboard.instance.isControlPressed ||
                        HardwareKeyboard.instance.isMetaPressed;
                    if (isControlPressed) {
                      return KeyEventResult.ignored;
                    }
                    // Intercept and swallow all typing/editing key events to block IME activation
                    // and prevent standard write transactions on a read-only document.
                    return KeyEventResult.handled;
                  },
                  child: AppFlowyEditor(
                    key: ValueKey(_editorState.hashCode),
                    editorState: _editorState!,
                    editable: false,
                    autoFocus: false,
                    blockComponentBuilders: _cachedBuilders ??=
                        _buildBlockComponentBuilders(),
                    commandShortcutEvents:
                        const [], // No shortcuts in read-only
                    editorScrollController: _editorScrollController,
                    shrinkWrap: true,
                    footer: const SizedBox(
                      height: SqaTokens.scrollClearanceBottom,
                    ),
                    contextMenuBuilder:
                        (context, anchorOffset, editorState, closeMenu) {
                          return _buildContextMenu(
                            context,
                            anchorOffset,
                            editorState,
                            closeMenu,
                            state,
                            notifier,
                            theme,
                          );
                        },
                    editorStyle: EditorStyle.desktop(
                      padding: const EdgeInsets.symmetric(
                        horizontal:
                            SqaTokens.spacingXXLarge + SqaTokens.spacingLarge,
                        vertical: SqaTokens.spacingMedium,
                      ),
                      maxWidth: 800.0,
                      textScaleFactor: 14.0 / 16.0,
                      cursorColor: theme.colorScheme.primary,
                      selectionColor: theme.colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
                      textSpanDecorator:
                          (context, node, index, text, before, after) {
                            return _obfuscatorTextSpanDecorator(
                              context,
                              node,
                              index,
                              text,
                              before,
                              after,
                              state.dictionary,
                              state.showObfuscatedPreview,
                            );
                          },
                      textStyleConfiguration: TextStyleConfiguration(
                        text: GoogleFonts.inter(
                          fontSize: 16.0,
                          height: 1.5,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: SqaTokens.spacingXLarge,
            left: 0,
            right: 0,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: barWidth),
                child: SqaFloatingBar(
                  children: [
                    Tooltip(
                      message: 'Obfuscate Document',
                      child: SqaSwitch(
                        value: state.showObfuscatedPreview,
                        onChanged: (_) => notifier.toggleObfuscatedPreview(),
                      ),
                    ),
                    const SqaFloatingBarDivider(),
                    SqaPopupMenu(
                      icon: Symbols.settings_suggest,
                      tooltip: 'Obfuscation Strategy',
                      alignmentOffset: const Offset(0, SqaTokens.spacingSmall),
                      builder: (context, controller, child) {
                        return InkWell(
                          onTap: () {
                            if (controller.isOpen) {
                              controller.close();
                            } else {
                              controller.open();
                            }
                          },
                          borderRadius: SqaTokens.borderRadiusSmall,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SqaTokens.spacingXSmall,
                              vertical: SqaTokens.spacingXXSmall,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  state.activeWorkspace?.strategy ==
                                          SubstitutionStrategy.token
                                      ? Symbols.tag
                                      : state.activeWorkspace?.strategy ==
                                            SubstitutionStrategy.codename
                                      ? Symbols.shield
                                      : Symbols.translate,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  state.activeWorkspace?.strategy.name
                                          .toUpperCase() ??
                                      'SEMANTIC',
                                  style: GoogleFonts.dmSans(
                                    fontSize: SqaTokens.fontSizeSmall - 1,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Symbols.arrow_drop_down,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      children: [
                        ...SubstitutionStrategy.values.map((strategy) {
                          final isSelected =
                              state.activeWorkspace?.strategy == strategy;
                          IconData icon;
                          switch (strategy) {
                            case SubstitutionStrategy.token:
                              icon = Symbols.tag;
                              break;
                            case SubstitutionStrategy.codename:
                              icon = Symbols.shield;
                              break;
                            case SubstitutionStrategy.semantic:
                              icon = Symbols.translate;
                              break;
                          }
                          return SqaPopupMenuItem(
                            onPressed: () =>
                                notifier.updateWorkspaceStrategy(strategy),
                            icon: Icon(
                              icon,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                            label:
                                strategy.name.substring(0, 1).toUpperCase() +
                                strategy.name.substring(1),
                          );
                        }),
                      ],
                    ),
                    const SqaFloatingBarDivider(),
                    SqaHoverIconButton(
                      icon: Symbols.document_scanner,
                      onPressed: () async {
                        final newEntriesCount = await notifier
                            .scanAndPopulateDictionary();
                        if (!context.mounted) return;
                        if (newEntriesCount > 0) {
                          SqaToast.show(
                            context,
                            'Scan complete: Added $newEntriesCount new technical terms to the dictionary!',
                            type: SqaToastType.success,
                          );
                        } else {
                          SqaToast.show(
                            context,
                            'Scan complete: No new terms discovered in this document.',
                            type: SqaToastType.info,
                          );
                        }
                      },
                      tooltip: 'Scan Document for Technical Terms',
                      iconSize: 18,
                    ),
                    const SqaFloatingBarDivider(),
                    SqaHoverIconButton(
                      icon: Symbols.content_copy,
                      onPressed: () async {
                        final originalContent =
                            state.activeDocument?.content ?? '';
                        final contentToCopy = state.showObfuscatedPreview
                            ? SubstitutionEngine.obfuscate(
                                originalContent,
                                state.dictionary,
                              )
                            : originalContent;

                        await notifier.copyContent(contentToCopy);

                        if (!context.mounted) return;
                        SqaToast.show(
                          context,
                          'Content copied to clipboard',
                          type: SqaToastType.success,
                        );
                      },
                      tooltip: 'Copy Content',
                      iconSize: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextMenu(
    BuildContext context,
    Offset anchorOffset,
    EditorState editorState,
    void Function() closeMenu,
    ObfuscatorState state,
    Obfuscator notifier,
    ThemeData theme,
  ) {
    final selection = editorState.selection;
    if (selection == null || selection.isCollapsed) {
      return const SizedBox.shrink();
    }

    final selectedTextList = editorState.getTextInSelection(selection);
    final selectedText = selectedTextList.join('\n').trim();
    if (selectedText.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if the selected term is already in the dictionary
    final matchingEntry = state.dictionary.where((entry) {
      final term = entry.original.toLowerCase();
      final repl = entry.replacement.toLowerCase();
      final val = selectedText.toLowerCase();
      return term == val ||
          repl == val ||
          entry.variants.values.any((v) => v.toLowerCase() == val);
    }).firstOrNull;

    return Positioned(
      left: anchorOffset.dx,
      top: anchorOffset.dy,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: SqaStyles.radiusLarge,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(SqaTokens.spacingXSmall),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Selection info label
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SqaTokens.spacingSmall,
                    vertical: SqaTokens.spacingXXSmall + 2,
                  ),
                  child: Text(
                    'Selection: "${selectedText.length > 20 ? '${selectedText.substring(0, 18)}...' : selectedText}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                if (matchingEntry == null) ...[
                  // Case 1: Term is not in dictionary yet
                  MenuItemButton(
                    onPressed: () async {
                      closeMenu();

                      // Infer category
                      EntryCategory category = EntryCategory.general;
                      final trimText = selectedText.trim();
                      if (RegExp(r'^[A-Z]{3,6}$').hasMatch(trimText)) {
                        category = EntryCategory.config;
                      } else if (trimText.startsWith('/') &&
                          trimText.contains('/', 1)) {
                        category = EntryCategory.endpoint;
                      } else if (RegExp(
                        r'(Service|Repository|Controller|Notifier|Manager|Processor)$',
                      ).hasMatch(trimText)) {
                        category = EntryCategory.service;
                      } else if (RegExp(
                            r'(Model|Entity|Dto|View|Page|Table)$',
                          ).hasMatch(trimText) ||
                          trimText.endsWith('_id')) {
                        category = EntryCategory.model;
                      }

                      // Generate alias
                      final idx =
                          state.dictionary
                              .where((e) => e.category == category)
                              .length +
                          1;
                      final strategy =
                          state.activeWorkspace?.strategy ??
                          SubstitutionStrategy.semantic;
                      final replacement = AliasGenerator.generate(
                        original: trimText,
                        category: category,
                        strategy: strategy,
                        index: idx,
                      );

                      await notifier.addDictionaryEntry(
                        original: trimText,
                        replacement: replacement,
                        category: category,
                      );

                      if (context.mounted) {
                        SqaToast.show(
                          context,
                          'Obfuscated "$selectedText" as "$replacement"',
                          type: SqaToastType.success,
                        );
                      }
                    },
                    style: MenuItemButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SqaTokens.spacingMedium,
                        vertical: 0,
                      ),
                      minimumSize: const Size(
                        120,
                        SqaTokens.spacingXXLarge + SqaTokens.spacingSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: SqaTokens.borderRadiusMedium,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.shield_lock,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: SqaTokens.spacingSmall),
                        Text(
                          'Obfuscate Term',
                          style: SqaTextStyles.labelBold(context).copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: SqaTokens.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Case 2 & 3: Term is in dictionary (enabled or disabled)
                  MenuItemButton(
                    onPressed: () async {
                      closeMenu();
                      await notifier.toggleDictionaryEntry(matchingEntry.id);
                      if (context.mounted) {
                        SqaToast.show(
                          context,
                          matchingEntry.enabled
                              ? 'Disabled obfuscation for "$selectedText"'
                              : 'Enabled obfuscation for "$selectedText"',
                          type: matchingEntry.enabled
                              ? SqaToastType.info
                              : SqaToastType.success,
                        );
                      }
                    },
                    style: MenuItemButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SqaTokens.spacingMedium,
                        vertical: 0,
                      ),
                      minimumSize: const Size(
                        120,
                        SqaTokens.spacingXXLarge + SqaTokens.spacingSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: SqaTokens.borderRadiusMedium,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          matchingEntry.enabled
                              ? Symbols.visibility_off
                              : Symbols.shield_lock,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: SqaTokens.spacingSmall),
                        Text(
                          matchingEntry.enabled
                              ? 'Disable Obfuscation'
                              : 'Enable Obfuscation',
                          style: SqaTextStyles.labelBold(context).copyWith(
                            color: theme.colorScheme.onSurface,
                            fontSize: SqaTokens.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MenuItemButton(
                    onPressed: () async {
                      closeMenu();
                      await notifier.deleteDictionaryEntry(matchingEntry.id);
                      if (context.mounted) {
                        SqaToast.show(
                          context,
                          'Removed "$selectedText" from dictionary',
                          type: SqaToastType.info,
                        );
                      }
                    },
                    style: MenuItemButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SqaTokens.spacingMedium,
                        vertical: 0,
                      ),
                      minimumSize: const Size(
                        120,
                        SqaTokens.spacingXXLarge + SqaTokens.spacingSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: SqaTokens.borderRadiusMedium,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.delete,
                          size: 16,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(width: SqaTokens.spacingSmall),
                        Text(
                          'Remove Obfuscation',
                          style: SqaTextStyles.labelBold(context).copyWith(
                            color: theme.colorScheme.error,
                            fontSize: SqaTokens.fontSizeTiny,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Action 2: Copy Selection
                MenuItemButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: selectedText));
                    if (context.mounted) {
                      SqaToast.show(
                        context,
                        'Copied to clipboard',
                        type: SqaToastType.success,
                      );
                    }
                    closeMenu();
                  },
                  style: MenuItemButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SqaTokens.spacingMedium,
                      vertical: 0,
                    ),
                    minimumSize: const Size(
                      120,
                      SqaTokens.spacingXXLarge + SqaTokens.spacingSmall,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: SqaTokens.borderRadiusMedium,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.content_copy,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: SqaTokens.spacingSmall),
                      Text(
                        'Copy text',
                        style: SqaTextStyles.labelBold(context).copyWith(
                          color: theme.colorScheme.onSurface,
                          fontSize: SqaTokens.fontSizeTiny,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

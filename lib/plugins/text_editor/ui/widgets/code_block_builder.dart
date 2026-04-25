import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import '../../../../ui/widgets/sqa_styles.dart';

/// A custom SQA-standard Code Block builder.
class SqaCodeBlockComponentBuilder extends BlockComponentBuilder {
  SqaCodeBlockComponentBuilder({super.configuration});

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return SqaCodeBlockComponentWidget(
      node: node,
      key: node.key,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) =>
          actionBuilder(blockComponentContext, state),
    );
  }

  @override
  BlockComponentValidate get validate =>
      (node) => node.delta != null;
}

class SqaCodeBlockComponentWidget extends BlockComponentStatefulWidget {
  const SqaCodeBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<SqaCodeBlockComponentWidget> createState() =>
      _SqaCodeBlockComponentWidgetState();
}

class _SqaCodeBlockComponentWidgetState
    extends State<SqaCodeBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectableMixin,
        BlockComponentConfigurable,
        BlockComponentBackgroundColorMixin,
        NestedBlockComponentStatefulWidgetMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'sqa_code_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey = GlobalKey(
    debugLabel: 'code',
  );

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  bool _isHovered = false;

  @override
  Widget buildComponent(
    BuildContext context, {
    bool withBackgroundColor = true,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final String language =
        node.attributes['language']?.toString() ?? 'plaintext';
    final code = node.delta?.toPlainText() ?? '';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        key: blockComponentKey,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
          borderRadius: SqaStyles.radiusMedium,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Language & Copy
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.2,
                    ),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    language.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const Spacer(),
                  if (_isHovered)
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Code copied to clipboard'),
                          ),
                        );
                      },
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
            ),

            // Code Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: AppFlowyRichText(
                key: forwardKey,
                delegate: this,
                node: node,
                editorState: editorState,
                placeholderText: 'Type code here...',
                textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
                  GoogleFonts.firaCode(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
                cursorColor: theme.colorScheme.primary,
                selectionColor: theme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A custom Markdown parser that detects fenced code blocks even when nested in lists.
class SqaMarkdownCodeBlockParser extends CustomMarkdownParser {
  const SqaMarkdownCodeBlockParser();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    // 1. Handle standard 'pre' blocks
    if (element is md.Element && element.tag == 'pre') {
      return _parsePreElement(element, listType);
    }

    // 2. Intercept 'li' tags that contain code blocks (including deeply nested in paragraphs)
    if (element is md.Element &&
        element.tag == 'li' &&
        listType != MarkdownListType.unknown) {
      final children = element.children;
      if (children != null && _hasDeepPre(children)) {
        final results = <Node>[];
        final textNodes = <md.Node>[];

        for (final child in children) {
          final nestedPre = _findPre(child);
          if (nestedPre != null) {
            // First, flush any accumulated text nodes as a list item
            if (textNodes.isNotEmpty) {
              results.add(
                _createListItemNode(textNodes, listType, startNumber),
              );
              textNodes.clear();
            }
            // Then, add the code block
            results.addAll(_parsePreElement(nestedPre, listType));
          } else {
            textNodes.add(child);
          }
        }

        // Flush remaining text
        if (textNodes.isNotEmpty) {
          results.add(_createListItemNode(textNodes, listType, startNumber));
        }

        return results;
      }
    }

    return [];
  }

  bool _hasDeepPre(List<md.Node> nodes) {
    return nodes.any((n) => _findPre(n) != null);
  }

  md.Element? _findPre(md.Node node) {
    if (node is! md.Element) return null;
    if (node.tag == 'pre') return node;

    // Check inside paragraphs (loose lists)
    if (node.tag == 'p' && node.children != null) {
      for (final child in node.children!) {
        final result = _findPre(child);
        if (result != null) return result;
      }
    }
    return null;
  }

  Node _createListItemNode(
    List<md.Node> mdNodes,
    MarkdownListType listType,
    int? number, {
    List<Node>? children,
  }) {
    final delta = DeltaMarkdownDecoder().convertNodes(mdNodes);
    final String type = (listType == MarkdownListType.ordered)
        ? 'numbered_list'
        : 'bulleted_list';

    return Node(
      type: type,
      attributes: {
        'delta': delta.toJson(),
        if (number != null) 'number': number,
      },
      children: children ?? [],
    );
  }

  List<Node> _parsePreElement(md.Element pre, MarkdownListType listType) {
    final children = pre.children;
    if (children == null || children.isEmpty || children.first is! md.Element) {
      return [];
    }

    final codeElement = children.first as md.Element;
    if (codeElement.tag != 'code') {
      return [];
    }

    String? language;
    if (codeElement.attributes.containsKey('class')) {
      final className = codeElement.attributes['class']!;
      if (className.startsWith('language-')) {
        language = className.substring('language-'.length);
      }
    }

    // Determine indentation
    final int indent = (listType != MarkdownListType.unknown) ? 1 : 0;

    return [
      Node(
        type: 'code',
        attributes: {
          'delta': (Delta()..insert(codeElement.textContent.trimRight()))
              .toJson(),
          'language': language ?? 'plaintext',
          if (indent > 0) 'indent': indent,
        },
      ),
    ];
  }
}

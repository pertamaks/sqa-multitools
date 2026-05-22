import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:html/parser.dart' as html;
import 'package:html/dom.dart' as dom;
import 'sqa_markdown_table.dart';
import 'sqa_grid_table.dart';
import 'sqa_field.dart';
import 'sqa_scroll_behavior.dart';

/// A high-fidelity Markdown viewer that uses a custom AST visitor to render
/// premium SQA-style widgets with support for deep linking.
class SqaMarkdownViewer extends StatefulWidget {
  final String markdown;
  final EdgeInsets padding;
  final bool useScrollable;
  final bool selectable;

  const SqaMarkdownViewer({
    super.key,
    required this.markdown,
    this.padding = const EdgeInsets.all(SqaTokens.spacingLarge),
    this.useScrollable = true,
    this.selectable = false,
  });

  @override
  State<SqaMarkdownViewer> createState() => _SqaMarkdownViewerState();
}

class _SqaMarkdownViewerState extends State<SqaMarkdownViewer> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _anchorKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToAnchor(String anchorId) {
    if (anchorId == 'top-of-page' || anchorId == 'top') {
      _scrollController.animateTo(
        0,
        duration: SqaTokens.durationSlow,
        curve: Curves.easeInOut,
      );
      return;
    }
    final key = _anchorKeys[anchorId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: SqaTokens.durationSlow,
        alignment: 0.1, // Align near the top
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't clear keys, just update/reuse them to ensure persistence for Click actions

    // Normalize line endings and parse Markdown to AST
    final normalizedMarkdown = widget.markdown.replaceAll('\r\n', '\n');
    final document = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
      encodeHtml: false,
    );
    final nodes = document.parseLines(normalizedMarkdown.split('\n'));

    // Convert AST to Widgets
    final visitor = SqaMarkdownVisitor(
      context: context,
      anchorKeys: _anchorKeys,
      onAnchorTap: _scrollToAnchor,
    );
    for (final node in nodes) {
      node.accept(visitor);
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: visitor.widgets,
    );

    if (!widget.useScrollable) {
      return Padding(padding: widget.padding, child: content);
    }

    return ScrollConfiguration(
      behavior: SqaMouseDragScrollBehavior(),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: widget.padding,
          child: content,
        ),
      ),
    );
  }
}

class SqaMarkdownVisitor implements md.NodeVisitor {
  final BuildContext context;
  final Map<String, GlobalKey> anchorKeys;
  final void Function(String) onAnchorTap;
  final List<Widget> widgets = [];
  final List<String> _tagStack = [];
  final Set<String> _usedIds = {};

  SqaMarkdownVisitor({
    required this.context,
    required this.anchorKeys,
    required this.onAnchorTap,
  });

  String _ensureUniqueId(String baseId) {
    String id = baseId;
    int counter = 1;
    while (_usedIds.contains(id)) {
      id = '$baseId-$counter';
      counter++;
    }
    _usedIds.add(id);
    return id;
  }

  @override
  bool visitElementBefore(md.Element element) {
    // Register ID if present for any element (crucial for footnotes and custom anchors)
    final id = element.attributes['id'];
    if (id != null) {
      final uniqueId = _ensureUniqueId(id);
      anchorKeys.putIfAbsent(uniqueId, () => GlobalKey());
    }

    _tagStack.add(element.tag);

    switch (element.tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        _addHeader(element);
        return false;
      case 'p':
        _addParagraph(element);
        return false;
      case 'ul':
      case 'ol':
        _addList(element);
        return false;
      case 'pre':
        _addCodeBlock(element);
        return false;
      case 'table':
        _addTable(element);
        return false;
      case 'hr':
        widgets.add(const Divider(height: SqaTokens.spacingXXLarge));
        return false;
      case 'blockquote':
        _addBlockquote(element);
        return false;
      case 'section':
        if (element.attributes['class'] == 'footnotes') {
          _addFootnoteSection(element);
          return false;
        }
        break;
    }

    return true;
  }

  @override
  void visitElementAfter(md.Element element) {
    _tagStack.removeLast();
  }

  @override
  void visitText(md.Text text) {
    final content = text.text.trim();
    if (content.isEmpty) return;

    if (content.startsWith('<table') && content.endsWith('</table>')) {
      _addRawHtmlTable(content);
      return;
    }

    if (_tagStack.isEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: _renderNodesAsRichText([text]),
        ),
      );
    }
  }

  Widget _wrapWithAnchor(String? id, Widget child) {
    if (id == null) return child;
    final key = anchorKeys.putIfAbsent(id, () => GlobalKey());
    return KeyedSubtree(key: key, child: child);
  }

  Widget _renderNodesAsRichText(List<md.Node>? nodes, {TextStyle? baseStyle}) {
    if (nodes == null || nodes.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final visitor = SqaInlineSpanVisitor(
      context: context,
      baseStyle: baseStyle,
      onAnchorTap: onAnchorTap,
      anchorKeys: anchorKeys,
      idGenerator: _ensureUniqueId,
    );
    for (final node in nodes) {
      node.accept(visitor);
    }

    return RichText(
      text: TextSpan(
        style: baseStyle ?? theme.textTheme.bodyMedium,
        children: visitor.spans,
      ),
    );
  }

  // --- Handlers ---

  void _addFootnoteSection(md.Element element) {
    final theme = Theme.of(context);
    widgets.add(const Divider(height: SqaTokens.spacingXXLarge + SqaTokens.spacingLarge, thickness: 1));
    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: SqaTokens.spacingSmall + 4),
        child: Text(
          'FOOTNOTES',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );

    // Visit children (the <ol> containing the footnotes)
    final subVisitor = SqaMarkdownVisitor(
      context: context,
      anchorKeys: anchorKeys,
      onAnchorTap: onAnchorTap,
    );
    // Use a smaller base style for footnotes
    final footnoteStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: SqaTokens.fontSizeSmall,
      color: theme.colorScheme.onSurfaceVariant,
    );

    for (final child in element.children ?? []) {
      if (child is md.Element && (child.tag == 'ol' || child.tag == 'ul')) {
        _addList(child, baseStyle: footnoteStyle);
      } else {
        child.accept(subVisitor);
      }
    }
    widgets.addAll(subVisitor.widgets);
  }

  void _addHeader(md.Element element) {
    final theme = Theme.of(context);
    final level = int.tryParse(element.tag.substring(1)) ?? 1;
    final text = element.textContent;

    // Generate anchor ID for deep linking (strip HTML tags first)
    final cleanText = text.replaceAll(RegExp(r'<[^>]*>'), '');
    final baseAnchorId = cleanText
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    final anchorId = _ensureUniqueId(baseAnchorId);
    final key = anchorKeys.putIfAbsent(anchorId, () => GlobalKey());

    TextStyle? style;
    double topPadding = SqaTokens.spacingLarge;
    double bottomPadding = SqaTokens.spacingSmall;

    if (level == 1) {
      style = theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.bold,
      );
      topPadding = 0;
    } else if (level == 2) {
      style = theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      );
    } else {
      style = theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold);
      topPadding = SqaTokens.spacingMedium;
    }

    widgets.add(
      _wrapWithAnchor(
        element.attributes['id'],
        Padding(
          key: key,
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _renderNodesAsRichText(element.children, baseStyle: style),
              if (level <= 2) ...[
                const SizedBox(height: SqaTokens.spacingTiny),
                Container(
                  width: level == 1 ? (SqaTokens.spacingXXLarge + SqaTokens.spacingMedium) : SqaTokens.spacingXXLarge,
                  height: SqaTokens.borderWidthThick,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    borderRadius: SqaTokens.borderRadiusSmall,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _addParagraph(md.Element element) {
    widgets.add(
      _wrapWithAnchor(
        element.attributes['id'],
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: _renderNodesAsRichText(element.children),
        ),
      ),
    );
  }

  void _addCodeBlock(md.Element element) {
    String? lang;
    md.Element? codeElement;
    try {
      codeElement =
          element.children?.firstWhere(
                (c) => c is md.Element && c.tag == 'code',
              )
              as md.Element?;
    } catch (_) {
      codeElement = null;
    }
    if (codeElement != null) {
      final className = codeElement.attributes['class'] ?? '';
      if (className.startsWith('language-')) {
        lang = className.substring(9);
      }
    }

    // Clean code text: remove leading/trailing empty lines but preserve indentation of text lines
    final lines = element.textContent.split(RegExp(r'\r?\n'));
    while (lines.isNotEmpty && lines.first.trim().isEmpty) {
      lines.removeAt(0);
    }
    while (lines.isNotEmpty && lines.last.trim().isEmpty) {
      lines.removeLast();
    }
    final cleanedCode = lines.join('\n');

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
        child: SqaField(
          label: lang?.toUpperCase() ?? 'CODE',
          initialValue: cleanedCode,
          isMultiline: true,
          readOnly: true,
          showCopyButton: true,
          wrap: false,
          isMonospace: true,
          showLabel: lang != null,
          isTransparent: false,
          fontSize: SqaTokens.fontSizeSmall,
        ),
      ),
    );
  }

  void _addList(md.Element element, {TextStyle? baseStyle}) {
    final isOrdered = element.tag == 'ol';
    final items =
        element.children
            ?.whereType<md.Element>()
            .where((e) => e.tag == 'li')
            .toList() ??
        [];

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final itemId = item.attributes['id'];
      bool hasBlockElements =
          item.children?.any(
            (c) =>
                c is md.Element &&
                (c.tag == 'pre' ||
                    c.tag == 'ul' ||
                    c.tag == 'ol' ||
                    c.tag == 'blockquote' ||
                    c.tag == 'table'),
          ) ??
          false;

      widgets.add(
        _wrapWithAnchor(
          itemId,
          Padding(
            padding: const EdgeInsets.only(bottom: SqaTokens.spacingSmall, left: SqaTokens.spacingSmall),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: SqaTokens.spacingMedium,
                  child: Text(
                    isOrdered ? '${i + 1}.' : '•',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: baseStyle?.fontSize,
                    ),
                  ),
                ),
                Expanded(
                  child: hasBlockElements
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _renderListItemContent(item),
                        )
                      : _renderNodesAsRichText(
                          item.children,
                          baseStyle: baseStyle,
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    widgets.add(const SizedBox(height: SqaTokens.spacingSmall));
  }

  List<Widget> _renderListItemContent(md.Element item) {
    final subVisitor = SqaMarkdownVisitor(
      context: context,
      anchorKeys: anchorKeys,
      onAnchorTap: onAnchorTap,
    );
    for (final child in item.children ?? []) {
      child.accept(subVisitor);
    }
    return subVisitor.widgets;
  }

  void _addTable(md.Element element) {
    final theme = Theme.of(context);

    // Use safe lookup to avoid cast errors
    final thead = element.children
        ?.whereType<md.Element>()
        .where((e) => e.tag == 'thead')
        .firstOrNull;
    final tbody = element.children
        ?.whereType<md.Element>()
        .where((e) => e.tag == 'tbody')
        .firstOrNull;

    final cellStyle = theme.textTheme.bodySmall?.copyWith(fontSize: SqaTokens.fontSizeSmall - 1);
    final headerStyle = cellStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );

    List<Widget>? headers;
    if (thead != null) {
      final tr = thead.children
          ?.whereType<md.Element>()
          .where((e) => e.tag == 'tr')
          .firstOrNull;
      if (tr != null) {
        headers = tr.children
            ?.whereType<md.Element>()
            .where((e) => e.tag == 'th' || e.tag == 'td')
            .map(
              (e) => _renderNodesAsRichText(e.children, baseStyle: headerStyle),
            )
            .toList();
      }
    }

    final List<List<Widget>> rows = [];
    if (tbody != null) {
      final trs =
          tbody.children?.whereType<md.Element>().where((e) => e.tag == 'tr') ??
          [];
      for (final tr in trs) {
        final rowCells = tr.children
            ?.whereType<md.Element>()
            .where((e) => e.tag == 'td' || e.tag == 'th')
            .map(
              (e) => _renderNodesAsRichText(e.children, baseStyle: cellStyle),
            )
            .toList();
        if (rowCells != null) {
          rows.add(rowCells);
        }
      }
    } else if (element.children != null) {
      // Fallback for tables without tbody (direct tr children)
      final trs = element.children!.whereType<md.Element>().where(
        (e) => e.tag == 'tr',
      );
      for (final tr in trs) {
        final rowCells = tr.children
            ?.whereType<md.Element>()
            .where((e) => e.tag == 'td' || e.tag == 'th')
            .map(
              (e) => _renderNodesAsRichText(e.children, baseStyle: cellStyle),
            )
            .toList();
        if (rowCells != null) {
          rows.add(rowCells);
        }
      }
    }

    if (rows.isNotEmpty || headers != null) {
      widgets.add(SqaMarkdownTable(headers: headers, rows: rows));
    }
  }

  void _addRawHtmlTable(String htmlContent) {
    final theme = Theme.of(context);
    final fragment = html.parseFragment(htmlContent);
    final table = fragment.querySelector('table');
    if (table == null) return;

    final cellStyle = theme.textTheme.bodySmall?.copyWith(fontSize: SqaTokens.fontSizeSmall - 1);
    final headerStyle = cellStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );

    final rows = table.querySelectorAll('tr');
    if (rows.isEmpty) return;

    // Identify max columns
    int maxCols = 0;
    for (final row in rows) {
      int cols = 0;
      for (final cell in row.children) {
        cols += int.tryParse(cell.attributes['colspan'] ?? '1') ?? 1;
      }
      if (cols > maxCols) maxCols = cols;
    }

    // Build column-major grid
    final List<List<SqaGridCell?>> columns = List.generate(maxCols, (_) => []);

    // Track occupied slots for rowspan
    final List<List<bool>> occupied = List.generate(
      rows.length,
      (_) => List.generate(maxCols, (_) => false),
    );

    for (int r = 0; r < rows.length; r++) {
      final row = rows[r];
      int c = 0;
      for (final cellElement in row.children) {
        // Skip occupied slots
        while (c < maxCols && occupied[r][c]) {
          c++;
        }
        if (c >= maxCols) break;

        final isHeader = cellElement.localName == 'th';
        final rowspan =
            int.tryParse(cellElement.attributes['rowspan'] ?? '1') ?? 1;
        final colspan =
            int.tryParse(cellElement.attributes['colspan'] ?? '1') ?? 1;

        // Render cell content using our high-fidelity HTML parser
        final cellWidget = Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _renderHtmlFragmentAsWidget(
                cellElement.innerHtml,
                isHeader ? headerStyle : cellStyle,
              ),
            ],
          ),
        );

        columns[c].add(
          SqaGridCell(child: cellWidget, rowspan: rowspan, isHeader: isHeader),
        );

        // Mark slots occupied
        for (int dr = 0; dr < rowspan; dr++) {
          for (int dc = 0; dc < colspan; dc++) {
            if (r + dr < rows.length && c + dc < maxCols) {
              occupied[r + dr][c + dc] = true;
            }
          }
        }
        c += colspan;
      }
    }

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
        child: SqaGridTable(
          columns: columns,
          columnWidths: List.generate(maxCols, (_) => 1.0 / maxCols),
        ),
      ),
    );
  }

  Widget _renderHtmlFragmentAsWidget(String innerHtml, TextStyle? style) {
    return _renderNodesAsRichText([md.Text(innerHtml)], baseStyle: style);
  }

  List<md.Node> _getCleanedAdmonitionChildren(md.Element element) {
    final children = List<md.Node>.from(element.children ?? []);
    if (children.isEmpty) return children;

    final markerPattern = RegExp(
      r'^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]\s*',
      caseSensitive: false,
    );

    if (children.first is md.Text) {
      final textNode = children.first as md.Text;
      final newText = textNode.text.replaceFirst(markerPattern, '');
      if (newText.trim().isEmpty) {
        children.removeAt(0);
      } else {
        children[0] = md.Text(newText);
      }
    } else if (children.first is md.Element &&
        (children.first as md.Element).tag == 'p') {
      final p = children.first as md.Element;
      if (p.children != null &&
          p.children!.isNotEmpty &&
          p.children!.first is md.Text) {
        final textNode = p.children!.first as md.Text;
        final newText = textNode.text.replaceFirst(markerPattern, '');
        if (newText.trim().isEmpty) {
          final List<md.Node> newPChildren = List.from(p.children!);
          newPChildren.removeAt(0);
          children[0] = md.Element('p', newPChildren);
          if (newPChildren.isEmpty) {
            children.removeAt(0);
          }
        } else {
          final List<md.Node> newPChildren = List.from(p.children!);
          newPChildren[0] = md.Text(newText);
          children[0] = md.Element('p', newPChildren);
        }
      }
    }
    return children;
  }

  void _addBlockquote(md.Element element) {
    final theme = Theme.of(context);
    final text = element.textContent.trim();
    final admonitionMatch = RegExp(
      r'^\[!(NOTE|TIP|IMPORTANT|WARNING|CAUTION)\]',
      caseSensitive: false,
    ).firstMatch(text);

    if (admonitionMatch != null) {
      final type = admonitionMatch.group(1)!.toUpperCase();
      Color color;
      IconData icon;

      switch (type) {
        case 'TIP':
          color = const Color(0xFF00E5A0);
          icon = Icons.lightbulb;
          break;
        case 'WARNING':
          color = const Color(0xFFFFD460);
          icon = Icons.warning;
          break;
        case 'CAUTION':
          color = const Color(0xFFFF5F6D);
          icon = Icons.error;
          break;
        case 'IMPORTANT':
          color = const Color(0xFF7B8CFF);
          icon = Icons.info;
          break;
        default:
          color = theme.colorScheme.primary;
          icon = Icons.info;
          break;
      }

      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: Container(
            padding: const EdgeInsets.all(SqaTokens.spacingMedium),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: SqaTokens.borderRadiusMedium,
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: SqaTokens.spacingLarge + SqaTokens.spacingXXSmall, color: color),
                const SizedBox(width: SqaTokens.spacingSmall + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: SqaTokens.spacingTiny),
                      _renderNodesAsRichText(
                        _getCleanedAdmonitionChildren(element),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: SqaTokens.spacingXSmall,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: SqaTokens.borderRadiusSmall,
                  ),
                ),
                const SizedBox(width: SqaTokens.spacingMedium),
                Expanded(
                  child: _renderNodesAsRichText(
                    element.children,
                    baseStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class SqaInlineSpanVisitor implements md.NodeVisitor {
  final BuildContext context;
  final TextStyle? baseStyle;
  final Map<String, GlobalKey> anchorKeys;
  final void Function(String) onAnchorTap;
  final String Function(String) idGenerator;
  final List<InlineSpan> spans = [];

  SqaInlineSpanVisitor({
    required this.context,
    this.baseStyle,
    required this.anchorKeys,
    required this.onAnchorTap,
    required this.idGenerator,
  });

  @override
  bool visitElementBefore(md.Element element) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentStyle =
        baseStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();

    switch (element.tag) {
      case 'strong':
        _addNestedSpans(
          element,
          currentStyle.copyWith(fontWeight: FontWeight.bold),
        );
        return false;
      case 'em':
        _addNestedSpans(
          element,
          currentStyle.copyWith(fontStyle: FontStyle.italic),
        );
        return false;
      case 'code':
        spans.add(
          TextSpan(
            text: element.textContent,
            style: currentStyle.copyWith(
              fontFamily: 'JetBrains Mono',
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              color: colorScheme.primary,
              fontSize: (currentStyle.fontSize ?? 13) * 0.9,
            ),
          ),
        );
        return false;
      case 'br':
        spans.add(const TextSpan(text: '\n'));
        return false;
      case 'a':
        final id = element.attributes['id'] ?? element.attributes['name'];
        final href = element.attributes['href'];

        if (id != null) {
          final uniqueId = idGenerator(id);
          final key = anchorKeys.putIfAbsent(uniqueId, () => GlobalKey());
          spans.add(WidgetSpan(child: SizedBox(key: key, width: SqaTokens.borderWidthThick, height: SqaTokens.borderWidthThick)));
        }

        if (href != null && href.startsWith('#')) {
          final anchorId = href.substring(1);
          spans.add(
            TextSpan(
              text: element.textContent,
              style: currentStyle.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => onAnchorTap(anchorId),
            ),
          );
          return false;
        } else if (href != null) {
          // Regular link
          spans.add(
            TextSpan(
              text: element.textContent,
              style: currentStyle.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          );
          return false;
        }
        _addNestedSpans(element, currentStyle);
        return false;
      case 'p':
        _addNestedSpans(element, currentStyle);
        spans.add(const TextSpan(text: '\n'));
        return false;
      case 'ul':
        _addNestedSpans(element, currentStyle);
        return false;
      case 'li':
        spans.add(
          TextSpan(
            text: ' • ',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        _addNestedSpans(element, currentStyle);
        spans.add(const TextSpan(text: '\n'));
        return false;
      case 'sup':
        _addNestedSpans(
          element,
          currentStyle.copyWith(fontSize: (currentStyle.fontSize ?? 14) * 0.75),
        );
        return false;
      case 'pre':
        spans.add(const TextSpan(text: '\n'));
        _addNestedSpans(element, currentStyle);
        spans.add(const TextSpan(text: '\n'));
        return false;
    }
    return true;
  }

  @override
  void visitElementAfter(md.Element element) {}

  @override
  void visitText(md.Text text) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentStyle =
        baseStyle ?? theme.textTheme.bodyMedium ?? const TextStyle();

    if (text.text.contains('<')) {
      final fragment = html.parseFragment(text.text);
      _processHtmlNode(fragment, spans, currentStyle, colorScheme);
    } else {
      _addMarkdownSpans(text.text, spans, currentStyle, colorScheme);
    }
  }

  void _addNestedSpans(md.Element element, TextStyle style) {
    final visitor = SqaInlineSpanVisitor(
      context: context,
      baseStyle: style,
      anchorKeys: anchorKeys,
      onAnchorTap: onAnchorTap,
      idGenerator: idGenerator,
    );
    for (final child in element.children ?? []) {
      child.accept(visitor);
    }
    spans.addAll(visitor.spans);
  }

  void _processHtmlNode(
    dom.Node node,
    List<InlineSpan> spans,
    TextStyle currentStyle,
    ColorScheme colorScheme,
  ) {
    for (final child in node.nodes) {
      if (child.nodeType == dom.Node.TEXT_NODE) {
        _addMarkdownSpans(child.text ?? '', spans, currentStyle, colorScheme);
      } else if (child is dom.Element) {
        switch (child.localName) {
          case 'a':
            final id = child.attributes['id'] ?? child.attributes['name'];
            final href = child.attributes['href'];
            if (id != null) {
              final uniqueId = idGenerator(id);
              final key = anchorKeys.putIfAbsent(uniqueId, () => GlobalKey());
              spans.add(
                WidgetSpan(child: SizedBox(key: key, width: 2, height: 2)),
              );
            }
            if (href != null && href.startsWith('#')) {
              final anchorId = href.substring(1);
              spans.add(
                TextSpan(
                  text: child.text,
                  style: currentStyle.copyWith(
                    color: colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => onAnchorTap(anchorId),
                ),
              );
            } else {
              _processHtmlNode(child, spans, currentStyle, colorScheme);
            }
            break;
          case 'b':
          case 'strong':
            _processHtmlNode(
              child,
              spans,
              currentStyle.copyWith(fontWeight: FontWeight.bold),
              colorScheme,
            );
            break;
          case 'i':
          case 'em':
            _processHtmlNode(
              child,
              spans,
              currentStyle.copyWith(fontStyle: FontStyle.italic),
              colorScheme,
            );
            break;
          case 'code':
            spans.add(
              TextSpan(
                text: child.text,
                style: currentStyle.copyWith(
                  fontFamily: 'JetBrains Mono',
                  backgroundColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  color: colorScheme.primary,
                  fontSize: (currentStyle.fontSize ?? 13) * 0.9,
                ),
              ),
            );
            break;
          case 'br':
            spans.add(const TextSpan(text: '\n'));
            break;
          case 'p':
            _processHtmlNode(child, spans, currentStyle, colorScheme);
            spans.add(const TextSpan(text: '\n'));
            break;
          case 'li':
            spans.add(
              TextSpan(
                text: ' • ',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            _processHtmlNode(child, spans, currentStyle, colorScheme);
            spans.add(const TextSpan(text: '\n'));
            break;
          case 'pre':
            spans.add(const TextSpan(text: '\n'));
            _processHtmlNode(
              child,
              spans,
              currentStyle.copyWith(
                fontFamily: 'JetBrains Mono',
                backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
              ),
              colorScheme,
            );
            spans.add(const TextSpan(text: '\n'));
            break;
          default:
            _processHtmlNode(child, spans, currentStyle, colorScheme);
        }
      }
    }
  }

  void _addMarkdownSpans(
    String text,
    List<InlineSpan> spans,
    TextStyle style,
    ColorScheme colorScheme,
  ) {
    final pattern = RegExp(
      r'\*\*(.*?)\*\*|\*(.*?)\*|`(.*?)`|\[(.*?)\]\((.*?)\)',
    );
    int lastMatchEnd = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: style.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (match.group(2) != null) {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: style.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (match.group(3) != null) {
        spans.add(
          TextSpan(
            text: match.group(3),
            style: style.copyWith(
              fontFamily: 'JetBrains Mono',
              backgroundColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              color: colorScheme.primary,
              fontSize: (style.fontSize ?? 13) * 0.9,
            ),
          ),
        );
      } else if (match.group(4) != null && match.group(5) != null) {
        final label = match.group(4)!;
        final href = match.group(5)!;
        if (href.startsWith('#')) {
          final anchorId = href.substring(1);
          spans.add(
            TextSpan(
              text: label,
              style: style.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => onAnchorTap(anchorId),
            ),
          );
        } else {
          spans.add(
            TextSpan(
              text: label,
              style: style.copyWith(
                color: colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          );
        }
      }
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }
  }
}

extension ThemeContext on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

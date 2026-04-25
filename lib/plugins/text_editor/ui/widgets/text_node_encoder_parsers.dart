import 'package:appflowy_editor/appflowy_editor.dart';

/// A custom SQA-standard Heading encoder parser.
/// It enforces a double newline (\n\n) after every heading to ensure
/// absolute block separation and prevent "Heading Bleed" into following paragraphs.
class SqaHeadingNodeParser extends NodeParser {
  const SqaHeadingNodeParser();

  @override
  String get id => HeadingBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final level = node.attributes[HeadingBlockKeys.level] as int? ?? 1;
    final delta = node.delta;
    if (delta == null) return '';

    final text = DeltaMarkdownEncoder().convert(delta);
    // Use '#' * level and ensure exactly two newlines for block separation
    return '${'#' * level} $text\n\n';
  }
}

/// A custom SQA-standard Paragraph encoder parser.
/// It ensures that top-level paragraphs are followed by a blank line
/// to maintain document structure and prevent Setext heading ambiguity.
class SqaParagraphNodeParser extends NodeParser {
  const SqaParagraphNodeParser();

  @override
  String get id => ParagraphBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    // If it's a raw HTML preservation node, handled by SqaHtmlNodeParser (if registered first)
    final isRawHtml = node.attributes['is_raw_html'] as bool? ?? false;
    if (isRawHtml) return '';

    final delta = node.delta;
    if (delta == null) return '';

    final text = DeltaMarkdownEncoder().convert(delta);
    if (text.isEmpty) return '\n';

    // Top-level paragraphs should have a blank line after them.
    // In AppFlowy, we can check if it's a child of the root.
    final isTopLevel = node.parent?.type == 'page' || node.parent == null;

    if (isTopLevel) {
      return '$text\n\n';
    } else {
      // Nested paragraphs (e.g. in lists) only need one newline
      return '$text\n';
    }
  }
}

/// A custom SQA-standard Quote encoder parser.
/// It enforces the "> " prefix and a double newline firewall.
class SqaQuoteNodeParser extends NodeParser {
  const SqaQuoteNodeParser();

  @override
  String get id => QuoteBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta;
    if (delta == null) return '';

    final text = DeltaMarkdownEncoder().convert(delta);
    return '> $text\n\n';
  }
}

import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

/// A custom SQA-standard HTML Preservation parser for the loader.
/// It catches raw HTML blocks and preserves the ENTIRE tag structure.
class SqaMarkdownHtmlParser extends CustomMarkdownParser {
  const SqaMarkdownHtmlParser();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    // We only care about Elements that are raw HTML blocks
    if (element is md.Element && _isRawHtmlTag(element.tag)) {
      // Reconstruct the raw HTML from the element
      // Since the markdown package doesn't give us the raw source easily,
      // we use an approximation that includes the tags.
      final rawHtml = _reconstructHtml(element);
      
      return [
        Node(
          type: 'raw_html',
          attributes: {
            'html_tag': element.tag,
            'content': rawHtml,
          },
        ),
      ];
    }
    
    // Also catch raw Text nodes that look like HTML tags at the start
    if (element is md.Text && element.text.trim().startsWith('<')) {
      return [
        Node(
          type: 'raw_html',
          attributes: {
            'content': element.text,
          },
        ),
      ];
    }

    return [];
  }

  bool _isRawHtmlTag(String tag) {
    const rawTags = {'table', 'div', 'section', 'article', 'header', 'footer', 'aside', 'nav', 'canvas', 'video', 'audio', 'iframe'};
    return rawTags.contains(tag.toLowerCase());
  }

  String _reconstructHtml(md.Element element) {
    final tag = element.tag;
    final attributes = element.attributes.entries
        .map((e) => ' ${e.key}="${e.value}"')
        .join();
    
    final children = element.children?.map((child) {
          if (child is md.Element) return _reconstructHtml(child);
          if (child is md.Text) return child.text;
          return '';
        }).join() ?? '';

    return '<$tag$attributes>$children</$tag>';
  }
}

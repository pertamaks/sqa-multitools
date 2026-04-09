import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

class HtmlFormatter {
  static String format(String html, {int indentWidth = 2}) {
    final document = parse(html);
    final buffer = StringBuffer();

    // Check if the input likely contained a full HTML document or just a fragment
    final hasHtmlTag =
        html.toLowerCase().contains('<html') || html.contains('<!DOCTYPE');

    if (hasHtmlTag) {
      _formatNode(document, 0, buffer, indentWidth);
    } else {
      // For fragments, we only format the children of the body
      for (var node in document.body!.nodes) {
        _formatNode(node, 0, buffer, indentWidth);
      }
    }

    return buffer.toString().trim();
  }

  static void _formatNode(
    Node node,
    int depth,
    StringBuffer buffer,
    int indentWidth,
  ) {
    if (node is DocumentType) {
      buffer.writeln('<!DOCTYPE ${node.name}>');
      return;
    }

    if (node is Comment) {
      buffer.writeln('${' ' * depth * indentWidth}<!--${node.data}-->');
      return;
    }

    if (node is Text) {
      final text = node.text.trim();
      if (text.isNotEmpty) {
        buffer.writeln(' ' * depth * indentWidth + text);
      }
      return;
    }

    if (node is Element) {
      final String indent = ' ' * depth * indentWidth;
      final String tag = node.localName ?? '';

      // Inline tags list (simplified)
      const inlineTags = {
        'a',
        'span',
        'b',
        'i',
        'strong',
        'em',
        'small',
        'u',
        'sub',
        'sup',
        'code',
        'kbd',
        'abbr',
      };

      // Void elements (HTML5)
      const voidTags = {
        'br',
        'hr',
        'img',
        'input',
        'link',
        'meta',
        'area',
        'base',
        'col',
        'embed',
        'param',
        'source',
        'track',
        'wbr',
      };

      // Build attributes string
      final attributes = node.attributes.entries
          .map((e) => ' ${e.key}="${e.value}"')
          .join('');

      buffer.write('$indent<$tag$attributes');

      if (voidTags.contains(tag)) {
        buffer.writeln('>');
        return;
      }

      buffer.write('>');

      if (node.nodes.isEmpty) {
        buffer.writeln('</$tag>');
      } else {
        // Decide whether to put content on new line
        final bool hasOnlyText =
            node.nodes.length == 1 && node.nodes.first is Text;
        final bool isInline = inlineTags.contains(tag);

        if (hasOnlyText && isInline) {
          buffer.write(node.text.trim());
          buffer.writeln('</$tag>');
        } else {
          buffer.writeln();
          for (var child in node.nodes) {
            _formatNode(child, depth + 1, buffer, indentWidth);
          }
          buffer.writeln('$indent</$tag>');
        }
      }
    }

    if (node is Document) {
      for (var child in node.nodes) {
        _formatNode(child, depth, buffer, indentWidth);
      }
    }
  }
}

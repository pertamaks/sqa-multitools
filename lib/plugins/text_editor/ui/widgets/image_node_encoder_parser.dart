import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

/// Encodes an Image node back into Markdown ![alt](url)
class SqaImageNodeParser extends NodeParser {
  const SqaImageNodeParser();

  @override
  String get id => ImageBlockKeys.type;

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final url = node.attributes[ImageBlockKeys.url] as String? ?? '';
    final alt = node.attributes['alt'] as String? ?? 'image';

    // The "Whitespace Firewall": Always follow block nodes with double newline
    return '![$alt]($url)\n\n';
  }
}

/// Decodes Markdown ![alt](url) (which the markdown package parses as an 'img' element)
/// back into an AppFlowy Image node.
class SqaMarkdownImageParser extends CustomMarkdownParser {
  const SqaMarkdownImageParser();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (element is md.Element && element.tag == 'img') {
      final url = element.attributes['src'] ?? '';
      final alt = element.attributes['alt'] ?? 'image';

      return [
        Node(
          type: ImageBlockKeys.type,
          attributes: {
            ImageBlockKeys.url: url,
            'alt': alt,
          },
        ),
      ];
    }
    return [];
  }
}

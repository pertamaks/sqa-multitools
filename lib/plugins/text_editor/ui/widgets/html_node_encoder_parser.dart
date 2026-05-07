import 'package:appflowy_editor/appflowy_editor.dart';

/// A custom SQA-standard HTML Preservation parser for the encoder.
/// It identifies 'raw_html' nodes and exports their content exactly as text.
class SqaHtmlNodeParser extends NodeParser {
  const SqaHtmlNodeParser();

  @override
  String get id => 'raw_html';

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    assert(node.type == 'raw_html');

    final content = node.attributes['content'] as String? ?? '';
    // Use double newline to ensure absolute separation from the next block
    return '$content\n\n';
  }
}

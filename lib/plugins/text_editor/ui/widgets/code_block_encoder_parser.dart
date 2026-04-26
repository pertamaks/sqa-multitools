import 'package:appflowy_editor/appflowy_editor.dart';

/// A custom SQA-standard Code Block encoder parser.
/// It preserves indentation and language metadata during Markdown export.
class SqaCodeBlockNodeParser extends NodeParser {
  const SqaCodeBlockNodeParser();

  @override
  String get id => 'code';

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    assert(node.type == 'code');

    final delta = node.delta;
    final language = node.attributes['language'] ?? '';
    final indent = node.attributes['indent'] as int? ?? 0;

    if (delta == null) {
      return '';
    }

    // Convert delta to plain text
    final code = delta.toPlainText();

    // Create the fenced block
    String result = '```$language\n$code\n```';

    // Apply indentation if nested
    if (indent > 0) {
      final spaces = '    ' * indent;
      result = result.split('\n').map((line) => '$spaces$line').join('\n');
    }

    // Ensure double newline for absolute block separation
    return '$result\n\n';
  }
}

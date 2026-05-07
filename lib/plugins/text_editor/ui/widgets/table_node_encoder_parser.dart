import 'package:appflowy_editor/appflowy_editor.dart';

/// A custom SQA-standard Table encoder parser.
/// It preserves column alignment metadata (left, center, right) during Markdown export.
class SqaTableNodeParser extends NodeParser {
  const SqaTableNodeParser();

  @override
  String get id => 'table';

  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final int rowsLen = node.attributes['rowsLen'] as int? ?? 0;
    final int colsLen = node.attributes['colsLen'] as int? ?? 0;
    final List<dynamic> alignments =
        node.attributes['alignments'] as List<dynamic>? ?? [];

    if (rowsLen == 0 || colsLen == 0) return '';

    String result = '';

    // Function to get cell content
    String getCellMarkdown(int row, int col) {
      // In AppFlowy, cells are stored in Column-Major order:
      // [Col 0, Row 0], [Col 0, Row 1], ..., [Col 1, Row 0], [Col 1, Row 1]
      final index = col * rowsLen + row;
      if (index < node.children.length) {
        final cell = node.children.elementAt(index);
        String md = documentToMarkdown(Document(root: cell)).trim();
        // Remove trailing newlines and escape pipes
        return md.replaceAll('\n', '<br>').replaceAll('|', '\\|');
      }
      return '';
    }

    // Build the rows
    for (var i = 0; i < rowsLen; i++) {
      String rowStr = '|';
      for (var j = 0; j < colsLen; j++) {
        String cellStr = getCellMarkdown(i, j);
        if (cellStr.isEmpty) cellStr = ' ';
        rowStr += '$cellStr|';
      }
      result += '$rowStr\n';
    }

    // Insert the alignment row after the header (first row)
    final List<String> lines = result.trim().split('\n');
    if (lines.isNotEmpty) {
      String alignRow = '|';
      for (var j = 0; j < colsLen; j++) {
        // AppFlowy alignment values: 0 = left, 1 = center, 2 = right
        final align = j < alignments.length ? alignments[j] : 0;
        switch (align) {
          case 1: // Center
            alignRow += ':---:|';
            break;
          case 2: // Right
            alignRow += '---:|';
            break;
          default: // Left / 0
            alignRow += ':---|';
            break;
        }
      }
      lines.insert(1, alignRow);
      result = lines.join('\n');
    }

    // Ensure double newline for absolute block separation
    return '$result\n\n';
  }
}

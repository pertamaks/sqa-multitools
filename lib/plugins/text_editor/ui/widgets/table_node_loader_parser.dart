import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:markdown/markdown.dart' as md;

/// A custom SQA-standard Table loader parser.
/// It correctly identifies column alignment (Left, Center, Right) from Markdown elements.
class SqaMarkdownTableParser extends CustomMarkdownParser {
  const SqaMarkdownTableParser();

  @override
  List<Node> transform(
    md.Node element,
    List<CustomMarkdownParser> parsers, {
    MarkdownListType listType = MarkdownListType.unknown,
    int? startNumber,
  }) {
    if (element is! md.Element || element.tag != 'table') {
      return [];
    }

    final ec = element.children;
    if (ec == null || ec.isEmpty) {
      return [];
    }

    // 1. Extract Header and Alignments
    // 1. Collect all rows (headers + body)
    final allRows = <List<md.Element>>[];

    final headElement = ec
        .whereType<md.Element>()
        .where((e) => e.tag == 'thead')
        .firstOrNull;
    if (headElement != null) {
      final rows =
          headElement.children?.whereType<md.Element>().where(
            (e) => e.tag == 'tr',
          ) ??
          [];
      for (final tr in rows) {
        allRows.add(
          tr.children
                  ?.whereType<md.Element>()
                  .where((e) => (e.tag == 'th' || e.tag == 'td'))
                  .toList() ??
              [],
        );
      }
    }

    final bodyElement = ec
        .whereType<md.Element>()
        .where((e) => e.tag == 'tbody')
        .firstOrNull;
    if (bodyElement != null) {
      final rows =
          bodyElement.children?.whereType<md.Element>().where(
            (e) => e.tag == 'tr',
          ) ??
          [];
      for (final tr in rows) {
        allRows.add(
          tr.children
                  ?.whereType<md.Element>()
                  .where((e) => e.tag == 'td')
                  .toList() ??
              [],
        );
      }
    }

    if (allRows.isEmpty) return [];

    // 2. Transpose Rows into Columns for TableNode.fromList(cells)
    final int rowsLen = allRows.length;
    final int colsLen = allRows[0].length;
    final List<List<Node>> cells = List.generate(colsLen, (_) => []);
    final List<int> alignments = [];

    for (int col = 0; col < colsLen; col++) {
      for (int row = 0; row < rowsLen; row++) {
        final element = allRows[row][col];

        // Capture alignment from the first row (header)
        if (row == 0) {
          final alignAttr = element.attributes['align']?.toLowerCase();
          final styleAttr = element.attributes['style']?.toLowerCase() ?? '';
          int alignment = 0;
          if (alignAttr == 'center' ||
              styleAttr.contains('text-align: center')) {
            alignment = 1;
          } else if (alignAttr == 'right' ||
              styleAttr.contains('text-align: right')) {
            alignment = 2;
          }
          alignments.add(alignment);
        }

        cells[col].add(
          paragraphNode(
            delta: DeltaMarkdownDecoder().convertNodes(element.children),
          ),
        );
      }
    }

    if (cells.isEmpty) return [];

    // In AppFlowy, columns are the first dimension in TableNode.fromList?
    // Wait, the standard parser (MarkdownTableListParserV2) does row-first then transposes?
    // Let's check the standard parser's loops again.
    // Line 55: for (var i = 0; i < th.length; i++) { ... cells.add(row); }
    // This looks like it adds columns as rows!

    // Actually, AppFlowy's TableNode.fromList expects a 2D list where cells[col][row].
    final tableNode = TableNode.fromList(cells);

    // Set the captured alignments
    if (alignments.isNotEmpty) {
      tableNode.node.updateAttributes({'alignments': alignments});
    }

    return [tableNode.node];
  }
}

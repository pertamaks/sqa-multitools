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

        final cellChildren = <Node>[];
        if (element.children != null) {
          for (final child in element.children!) {
            bool handled = false;
            for (final parser in parsers) {
              if (parser == this) continue; // Avoid infinite recursion
              final nodes = parser.transform(child, parsers);
              if (nodes.isNotEmpty) {
                cellChildren.addAll(nodes);
                handled = true;
                break;
              }
            }

            if (!handled) {
              if (child is md.Text) {
                cellChildren.add(
                  paragraphNode(delta: Delta()..insert(child.text)),
                );
              } else if (child is md.Element) {
                // If it's an unhandled element (like <a> or <span>),
                // try to convert its nodes to a delta if possible
                cellChildren.add(
                  paragraphNode(
                    delta: DeltaMarkdownDecoder().convertNodes([child]),
                  ),
                );
              }
            }
          }
        }

        if (cellChildren.isEmpty) {
          cellChildren.add(paragraphNode());
        }

        final cellNode = Node(
          type: TableCellBlockKeys.type,
          children: cellChildren,
        );
        cells[col].add(cellNode);
      }
    }

    // 3. Manually construct the TableNode to avoid TableNode.fromList's strict delta assertions.
    // This allows table cells to contain non-text nodes like Images.
    // IMPORTANT: We must include default attributes to avoid "Null check operator" crashes
    // during rendering (specifically in TableNode's internal calculations).
    final tableNode = Node(
      type: TableBlockKeys.type,
      attributes: {
        TableBlockKeys.rowsLen: rowsLen,
        TableBlockKeys.colsLen: colsLen,
        TableBlockKeys.colDefaultWidth: 160.0,
        TableBlockKeys.rowDefaultHeight: 40.0,
        TableBlockKeys.colMinimumWidth: 40.0,
        TableBlockKeys.borderWidth: 2.0,
        'alignments': alignments,
      },
    );

    for (int col = 0; col < colsLen; col++) {
      for (int row = 0; row < rowsLen; row++) {
        final cellNode = cells[col][row];
        cellNode.updateAttributes({
          TableCellBlockKeys.rowPosition: row,
          TableCellBlockKeys.colPosition: col,
        });
        tableNode.insert(cellNode);
      }
    }

    return [tableNode];
  }
}

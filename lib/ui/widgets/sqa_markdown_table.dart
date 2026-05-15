import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

/// A premium, high-fidelity table widget for Markdown content.
/// Supports dynamic column counts and striped rows.
class SqaMarkdownTable extends StatelessWidget {
  final List<Widget>? headers;
  final List<List<Widget>> rows;
  final EdgeInsets padding;

  const SqaMarkdownTable({
    super.key,
    this.headers,
    required this.rows,
    this.padding = const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine max columns to ensure table stability
    int maxColumns = headers?.length ?? 0;
    for (final row in rows) {
      if (row.length > maxColumns) maxColumns = row.length;
    }
    if (maxColumns == 0) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SqaTokens.spacingXSmall),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: SqaTokens.borderWidthThin / 2,
            ),
          ),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              if (headers != null && headers!.isNotEmpty)
                TableRow(
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                  children: [
                    ...headers!.map(
                      (h) => _buildCell(context, h, isHeader: true),
                    ),
                    ...List.generate(
                      (maxColumns - headers!.length).clamp(0, 100),
                      (_) => _buildCell(
                        context,
                        const SizedBox.shrink(),
                        isHeader: true,
                      ),
                    ),
                  ],
                ),
              ...rows.asMap().entries.map((entry) {
                final index = entry.key;
                final rowData = entry.value;
                final bool isEven = index.isEven;

                final rowCells = rowData
                    .map((cell) => _buildCell(context, cell))
                    .toList();

                while (rowCells.length < maxColumns) {
                  rowCells.add(_buildCell(context, const SizedBox.shrink()));
                }

                return TableRow(
                  decoration: BoxDecoration(
                    color: isEven
                        ? colorScheme.onSurface.withValues(alpha: 0.02)
                        : Colors.transparent,
                  ),
                  children: rowCells,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    Widget child, {
    bool isHeader = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SqaTokens.spacingSmall + 4,
        vertical: SqaTokens.spacingSmall + 2,
      ),
      child: child,
    );
  }
}

import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';

/// A column-major grid table that supports vertical spanning (rowspan).
class SqaGridTable extends StatelessWidget {
  final List<List<SqaGridCell?>> columns;
  final List<double> columnWidths;

  const SqaGridTable({
    super.key,
    required this.columns,
    required this.columnWidths,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Separate header row from content rows for better layout stability
    final headerRow = columns
        .map((col) => col.isNotEmpty && col.first!.isHeader ? col.first : null)
        .toList();
    final hasHeader = headerRow.any((h) => h != null);

    return Container(
      decoration: BoxDecoration(
        borderRadius: SqaTokens.borderRadiusSmall,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (hasHeader)
            Container(
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(headerRow.length, (i) {
                    final cell = headerRow[i];
                    return Expanded(
                      flex: (columnWidths[i] * 100).toInt(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SqaTokens.spacingMedium,
                          vertical: SqaTokens.spacingSmall + 2,
                        ),
                        decoration: BoxDecoration(
                          border: i < headerRow.length - 1
                              ? Border(
                                  right: BorderSide(
                                    color: colorScheme.outlineVariant
                                        .withValues(alpha: 0.1),
                                    width: 0.5,
                                  ),
                                )
                              : null,
                        ),
                        child: cell?.child ?? const SizedBox.shrink(),
                      ),
                    );
                  }),
                ),
              ),
            ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(columns.length, (colIndex) {
                final colCells = columns[colIndex]
                    .where((c) => c != null && !c.isHeader)
                    .toList();

                return Expanded(
                  flex: (columnWidths[colIndex] * 100).toInt(),
                  child: Container(
                    decoration: BoxDecoration(
                      border: colIndex < columns.length - 1
                          ? Border(
                              right: BorderSide(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.1,
                                ),
                                width: 0.5,
                              ),
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: colCells.asMap().entries.map((entry) {
                        final cellIndex = entry.key;
                        final cell = entry.value!;

                        return Expanded(
                          flex: cell.rowspan,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: SqaTokens.spacingMedium,
                              vertical: SqaTokens.spacingSmall + 2,
                            ),
                            decoration: BoxDecoration(
                              border: cellIndex < colCells.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: colorScheme.outlineVariant
                                            .withValues(alpha: 0.1),
                                        width: 0.5,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: cell.child,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class SqaGridCell {
  final Widget child;
  final int rowspan;
  final bool isHeader;

  SqaGridCell({required this.child, this.rowspan = 1, this.isHeader = false});
}

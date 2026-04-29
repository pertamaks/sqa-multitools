import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'sqa_block_component_wrapper.dart';
import '../../../../ui/widgets/sqa_fade_wrapper.dart';
class SqaTableBlockComponentBuilder extends TableBlockComponentBuilder {
  SqaTableBlockComponentBuilder({
    super.configuration,
    super.tableStyle,
    super.menuBuilder,
  });

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final widget = super.build(blockComponentContext);
    final theme = Theme.of(blockComponentContext.buildContext);

    return SqaBlockComponentWrapper(
      node: widget.node,
      configuration: widget.configuration,
      showActions: widget.showActions,
      actionBuilder: widget.actionBuilder,
      actionTrailingBuilder: widget.actionTrailingBuilder,
      child: SqaFadeWrapper(
        axis: Axis.horizontal,
        showStart: true,
        showEnd: true,
        child: Theme(
          data: theme.copyWith(
            iconTheme: IconThemeData(
              color: theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            // MAINTENANCE: Standardize the hardcoded Card widgets in appflowy_editor's TableActionButton
            cardTheme: CardThemeData(
              color: theme.colorScheme.surfaceContainerHigh,
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                  width: 1,
                ),
              ),
            ),
          ),
          child: widget,
        ),
      ),
    );
  }
}

/// A customized TableCellBlockComponentBuilder that injects SQA-standard row handles.
/// In appflowy_editor, the row-level interaction handles are provided by the cell builder.
class SqaTableCellBlockComponentBuilder extends TableCellBlockComponentBuilder {
  SqaTableCellBlockComponentBuilder({super.menuBuilder});

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final widget = super.build(blockComponentContext);

    // Standardize the row handle behavior via the block wrapper pattern
    return SqaBlockComponentWrapper(
      node: widget.node,
      configuration: widget.configuration,
      child: widget,
    );
  }
}

/// A concrete wrapper for BlockComponentWidget that allows themed child wrapping.

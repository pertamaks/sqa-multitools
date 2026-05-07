import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../ui/widgets/sqa_styles.dart';

/// A custom SQA-standard Quote Block builder.
/// It provides a premium aesthetic with a subtle background and a stylized left border.
class SqaQuoteBlockComponentBuilder extends QuoteBlockComponentBuilder {
  SqaQuoteBlockComponentBuilder({super.configuration});

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return SqaQuoteBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) =>
          actionBuilder(blockComponentContext, state),
      actionTrailingBuilder: (context, state) =>
          actionTrailingBuilder(blockComponentContext, state),
    );
  }

  @override
  BlockComponentValidate get validate =>
      (node) => node.delta != null;
}

class SqaQuoteBlockComponentWidget extends BlockComponentStatefulWidget {
  const SqaQuoteBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.actionTrailingBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<SqaQuoteBlockComponentWidget> createState() =>
      _SqaQuoteBlockComponentWidgetState();
}

class _SqaQuoteBlockComponentWidgetState
    extends State<SqaQuoteBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectableMixin,
        BlockComponentConfigurable,
        BlockComponentBackgroundColorMixin,
        BlockComponentTextDirectionMixin,
        BlockComponentAlignMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'sqa_quote_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey = GlobalKey(
    debugLabel: 'quote',
  );

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScaleFactor = editorState.editorStyle.textScaleFactor;

    Widget child = Container(
      width: double.infinity,
      alignment: alignment,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.05),
        borderRadius: SqaStyles.radiusMedium,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SQA-style Quote Bar (Thicker and rounded)
            Container(
              width: 4 * textScaleFactor,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: AppFlowyRichText(
                key: forwardKey,
                delegate: this,
                node: widget.node,
                editorState: editorState,
                placeholderText: 'Quote...',
                textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
                  GoogleFonts.inter(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
                cursorColor: theme.colorScheme.primary,
                selectionColor: theme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Apply standard AppFlowy wrappers for selection and actions
    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [BlockSelectionType.block],
      child: child,
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        actionTrailingBuilder: widget.actionTrailingBuilder,
        child: child,
      );
    }

    return Container(
      key: blockComponentKey,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }
}

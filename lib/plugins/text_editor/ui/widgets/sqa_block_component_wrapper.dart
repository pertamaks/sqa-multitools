import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A centralized wrapper for custom SQA block components.
/// Handles selection containers, action handles, and consistent margins.
class SqaBlockComponentWrapper extends BlockComponentStatelessWidget {
  final Widget child;
  final SelectableMixin? delegate;

  const SqaBlockComponentWrapper({
    super.key,
    required super.node,
    required super.configuration,
    this.delegate,
    super.showActions = false,
    super.actionBuilder,
    super.actionTrailingBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    late final editorState = Provider.of<EditorState>(context, listen: false);

    Widget wrappedChild = child;

    // 1. Action Wrapper (Inside)
    if (showActions && actionBuilder != null) {
      wrappedChild = BlockComponentActionWrapper(
        node: node,
        actionBuilder: actionBuilder!,
        actionTrailingBuilder: actionTrailingBuilder,
        child: wrappedChild,
      );
    }

    // 2. Selection Container (Outer)
    if (delegate != null) {
      wrappedChild = BlockSelectionContainer(
        node: node,
        delegate: delegate!,
        listenable: editorState.selectionNotifier,
        remoteSelection: editorState.remoteSelections,
        cursorColor: editorState.editorStyle.cursorColor,
        selectionColor: editorState.editorStyle.selectionColor,
        blockColor: editorState.editorStyle.selectionColor.withValues(alpha: 0.3),
        supportTypes: const [
          BlockSelectionType.block,
          BlockSelectionType.selection,
          BlockSelectionType.cursor,
        ],
        selectionAboveBlock: true,
        child: wrappedChild,
      );
    }

    return wrappedChild;
  }
}

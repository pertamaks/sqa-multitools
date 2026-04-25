import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../../ui/widgets/sqa_styles.dart';

/// A premium SQA-standard action handle for block components.
/// Provides a six-dot drag indicator and an add button with smooth hover effects.
class SqaBlockActionHandle extends StatelessWidget {
  final Node node;
  final BlockComponentActionState state;

  const SqaBlockActionHandle({
    super.key,
    required this.node,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Add Button
          _SqaActionButton(
            icon: Symbols.add,
            onTap: () {
              final editorState = context.read<EditorState>();
              final transaction = editorState.transaction;
              transaction.insertNode(
                node.path.next,
                paragraphNode(),
              );
              editorState.apply(transaction);
            },
            tooltip: 'Add Block Below',
          ),
          const SizedBox(width: 2),
          // 2. Drag Handle (Six Dots) with Options Menu
          MenuAnchor(
            style: MenuStyle(
              backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surface),
              surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
              elevation: const WidgetStatePropertyAll(8),
              padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
              shape: WidgetStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: SqaStyles.radiusLarge,
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            menuChildren: [
              MenuItemButton(
                leadingIcon: Icon(Symbols.content_copy, size: 18, color: theme.colorScheme.onSurfaceVariant),
                onPressed: () {
                  final editorState = context.read<EditorState>();
                  final transaction = editorState.transaction;
                  transaction.insertNode(
                    node.path.next,
                    node.copyWith(),
                  );
                  editorState.apply(transaction);
                },
                style: MenuItemButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(140, 36),
                  shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
                ),
                child: Text(
                  'Duplicate',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              MenuItemButton(
                leadingIcon: Icon(Symbols.delete, size: 18, color: theme.colorScheme.error),
                onPressed: () {
                  final editorState = context.read<EditorState>();
                  final transaction = editorState.transaction;
                  transaction.deleteNode(node);
                  editorState.apply(transaction);
                },
                style: MenuItemButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(140, 36),
                  shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusMedium),
                ),
                child: Text(
                  'Delete',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
            builder: (context, controller, child) {
              return _SqaActionButton(
                icon: Symbols.drag_indicator,
                onTap: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                tooltip: 'Options',
                isDraggable: true,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SqaActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isDraggable;

  const _SqaActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isDraggable = false,
  });

  @override
  State<_SqaActionButton> createState() => _SqaActionButtonState();
}

class _SqaActionButtonState extends State<_SqaActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 500),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: widget.isDraggable ? SystemMouseCursors.grab : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _isHovered 
                  ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
                  : Colors.transparent,
              borderRadius: SqaStyles.radiusSmall,
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: _isHovered 
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

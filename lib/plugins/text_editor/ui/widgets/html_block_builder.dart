import 'package:flutter/material.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:google_fonts/google_fonts.dart';

class RawHtmlBlockComponentBuilder extends BlockComponentBuilder {
  RawHtmlBlockComponentBuilder()
    : super(
        configuration: BlockComponentConfiguration(
          padding: (node) => const EdgeInsets.symmetric(vertical: 8.0),
        ),
      );

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return RawHtmlBlockComponentWidget(
      key: ValueKey(node.id),
      node: node,
      configuration: configuration,
    );
  }
}

class RawHtmlBlockComponentWidget extends BlockComponentStatelessWidget {
  const RawHtmlBlockComponentWidget({
    super.key,
    required super.node,
    required super.configuration,
    super.showActions = false,
    super.actionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = node.attributes['content'] as String? ?? '';

    return Padding(
      padding: configuration.padding(node),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code,
                  size: 14,
                  color: theme.colorScheme.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'RAW HTML',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: GoogleFonts.firaCode(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

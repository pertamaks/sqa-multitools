import 'dart:io';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import 'sqa_block_component_wrapper.dart';
import 'sqa_block_action_handle.dart';

/// A custom SQA-standard Image Block builder.
/// Renders images with premium rounded corners, adaptive sizing,
/// and absolute-path resolution for local attachments.
class SqaImageBlockComponentBuilder extends ImageBlockComponentBuilder {
  final String? storagePath;

  SqaImageBlockComponentBuilder({
    super.configuration,
    this.storagePath,
  });

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return SqaImageBlockComponentWidget(
      key: node.key,
      node: node,
      storagePath: storagePath,
      configuration: configuration,
      showActions: showActions(node),
      actionBuilder: (context, state) => SqaBlockActionHandle(
        node: node,
        state: state,
      ),
      actionTrailingBuilder: (context, state) =>
          actionTrailingBuilder(blockComponentContext, state),
    );
  }

  @override
  bool Function(Node node) get showActions => (node) => true;

  @override
  BlockComponentValidate get validate => (node) =>
      node.attributes[ImageBlockKeys.url] != null;
}

class SqaImageBlockComponentWidget extends BlockComponentStatefulWidget {
  final String? storagePath;

  const SqaImageBlockComponentWidget({
    super.key,
    required super.node,
    this.storagePath,
    super.showActions,
    super.actionBuilder,
    super.actionTrailingBuilder,
    super.configuration = const BlockComponentConfiguration(),
  });

  @override
  State<SqaImageBlockComponentWidget> createState() =>
      _SqaImageBlockComponentWidgetState();
}

class _SqaImageBlockComponentWidgetState
    extends State<SqaImageBlockComponentWidget>
    with SelectableMixin, BlockComponentConfigurable, BlockComponentAlignMixin {
  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  final imageKey = GlobalKey();

  RenderBox? get _renderBox => context.findRenderObject() as RenderBox?;

  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Position start() => Position(path: widget.node.path, offset: 0);

  @override
  Position end() => Position(path: widget.node.path, offset: 1);

  @override
  Position getPositionInOffset(Offset start) => end();

  @override
  bool get shouldCursorBlink => false;

  @override
  CursorStyle get cursorStyle => CursorStyle.cover;

  @override
  Rect getBlockRect({
    bool shiftWithBaseOffset = false,
  }) {
    final imageBox = imageKey.currentContext?.findRenderObject();
    if (imageBox is RenderBox) {
      return Offset.zero & imageBox.size;
    }
    return Rect.zero;
  }

  @override
  Rect? getCursorRectInPosition(
    Position position, {
    bool shiftWithBaseOffset = false,
  }) {
    final parentBox = context.findRenderObject();
    final imageBox = imageKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && imageBox is RenderBox) {
      return imageBox.localToGlobal(Offset.zero, ancestor: parentBox) &
          imageBox.size;
    }
    return null;
  }

  @override
  List<Rect> getRectsInSelection(
    Selection selection, {
    bool shiftWithBaseOffset = false,
  }) {
    if (_renderBox == null) return [];
    final parentBox = context.findRenderObject();
    final imageBox = imageKey.currentContext?.findRenderObject();
    if (parentBox is RenderBox && imageBox is RenderBox) {
      return [
        imageBox.localToGlobal(Offset.zero, ancestor: parentBox) &
            imageBox.size,
      ];
    }
    return [Offset.zero & _renderBox!.size];
  }

  @override
  Selection getSelectionInRange(Offset start, Offset end) => Selection.single(
        path: widget.node.path,
        startOffset: 0,
        endOffset: 1,
      );

  @override
  Offset localToGlobal(
    Offset offset, {
    bool shiftWithBaseOffset = false,
  }) =>
      _renderBox!.localToGlobal(offset);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = node.attributes[ImageBlockKeys.url] as String? ?? '';

    // Resolve URL: If it's a relative path starting with 'attachments/',
    // prepend the storagePath if available.
    Widget image;
    if (url.startsWith('attachments/')) {
      if (widget.storagePath != null) {
        final fullPath = '${widget.storagePath}${Platform.pathSeparator}$url';
        final file = File(fullPath);
        if (file.existsSync()) {
          image = Image.file(
            file,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                _buildError(context, 'File not found on disk'),
          );
        } else {
          image = _buildError(context, 'Attachment missing');
        }
      } else {
        image = _buildError(context, 'Storage path not configured');
      }
    } else if (url.startsWith('http')) {
      image = Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildError(context, 'Failed to load network image'),
      );
    } else {
      image = _buildError(context, 'Invalid image source');
    }

    Widget child = Container(
      width: double.infinity,
      alignment: alignment,
      child: ClipRRect(
        borderRadius: SqaStyles.radiusLarge,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: image,
        ),
      ),
    );

    return SqaBlockComponentWrapper(
      node: node,
      configuration: configuration,
      delegate: this,
      showActions: widget.showActions,
      actionBuilder: widget.actionBuilder,
      actionTrailingBuilder: widget.actionTrailingBuilder,
      child: Padding(
        key: imageKey,
        padding: padding,
        child: child,
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Container(
      height: 120,
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Symbols.broken_image,
            color: theme.colorScheme.error.withValues(alpha: 0.5),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

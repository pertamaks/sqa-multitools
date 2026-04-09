import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'sqa_styles.dart';

/// A custom scroll behavior that enables mouse dragging for specific widgets.
class _SqaMouseDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
  };
}

class SqaSegmentedButton<T> extends StatefulWidget {
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool showSelectedIcon;
  final EdgeInsets? padding;
  final bool isChild;
  final bool hasChild;

  const SqaSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.showSelectedIcon = false,
    this.padding,
    this.isChild = false,
    this.hasChild = false,
  });

  @override
  State<SqaSegmentedButton<T>> createState() => _SqaSegmentedButtonState<T>();
}

class _SqaSegmentedButtonState<T> extends State<SqaSegmentedButton<T>> {
  final ScrollController _scrollController = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollState);
    // Use addPostFrameCallback to check initial overflow
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollState);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    final bool canScroll = maxScroll > 0;
    final bool newShowLeft = canScroll && currentScroll > 5;
    final bool newShowRight = canScroll && currentScroll < maxScroll - 5;

    if (newShowLeft != _showLeftFade || newShowRight != _showRightFade) {
      setState(() {
        _showLeftFade = newShowLeft;
        _showRightFade = newShowRight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // We only use expandedInsets if the segments are few enough to fit on screen.
    // This prevents the "infinite width" crash in SingleChildScrollView and
    // ensures the edge-to-edge look for standard 2-3 segment controls.
    final bool shouldStretch = widget.segments.length <= 3;

    final segmentedButton = SegmentedButton<T>(
      segments: widget.segments,
      selected: widget.selected,
      onSelectionChanged: widget.onSelectionChanged,
      showSelectedIcon: widget.showSelectedIcon,
      expandedInsets: shouldStretch ? EdgeInsets.zero : null,
      style:
          SegmentedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            selectedBackgroundColor: colorScheme.primaryContainer,
            side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
          ).copyWith(
            shape: SqaStyles.buttonShape,
            overlayColor: SqaStyles.buttonOverlay(context),
          ),
    );

    final effectivePadding =
        widget.padding ??
        EdgeInsets.only(
          top: widget.isChild ? 2 : 4,
          bottom: widget.hasChild ? 2 : 4,
          left: widget.isChild ? 16 : 0,
          right: widget.isChild ? 16 : 0,
        );

    if (shouldStretch) {
      return Padding(padding: effectivePadding, child: segmentedButton);
    }

    return Padding(
      padding: effectivePadding,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _updateScrollState();
          return false;
        },
        child: ShaderMask(
          shaderCallback: (Rect rect) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                _showLeftFade ? Colors.transparent : Colors.black,
                Colors.black,
                Colors.black,
                _showRightFade ? Colors.transparent : Colors.black,
              ],
              stops: const [0.0, 0.06, 0.94, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: ScrollConfiguration(
            behavior: _SqaMouseDragScrollBehavior(),
            child: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  // Consume wheel signals
                }
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                clipBehavior: Clip.hardEdge,
                child: segmentedButton,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'sqa_styles.dart';
import 'sqa_fade_wrapper.dart';

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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      style: SegmentedButton.styleFrom(
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
      child: SqaFadeWrapper(
        axis: Axis.horizontal,
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
    );
  }
}

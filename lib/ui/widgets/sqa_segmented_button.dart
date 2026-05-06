import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'sqa_styles.dart';
import 'sqa_fade_wrapper.dart';
import 'sqa_scroll_behavior.dart';

class SqaSegmentedButton<T> extends StatefulWidget {
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;
  final bool showSelectedIcon;
  final EdgeInsets? padding;
  final bool isChild;
  final bool hasChild;
  final bool stretches;
  final double fontSize;
  final VisualDensity? visualDensity;
  final String? storageKey;
  final ScrollController? scrollController;
  final double scale;

  const SqaSegmentedButton({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
    this.showSelectedIcon = false,
    this.padding,
    this.isChild = false,
    this.hasChild = false,
    this.stretches = true,
    this.fontSize = 12,
    this.visualDensity,
    this.storageKey,
    this.scrollController,
    this.scale = 1.0,
    this.minScale = 1.0,
  });

  final double minScale;

  @override
  State<SqaSegmentedButton<T>> createState() => _SqaSegmentedButtonState<T>();
}

class _SqaSegmentedButtonState<T> extends State<SqaSegmentedButton<T>> {
  late final ScrollController _scrollController;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected();
    });
  }

  @override
  void didUpdateWidget(SqaSegmentedButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected ||
        widget.segments.length != oldWidget.segments.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelected();
      });
    }
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.maxScrollExtent <= 0) return;

    if (widget.selected.isEmpty) return;
    final selectedValue = widget.selected.first;
    final index = widget.segments.indexWhere((s) => s.value == selectedValue);
    if (index == -1) return;

    final N = widget.segments.length;
    final viewportDimension = position.viewportDimension;
    final totalWidth = position.maxScrollExtent + viewportDimension;

    final buttonCenter = totalWidth * (index + 0.5) / N;
    final targetOffset = buttonCenter - (viewportDimension / 2);

    final clampedOffset = targetOffset.clamp(0.0, position.maxScrollExtent);

    _scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // We only use expandedInsets if the segments are few enough to fit on screen.
    // This prevents the "infinite width" crash in SingleChildScrollView and
    // ensures the edge-to-edge look for standard 2-3 segment controls.
    final bool shouldStretch = widget.stretches && widget.segments.length <= 3;

    final segmentedButton = SegmentedButton<T>(
      segments: widget.segments,
      selected: widget.selected,
      onSelectionChanged: widget.onSelectionChanged,
      showSelectedIcon: widget.showSelectedIcon,
      expandedInsets: shouldStretch ? EdgeInsets.zero : null,
      style: SegmentedButton.styleFrom(
        visualDensity: widget.visualDensity ?? VisualDensity.compact,
        textStyle: TextStyle(
          fontSize: widget.fontSize,
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
        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
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

    Widget result;
    if (shouldStretch) {
      result = Padding(padding: effectivePadding, child: segmentedButton);
    } else {
      result = Padding(
        padding: effectivePadding,
        child: SqaFadeWrapper(
          axis: Axis.horizontal,
          child: ScrollConfiguration(
            behavior: const SqaMouseDragScrollBehavior(),
            child: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  // Consume wheel signals
                }
              },
              child: SingleChildScrollView(
                key: widget.storageKey != null
                    ? PageStorageKey<String>(widget.storageKey!)
                    : null,
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                child: segmentedButton,
              ),
            ),
          ),
        ),
      );
    }

    if (widget.scale != 1.0 || widget.minScale != 1.0) {
      return Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 32.0 * widget.minScale),
          child: SizedBox(
            height: 32.0 * widget.scale,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: result,
            ),
          ),
        ),
      );
    }

    return result;
  }
}

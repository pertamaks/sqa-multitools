import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'sqa_toast.dart';
import 'sqa_styles.dart';

class SqaField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final String? initialValue;
  final IconData? icon;
  final bool isMonospace;
  final bool readOnly;
  final bool isMultiline;
  final int? maxLines;
  final int? minLines;
  final double? maxHeight;
  final Widget? prefix;
  final ScrollController? horizontalScrollController;
  final bool wrap;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final bool showCopyButton;
  final Widget? trailing;
  final int? collapsedMaxLines;
  final bool showLineNumbers;

  const SqaField({
    super.key,
    required this.label,
    this.controller,
    this.initialValue,
    this.icon,
    this.isMonospace = false,
    this.readOnly = false,
    this.isMultiline = false,
    this.maxLines,
    this.minLines,
    this.maxHeight,
    this.prefix,
    this.horizontalScrollController,
    this.wrap = true,
    this.onChanged,
    this.hintText,
    this.showCopyButton = true,
    this.trailing,
    this.collapsedMaxLines,
    this.showLineNumbers = false,
  });

  @override
  State<SqaField> createState() => _SqaFieldState();
}

class _SqaFieldState extends State<SqaField> {
  late TextEditingController _internalController;
  bool _isExpanded = false;
  final GlobalKey _containerKey = GlobalKey();
  final ValueNotifier<double> _stickyTopNotifier = ValueNotifier<double>(4.0);
  late ScrollController _verticalScrollController;
  late ScrollController _gutterScrollController;

  int get _lineCount => _internalController.text.split('\n').length;

  void _updateStickyOffset() {
    if (!widget.showCopyButton) return;

    final RenderBox? containerBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (containerBox == null || !containerBox.hasSize) return;

    try {
      final scrollable = Scrollable.of(_containerKey.currentContext!);
      final viewportBox = scrollable.context.findRenderObject() as RenderBox?;
      if (viewportBox == null) return;

      // Get position of field's top relative to viewport's top
      final fieldOffsetInViewport = containerBox.localToGlobal(
        Offset.zero,
        ancestor: viewportBox,
      );

      final bool isActuallyShowingFooter =
          widget.collapsedMaxLines != null &&
          _lineCount > widget.collapsedMaxLines!;

      final fieldTop = fieldOffsetInViewport.dy;
      final fieldHeight = containerBox.size.height;
      const buttonHeight = 32.0;
      const padding = 4.0;

      double nextStickyTop = padding;

      if (fieldTop < 0 && _isExpanded) {
        // Field top is off-screen (above). Slide button down.
        // But stay 4px above the bottom edge at most.
        final footerHeight = (isActuallyShowingFooter) ? 40.0 : 0.0;
        nextStickyTop = (-fieldTop + padding).clamp(
          padding,
          fieldHeight - buttonHeight - padding - footerHeight,
        );
      }

      if (_stickyTopNotifier.value != nextStickyTop) {
        _stickyTopNotifier.value = nextStickyTop;
      }
    } catch (_) {
      // Scrollable not found or other coordinate error, fallback to top
      if (_stickyTopNotifier.value != 4.0) {
        _stickyTopNotifier.value = 4.0;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _internalController =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _internalController.addListener(_onControllerChanged);
    _verticalScrollController = ScrollController();
    _gutterScrollController = ScrollController();

    _verticalScrollController.addListener(_syncGutterScroll);
  }

  void _syncGutterScroll() {
    if (_gutterScrollController.hasClients &&
        _verticalScrollController.hasClients) {
      if (_gutterScrollController.offset != _verticalScrollController.offset) {
        _gutterScrollController.jumpTo(_verticalScrollController.offset);
      }
    }
  }

  void _onControllerChanged() {
    if (widget.collapsedMaxLines != null) {
      // Rebuild to update hidden line count footer
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant SqaField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null &&
        widget.controller != oldWidget.controller) {
      _internalController.removeListener(_onControllerChanged);
      _internalController = widget.controller!;
      _internalController.addListener(_onControllerChanged);
    } else if (widget.initialValue != null &&
        widget.initialValue != oldWidget.initialValue) {
      _internalController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_updateStickyOffset);
    _internalController.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _verticalScrollController.removeListener(_syncGutterScroll);
    _verticalScrollController.dispose();
    _gutterScrollController.dispose();
    _stickyTopNotifier.dispose();
    super.dispose();
  }

  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_updateStickyOffset);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_updateStickyOffset);

    // Initial check after build
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateStickyOffset());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Line height logic for height snapping
    const fontSize = 13.0;
    const fontHeight = 1.3;
    const vPadding = 12.0 * 2; // Total vertical padding of TextField
    final singleLineHeight = fontSize * fontHeight;

    // Calculate maximum height for the container
    double? effectiveMaxHeight = widget.maxHeight;
    bool showFooter = false;

    if (widget.collapsedMaxLines != null &&
        _lineCount > widget.collapsedMaxLines!) {
      showFooter = true;
      if (!_isExpanded) {
        // Force the container to snap to exactly the collapsed size
        effectiveMaxHeight =
            (widget.collapsedMaxLines! * singleLineHeight) + vPadding;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 14, color: colorScheme.primary),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          constraints: effectiveMaxHeight != null
              ? BoxConstraints(maxHeight: effectiveMaxHeight)
              : null,
          key: _containerKey,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: SqaStyles.radiusLarge,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: ClipRRect(
            borderRadius: SqaStyles.radiusLarge,
            child: Stack(
              children: [
                // 1. Gutter Divider Line (Edge-to-Edge)
                if (widget.showLineNumbers)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),

                // 2. Main Content (Numbers + Text)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: (showFooter && _isExpanded) ? 40 : 0,
                    right: widget.showCopyButton ? 44 : 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: widget.isMultiline
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      if (widget.prefix != null) widget.prefix!,
                      if (widget.showLineNumbers) _buildNativeGutter(theme),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final textField = TextField(
                              controller: _internalController,
                              readOnly: widget.readOnly,
                              onChanged: widget.onChanged,
                              scrollPhysics:
                                  (widget.collapsedMaxLines != null &&
                                      !_isExpanded)
                                  ? const NeverScrollableScrollPhysics()
                                  : null,
                              maxLines:
                                  (widget.collapsedMaxLines != null &&
                                      !_isExpanded)
                                  ? widget.collapsedMaxLines
                                  : (widget.isMultiline ? widget.maxLines : 1),
                              minLines: widget.minLines ?? 1,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: widget.isMonospace
                                    ? 'monospace'
                                    : null,
                                fontSize: fontSize,
                                height: fontHeight,
                              ),
                              decoration: InputDecoration(
                                hintText: widget.hintText,
                                hintStyle: TextStyle(
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.fromLTRB(
                                  widget.showLineNumbers ? 8 : 16,
                                  12,
                                  16, // Standard horizontal padding
                                  12,
                                ),
                              ),
                              scrollController: _verticalScrollController,
                            );

                            final scrollConfiguration = ScrollConfiguration(
                              // Use custom behavior to hide scrollbars when collapsed
                              behavior:
                                  (widget.collapsedMaxLines != null &&
                                      !_isExpanded)
                                  ? const _NoScrollbarBehavior()
                                  : ScrollConfiguration.of(context),
                              child: textField,
                            );

                            if (widget.horizontalScrollController != null &&
                                !widget.wrap) {
                              return Scrollbar(
                                controller: widget.horizontalScrollController,
                                thumbVisibility: true,
                                thickness: 4.0,
                                radius: const Radius.circular(2),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  controller: widget.horizontalScrollController,
                                  child: IntrinsicWidth(
                                    child: scrollConfiguration,
                                  ),
                                ),
                              );
                            }
                            return scrollConfiguration;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Expansion Footer (Sticky to bottom)
                if (showFooter)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildExpansionFooter(theme),
                  ),

                // 4. Sticky Copy Button
                if (widget.showCopyButton)
                  ValueListenableBuilder<double>(
                    valueListenable: _stickyTopNotifier,
                    builder: (context, stickyTop, child) {
                      return Positioned(
                        top: stickyTop,
                        right: 4,
                        child: child!,
                      );
                    },
                    child: IconButton(
                      icon: const Icon(Symbols.content_copy, size: 16),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: _internalController.text),
                        );
                        SqaToast.show(context, 'Copied to clipboard');
                      },
                      tooltip: 'Copy to clipboard',
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNativeGutter(ThemeData theme) {
    return ListenableBuilder(
      listenable: _internalController,
      builder: (context, _) {
        final lineCount = '\n'.allMatches(_internalController.text).length + 1;
        const fontSize = 13.0;
        const fontHeight = 1.3;
        final singleLineHeight = fontSize * fontHeight;

        return Container(
          width: 40,
          padding: const EdgeInsets.only(top: 12),
          child: ScrollConfiguration(
            behavior: const _NoScrollbarBehavior(),
            child: SingleChildScrollView(
              controller: _gutterScrollController,
              physics: const NeverScrollableScrollPhysics(), // Sync only
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(lineCount, (index) {
                  return SizedBox(
                    height: singleLineHeight,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: fontSize,
                          height: fontHeight,
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpansionFooter(ThemeData theme) {
    final hiddenLines = _lineCount - widget.collapsedMaxLines!;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
          if (!_isExpanded) {
            _stickyTopNotifier.value = 4.0;
          }
        });
      },
      child: Container(
        width: double.infinity,
        height: _isExpanded ? 40 : 60, // Taller when collapsed for gradient
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface.withValues(alpha: 0),
              theme.colorScheme.surface.withValues(
                alpha: _isExpanded ? 0.8 : 0.6,
              ),
              theme.colorScheme.surface,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isExpanded ? Symbols.expand_less : Symbols.expand_more,
              size: 14,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              _isExpanded
                  ? 'SHOW LESS'
                  : '+ $hiddenLines MORE LINES... (SHOW ALL)',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                letterSpacing: 1.1,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Return original child without wrapping in a scrollbar
    return child;
  }
}

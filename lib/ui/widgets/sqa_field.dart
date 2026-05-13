import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'sqa_toast.dart';
import 'sqa_styles.dart';
import 'sqa_hover_icon_button.dart';

class SqaField extends StatefulWidget {
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
    this.isTransparent = false,
    this.showLabel = true,
    this.undoController,
    this.onTapOutside,
    this.fontSize = 13.0,
    this.lineHeight = 1.5,
    this.gutterFontSize,
    this.showSentenceCaseButton = false,
    this.autofocus = false,
    this.fontWeight,
    this.color,
    this.onSubmitted,
    this.focusNode,
    this.isSelectable = true,
    this.expands = false,
  });

  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final UndoHistoryController? undoController;
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
  final ValueChanged<String>? onSubmitted;
  final TapRegionCallback? onTapOutside;
  final String? hintText;
  final bool showCopyButton;
  final Widget? trailing;
  final FontWeight? fontWeight;
  final Color? color;
  final int? collapsedMaxLines;
  final bool showLineNumbers;
  final bool isTransparent;
  final bool showLabel;
  final double fontSize;
  final double lineHeight;
  final double? gutterFontSize;
  final bool showSentenceCaseButton;
  final bool autofocus;
  final bool isSelectable;
  final bool expands;

  @override
  State<SqaField> createState() => _SqaFieldState();

  static String toSentenceCase(String text) {
    if (text.isEmpty) return text;

    final RegExp sentencePattern = RegExp(r'([^.!?]+[.!?]*\s*)');
    final matches = sentencePattern.allMatches(text);

    if (matches.isEmpty) {
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }

    String result = '';
    for (final match in matches) {
      final sentence = match.group(0)!;
      if (sentence.trim().isEmpty) {
        result += sentence;
        continue;
      }

      int firstLetterIdx = -1;
      for (int i = 0; i < sentence.length; i++) {
        if (RegExp(r'[a-zA-Z]').hasMatch(sentence[i])) {
          firstLetterIdx = i;
          break;
        }
      }

      if (firstLetterIdx == -1) {
        result += sentence;
      } else {
        result +=
            sentence.substring(0, firstLetterIdx) +
            sentence[firstLetterIdx].toUpperCase() +
            sentence.substring(firstLetterIdx + 1).toLowerCase();
      }
    }
    return result;
  }
}

class _SqaFieldState extends State<SqaField> {
  late TextEditingController _internalController;
  bool _isExpanded = false;
  final GlobalKey _containerKey = GlobalKey();
  final ValueNotifier<double> _stickyTopNotifier = ValueNotifier<double>(0.0);
  late ScrollController _verticalScrollController;
  late ScrollController _internalHorizontalScrollController;
  bool _isHovered = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  int get _lineCount => _internalController.text.split('\n').length;

  void _updateStickyOffset() {
    if (!widget.showCopyButton && !widget.showSentenceCaseButton) return;

    final RenderBox? containerBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (containerBox == null || !containerBox.hasSize) return;

    try {
      final scrollable = Scrollable.of(_containerKey.currentContext!);
      final viewportBox = scrollable.context.findRenderObject() as RenderBox?;
      if (viewportBox == null) return;

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
      const padding = 0.0;
      double nextStickyTop = padding;

      if (fieldTop < 0 && _isExpanded) {
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
      if (_stickyTopNotifier.value != 0.0) {
        _stickyTopNotifier.value = 0.0;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _internalController =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _lastLineCount = _internalController.text.split('\n').length;
    _internalController.addListener(_onControllerChanged);
    _verticalScrollController = ScrollController();
    _internalHorizontalScrollController = ScrollController();

    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.readOnly) {
      _focusNode.canRequestFocus = false;
    }
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _scrollPosition?.removeListener(_updateStickyOffset);
    _internalController.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _verticalScrollController.dispose();
    _internalHorizontalScrollController.dispose();
    _stickyTopNotifier.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  int _lastLineCount = 0;

  void _onControllerChanged() {
    final currentLineCount = _lineCount;
    if (widget.collapsedMaxLines != null) {
      final lineDelta = currentLineCount - _lastLineCount;

      if (_isFocused &&
          !_isExpanded &&
          lineDelta == 1 &&
          currentLineCount > widget.collapsedMaxLines!) {
        setState(() {
          _isExpanded = true;
        });
      } else {
        setState(() {});
      }
    }
    _lastLineCount = currentLineCount;
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
        widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _internalController.text) {
      _internalController.text = widget.initialValue!;
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
  }

  ScrollPosition? _scrollPosition;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollPosition?.removeListener(_updateStickyOffset);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_updateStickyOffset);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateStickyOffset());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final fontSize = widget.fontSize;
    final fontHeight = widget.lineHeight;
    const vPadding = 12.0 * 2;
    final singleLineHeight = fontSize * fontHeight;

    double? effectiveMaxHeight = widget.maxHeight;
    bool showFooter = false;

    if (widget.collapsedMaxLines != null &&
        _lineCount > widget.collapsedMaxLines!) {
      showFooter = true;
      if (!_isExpanded) {
        effectiveMaxHeight =
            (widget.collapsedMaxLines! * singleLineHeight) + vPadding;
      }
    }

    final content = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        width: double.infinity,
        constraints: effectiveMaxHeight != null
            ? BoxConstraints(maxHeight: effectiveMaxHeight)
            : null,
        child: Container(
          key: _containerKey,
          decoration: BoxDecoration(
            color: widget.isTransparent
                ? Colors.transparent
                : (!widget.readOnly && _isFocused
                    ? colorScheme.primaryContainer.withValues(alpha: 0.15)
                    : (!widget.readOnly && _isHovered
                        ? colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.1,
                          )
                        : Colors.transparent)),
            borderRadius: SqaStyles.radiusLarge,
            border: Border.all(
              color: widget.isTransparent
                  ? Colors.transparent
                  : (!widget.readOnly && _isFocused
                      ? colorScheme.primary.withValues(alpha: 0.3)
                      : (!widget.readOnly && _isHovered
                          ? colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            )
                          : colorScheme.outlineVariant.withValues(
                              alpha: 0.0,
                            ))),
            ),
            boxShadow: !widget.readOnly && _isFocused
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.05),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: SqaStyles.radiusLarge,
            child: Stack(
              children: [
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
                            color: _isFocused
                                ? colorScheme.primary.withValues(alpha: 0.4)
                                : colorScheme.outlineVariant.withValues(
                                    alpha: 0.15,
                                  ),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: (showFooter && _isExpanded) ? 40 : 0,
                    right: (widget.showCopyButton ||
                            widget.showSentenceCaseButton ||
                            widget.trailing != null)
                        ? 44
                        : 0,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        crossAxisAlignment: widget.isMultiline
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.center,
                        children: [
                          if (widget.showLineNumbers)
                            _buildNativeGutter(theme, constraints.maxWidth),
                          Expanded(
                            child: _buildTextField(context, theme),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                if (showFooter)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildExpansionFooter(theme),
                  ),
                if (widget.showCopyButton || widget.showSentenceCaseButton)
                  ValueListenableBuilder<double>(
                    valueListenable: _stickyTopNotifier,
                    builder: (context, stickyTop, child) {
                      return Positioned(
                        top: stickyTop,
                        right: 4,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.showSentenceCaseButton)
                              SqaHoverIconButton(
                                icon: Symbols.text_fields,
                                onPressed: () {
                                  final text = _internalController.text;
                                  if (text.isEmpty) return;
                                  final converted = SqaField.toSentenceCase(
                                    text,
                                  );
                                  _internalController.text = converted;
                                  if (widget.onChanged != null) {
                                    widget.onChanged!(converted);
                                  }
                                },
                                tooltip: 'Convert to Sentence case',
                              ),
                            if (widget.showCopyButton)
                              SqaHoverIconButton(
                                icon: Symbols.content_copy,
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text: _internalController.text,
                                    ),
                                  );
                                  SqaToast.show(
                                    context,
                                    'Copied to clipboard',
                                  );
                                },
                                tooltip: 'Copy to clipboard',
                              ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: widget.expands ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
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
                    widget.label,
                    style: SqaTextStyles.labelBold(context).copyWith(
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
        ],
        if (widget.expands) Expanded(child: content) else content,
      ],
    );
  }

  Widget _buildTextField(BuildContext context, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final fontSize = widget.fontSize;
    final fontHeight = widget.lineHeight;

    final textField = TextField(
      controller: _internalController,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      scrollController: _verticalScrollController,
      scrollPhysics: (widget.collapsedMaxLines != null && !_isExpanded)
          ? const NeverScrollableScrollPhysics()
          : null,
      maxLines: widget.expands
          ? null
          : ((widget.collapsedMaxLines != null && !_isExpanded)
              ? widget.collapsedMaxLines
              : (widget.isMultiline ? widget.maxLines : 1)),
      minLines: widget.expands ? null : (widget.minLines ?? 1),
      expands: widget.expands,
      style: (widget.isMonospace
              ? SqaTextStyles.mono(context)
              : SqaTextStyles.body(context))
          .copyWith(
        fontSize: fontSize,
        height: fontHeight,
        color: widget.color ?? colorScheme.onSurface,
        fontWeight: widget.fontWeight,
      ),
      strutStyle: StrutStyle(
        fontSize: fontSize,
        height: fontHeight,
        forceStrutHeight: true,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      decoration: InputDecoration(
        filled: false,
        isDense: false,
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.3),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: SqaSpacing.small,
        ),
      ),
      undoController: widget.undoController,
      onTapOutside: widget.onTapOutside,
      enableInteractiveSelection: widget.isSelectable,
      textAlignVertical: TextAlignVertical.top,
    );

    if (!widget.wrap) {
      final hController = widget.horizontalScrollController ??
          _internalHorizontalScrollController;

      return Scrollbar(
        controller: hController,
        thumbVisibility: true,
        thickness: 4.0,
        radius: const Radius.circular(2),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: hController,
          child: IntrinsicWidth(
            child: textField,
          ),
        ),
      );
    }
    return textField;
  }

  Widget _buildNativeGutter(ThemeData theme, double totalWidth) {
    return ListenableBuilder(
      listenable: _internalController,
      builder: (context, _) {
        final text = _internalController.text;
        final logicalLines = text.split('\n');
        final fontSize = widget.fontSize;
        final fontHeight = widget.lineHeight;
        final gFontSize = widget.gutterFontSize ?? (fontSize * 0.9);

        final textStyle = (widget.isMonospace
                ? SqaTextStyles.mono(context)
                : SqaTextStyles.body(context))
            .copyWith(
          fontSize: fontSize,
          height: fontHeight,
        );

        String numbers = '';
        for (int i = 0; i < logicalLines.length; i++) {
          numbers += '${i + 1}';
          if (widget.wrap) {
            final tp = TextPainter(
              text: TextSpan(text: logicalLines[i], style: textStyle),
              textDirection: TextDirection.ltr,
            );
            // Ensure maxWidth is never negative
            tp.layout(maxWidth: ((totalWidth - 40) - 32).clamp(0, double.infinity));
            final visualLines = tp.computeLineMetrics().length;
            final effectiveLines = visualLines < 1 ? 1 : visualLines;
            for (int j = 0; j < effectiveLines; j++) {
              numbers += '\n';
            }
          } else {
            numbers += '\n';
          }
        }

        return Container(
          width: 40,
          child: InputDecorator(
            decoration: const InputDecoration(
              filled: false,
              isDense: false,
              contentPadding: EdgeInsets.symmetric(
                vertical: SqaSpacing.small,
              ),
              border: InputBorder.none,
            ),
            child: ClipRect(
              child: ListenableBuilder(
                listenable: _verticalScrollController,
                builder: (context, child) {
                  double offset = 0;
                  if (_verticalScrollController.hasClients) {
                    offset = _verticalScrollController.offset;
                  }
                  
                  return OverflowBox(
                    maxHeight: double.infinity,
                    alignment: Alignment.topLeft,
                    child: Transform.translate(
                      offset: Offset(0, -offset),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          numbers,
                          style: SqaTextStyles.mono(context).copyWith(
                            fontSize: gFontSize,
                            height: (fontSize * fontHeight) / gFontSize,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                          textAlign: TextAlign.right,
                          strutStyle: StrutStyle(
                            fontSize: fontSize,
                            height: fontHeight,
                            forceStrutHeight: true,
                            leadingDistribution: TextLeadingDistribution.even,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpansionFooter(ThemeData theme) {
    final hiddenLines = _lineCount - widget.collapsedMaxLines!;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
          height: _isExpanded ? 40 : 60,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                      ? 'Show Less'
                      : '+ $hiddenLines More Lines... (Show All)',
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
    return child;
  }
}

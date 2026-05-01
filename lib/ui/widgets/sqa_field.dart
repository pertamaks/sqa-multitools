import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:google_fonts/google_fonts.dart';
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
  });

  final String label;
  final TextEditingController? controller;
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
  final TapRegionCallback? onTapOutside;
  final String? hintText;
  final bool showCopyButton;
  final Widget? trailing;
  final int? collapsedMaxLines;
  final bool showLineNumbers;
  final bool isTransparent;
  final bool showLabel;
  final double fontSize;
  final double lineHeight;
  final double? gutterFontSize;
  final bool showSentenceCaseButton;
  final bool autofocus;

  @override
  State<SqaField> createState() => _SqaFieldState();

  static String toSentenceCase(String text) {
    if (text.isEmpty) return text;

    // Split by sentence boundaries (., !, ?) followed by whitespace or end of string
    final RegExp sentencePattern = RegExp(r'([^.!?]+[.!?]*\s*)');
    final matches = sentencePattern.allMatches(text);

    if (matches.isEmpty) {
      // Just one sentence/word
      return text[0].toUpperCase() + text.substring(1).toLowerCase();
    }

    String result = '';
    for (final match in matches) {
      final sentence = match.group(0)!;
      if (sentence.trim().isEmpty) {
        result += sentence;
        continue;
      }

      // Find first letter
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
  late ScrollController _gutterScrollController;
  late ScrollController _internalHorizontalScrollController;
  bool _isHovered = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

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
      const padding = 0.0;
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
    _gutterScrollController = ScrollController();
    _internalHorizontalScrollController = ScrollController();

    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });

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

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollPosition?.removeListener(_updateStickyOffset);
    _internalController.removeListener(_onControllerChanged);
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _verticalScrollController.removeListener(_syncGutterScroll);
    _verticalScrollController.dispose();
    _gutterScrollController.dispose();
    _internalHorizontalScrollController.dispose();
    _stickyTopNotifier.dispose();
    super.dispose();
  }

  int _lastLineCount = 0;

  void _onControllerChanged() {
    final currentLineCount = _lineCount;
    if (widget.collapsedMaxLines != null) {
      // Auto-expand ONLY if the user is manually typing (adding 1 line at a time)
      // If they paste a large block (delta > 1), we keep it collapsed for stability.
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
        widget.initialValue != oldWidget.initialValue) {
      _internalController.text = widget.initialValue!;
    }
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
    final fontSize = widget.fontSize;
    final fontHeight = widget.lineHeight;
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
        ],
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            width: double.infinity,
            constraints: effectiveMaxHeight != null
                ? BoxConstraints(maxHeight: effectiveMaxHeight)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              key: _containerKey,
              decoration: BoxDecoration(
                color: widget.isTransparent
                    ? Colors.transparent
                    : (_isFocused
                          ? colorScheme.primaryContainer.withValues(alpha: 0.15)
                          : (_isHovered
                                ? colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.1)
                                : Colors.transparent)),
                borderRadius: SqaStyles.radiusLarge,
                border: Border.all(
                  color: widget.isTransparent
                      ? Colors.transparent
                      : (_isFocused
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : (_isHovered
                                  ? colorScheme.outlineVariant.withValues(
                                      alpha: 0.3,
                                    )
                                  : colorScheme.outlineVariant.withValues(
                                      alpha: 0.0,
                                    ))),
                ),
                boxShadow: _isFocused
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

                    // 2. Main Content (Numbers + Text)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: (showFooter && _isExpanded) ? 40 : 0,
                        right: widget.showCopyButton ? 44 : 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
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
                                  focusNode: _focusNode,
                                  autofocus: widget.autofocus,
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
                                      : (widget.isMultiline
                                            ? widget.maxLines
                                            : 1),
                                  minLines: widget.minLines ?? 1,
                                  style:
                                      (widget.isMonospace
                                              ? GoogleFonts.jetBrainsMono()
                                              : theme.textTheme.bodyMedium)
                                          ?.copyWith(
                                            fontSize: fontSize,
                                            height: fontHeight,
                                            color: colorScheme.onSurface,
                                          ),
                                  strutStyle: StrutStyle(
                                    fontSize: fontSize,
                                    height: fontHeight,
                                    leadingDistribution:
                                        TextLeadingDistribution.even,
                                  ),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: widget.hintText,
                                    hintStyle: TextStyle(
                                      color: colorScheme.onSurface.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                  scrollController: _verticalScrollController,
                                  undoController: widget.undoController,
                                  onTapOutside: widget.onTapOutside,
                                  textAlignVertical: TextAlignVertical.top,
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

                                if (!widget.wrap) {
                                  final hController =
                                      widget.horizontalScrollController ??
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

                    // 4. Sticky Action Buttons
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
        ),
      ],
    );
  }

  Widget _buildNativeGutter(ThemeData theme) {
    return ListenableBuilder(
      listenable: _internalController,
      builder: (context, _) {
        final lineCount = '\n'.allMatches(_internalController.text).length + 1;
        final fontSize = widget.fontSize;
        final fontHeight = widget.lineHeight;
        final gFontSize = widget.gutterFontSize ?? (fontSize * 0.9);
        final numbers = List.generate(lineCount, (i) => '${i + 1}').join('\n');

        return Container(
          width: 40,
          padding: const EdgeInsets.only(top: 6.5),
          child: ScrollConfiguration(
            behavior: const _NoScrollbarBehavior(),
            child: SingleChildScrollView(
              controller: _gutterScrollController,
              physics: const NeverScrollableScrollPhysics(), // Sync only
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  numbers,
                  style: GoogleFonts.jetBrainsMono().copyWith(
                    fontSize: gFontSize,
                    height: (fontSize * fontHeight) / gFontSize,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  strutStyle: StrutStyle(
                    fontSize: fontSize,
                    height: fontHeight,
                    forceStrutHeight: true,
                    leadingDistribution: TextLeadingDistribution.even,
                  ),
                  textAlign: TextAlign.right,
                ),
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

import 'dart:async';
import 'dart:ffi' hide Size;
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/models/sqa_coachmark_step.dart';
import 'sqa_design_tokens.dart';
import 'sqa_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIN32 REPAINT HELPER
// ─────────────────────────────────────────────────────────────────────────────
// On Flutter Windows, after a long async chain the DWM compositor enters an
// idle state and won't present new frames until an external OS event (e.g. a
// focus change) sends WM_PAINT. We replicate that trigger programmatically by
// calling InvalidateRect + UpdateWindow on the foreground HWND via FFI.

typedef _GetForegroundWindowC = IntPtr Function();
typedef _GetForegroundWindow = int Function();
typedef _InvalidateRectC = Int32 Function(IntPtr hwnd, Pointer<Void> lpRect, Int32 bErase);
typedef _InvalidateRect = int Function(int hwnd, Pointer<Void> lpRect, int bErase);
typedef _UpdateWindowC = Int32 Function(IntPtr hwnd);
typedef _UpdateWindow = int Function(int hwnd);

Future<void> _forceWindowsRepaint() async {
  if (!Platform.isWindows) return;
  try {
    // Only attempt to force a repaint if our app window is the focused one.
    // This prevents inadvertently forcing a repaint on another application.
    final isFocused = await windowManager.isFocused();
    if (!isFocused) return;

    final user32 = DynamicLibrary.open('user32.dll');
    final getForegroundWindow =
        user32.lookupFunction<_GetForegroundWindowC, _GetForegroundWindow>('GetForegroundWindow');
    final invalidateRect =
        user32.lookupFunction<_InvalidateRectC, _InvalidateRect>('InvalidateRect');
    final updateWindow =
        user32.lookupFunction<_UpdateWindowC, _UpdateWindow>('UpdateWindow');
        
    final hwnd = getForegroundWindow();
    if (hwnd != 0) {
      invalidateRect(hwnd, nullptr, 0); // Invalidate entire client area
      updateWindow(hwnd);               // Force synchronous WM_PAINT dispatch
    }
  } catch (_) {
    // Silently ignore if FFI fails (non-Windows builds)
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC API
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps a widget to make it a coachmark target.
///
/// The [layerLink] is used by the overlay to position the spotlight.
/// Register the [layerLink] and [targetKey] pair with your coachmark step list.
class SqaCoachmarkTarget extends StatelessWidget {
  final GlobalKey targetKey;
  final Widget child;

  const SqaCoachmarkTarget({
    required this.targetKey,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: targetKey, child: child);
  }
}

/// Controls a coachmark tour for a set of [SqaCoachmarkStep]s.
///
/// Call [SqaCoachmarkController.show] to attach the tour overlay to a given
/// [BuildContext]. Call [dismiss] to close it early.
class SqaCoachmarkController {
  final List<SqaCoachmarkStep> steps;
  final VoidCallback? onFinish;
  final VoidCallback? onSkip;

  OverlayEntry? _overlayEntry;
  _SqaCoachmarkOverlayState? _overlayState;

  SqaCoachmarkController({
    required this.steps,
    this.onFinish,
    this.onSkip,
  });

  /// Inserts the coachmark overlay into the [context]'s [Overlay].
  void show(BuildContext context) {
    if (steps.isEmpty) return;
    _overlayEntry = OverlayEntry(
      builder: (_) => _SqaCoachmarkOverlay(
        controller: this,
        steps: steps,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    // Kick the state machine after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlayState?._goToStep(0);
    });
  }

  /// Programmatically advances to the next step.
  void next() => _overlayState?._next();

  /// Programmatically goes back one step.
  void previous() => _overlayState?._previous();

  /// Dismisses the overlay entirely (marks as "skipped").
  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    onSkip?.call();
  }

  void _finish() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    onFinish?.call();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// OVERLAY WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _SqaCoachmarkOverlay extends ConsumerStatefulWidget {
  final SqaCoachmarkController controller;
  final List<SqaCoachmarkStep> steps;

  const _SqaCoachmarkOverlay({
    required this.controller,
    required this.steps,
  });

  @override
  ConsumerState<_SqaCoachmarkOverlay> createState() => _SqaCoachmarkOverlayState();
}

class _SqaCoachmarkOverlayState extends ConsumerState<_SqaCoachmarkOverlay>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Rect? _targetRect;
  bool _isTransitioning = false;

  // Card fade animation
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller._overlayState = this;

    _fadeController = AnimationController(
      vsync: this,
      duration: SqaTokens.durationNormal,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: SqaTokens.curveDecelerate,
    );

    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      widget.controller.dismiss();
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _fadeController.dispose();
    widget.controller._overlayState = null;
    super.dispose();
  }

  // ── Step Navigation ───────────────────────────────────────────────────────

  Future<void> _goToStep(int index) async {
    if (index < 0 || index >= widget.steps.length) return;
    if (_isTransitioning) return;
    _isTransitioning = true;

    // Fade card out
    await _fadeController.reverse();

    setState(() {
      _currentIndex = index;
      _targetRect = null;
    });

    final step = widget.steps[index];

    // Run the beforeStepAction (e.g. scroll, tab switch, navigate)
    if (step.beforeStepAction != null) {
      await step.beforeStepAction!(ref);
    } else {
      final targetContext = step.targetKey.currentContext;
      if (targetContext != null) {
        try {
          await Scrollable.ensureVisible(
            targetContext,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.5,
          );
        } catch (_) {
          // Ignore if there's no Scrollable ancestor or it fails
        }
      }
    }

    // Wait for the Flutter frame to settle after any UI changes
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      completer.complete();
    });
    await completer.future;

    // Small additional delay for animations (scroll/tab) to finish visually
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Compute target bounding box (with retries up to 1 second if widget is still laying out/animating)
    Rect? rect;
    final startTime = DateTime.now();
    while (DateTime.now().difference(startTime).inMilliseconds < 1000) {
      if (!mounted) {
        _isTransitioning = false;
        return;
      }
      rect = _getTargetRect(step.targetKey);
      if (rect != null) break;

      final retryCompleter = Completer<void>();
      WidgetsBinding.instance.addPostFrameCallback((_) => retryCompleter.complete());
      WidgetsBinding.instance.scheduleFrame();
      await retryCompleter.future;
    }

    if (!mounted) {
      _isTransitioning = false;
      return;
    }

    // Fallback: If rect is STILL null (widget unmounted/offscreen), fallback to a zero-size
    // center rect so the card ALWAYS renders in the middle of the screen rather than
    // trapping the user on a blank dimmed screen.
    final effectiveRect = rect ?? Rect.fromCenter(
      center: Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 3),
      width: 0,
      height: 0,
    );

    // Commit the rect so the card enters the widget tree.
    setState(() => _targetRect = effectiveRect);

    // On Flutter Windows the compositor goes idle after long async chains and
    // won't present the new frame until WM_PAINT arrives (the same trigger
    // that an Alt-Tab / focus-change normally provides). Replicate it via FFI.
    await _forceWindowsRepaint();

    // Additionally schedule a Flutter frame so the engine re-registers for
    // vsync and the post-frame callback below fires promptly.
    final cardShownCompleter = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => cardShownCompleter.complete());
    WidgetsBinding.instance.scheduleFrame();
    await cardShownCompleter.future;

    // Fade card in
    if (mounted) {
      await _fadeController.forward();
    }

    _isTransitioning = false;
  }

  Rect? _getTargetRect(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject == null) return null;
    final renderBox = renderObject as RenderBox;
    final overlayContext = Overlay.of(context).context;
    final overlayRenderBox = overlayContext.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlayRenderBox);
    return offset & renderBox.size;
  }

  void _next() {
    if (_currentIndex < widget.steps.length - 1) {
      _goToStep(_currentIndex + 1);
    } else {
      widget.controller._finish();
    }
  }

  void _previous() {
    if (_currentIndex > 0) {
      _goToStep(_currentIndex - 1);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_currentIndex];
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Scrim + Spotlight (Clickable to advance)
        GestureDetector(
          onTap: _next,
          behavior: HitTestBehavior.opaque,
          child: CustomPaint(
            size: size,
            painter: _SpotlightPainter(
              targetRect: _targetRect,
              scrimColor: Colors.black.withValues(alpha: 0.75),
              spotlightPadding: SqaTokens.spacingMedium,
              borderRadius: SqaTokens.radiusMedium,
              borderWidth: SqaTokens.borderWidthThick,
              borderColor: colorScheme.primary,
            ),
          ),
        ),



        // Tooltip card
        if (_targetRect != null)
          _CoachmarkCard(
            step: step,
            targetRect: _targetRect!,
            currentIndex: _currentIndex,
            totalSteps: widget.steps.length,
            fadeAnimation: _fadeAnimation,
            onNext: _next,
            onPrevious: _currentIndex > 0 ? _previous : null,
            onSkip: () => widget.controller.dismiss(),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SPOTLIGHT PAINTER
// ─────────────────────────────────────────────────────────────────────────────

class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final Color scrimColor;
  final double spotlightPadding;
  final double borderRadius;
  final double borderWidth;
  final Color borderColor;

  const _SpotlightPainter({
    required this.targetRect,
    required this.scrimColor,
    required this.spotlightPadding,
    required this.borderRadius,
    required this.borderWidth,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()..color = scrimColor;
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (targetRect == null || (targetRect!.width == 0 && targetRect!.height == 0)) {
      canvas.drawRect(fullRect, scrimPaint);
      return;
    }

    final paddedRect = targetRect!.inflate(spotlightPadding);
    final spotlightRRect = RRect.fromRectAndRadius(
      paddedRect,
      Radius.circular(borderRadius),
    );

    // Draw scrim with cutout
    final fullPath = Path()..addRect(fullRect);
    final spotlightPath = Path()..addRRect(spotlightRRect);
    final combined = Path.combine(
      PathOperation.difference,
      fullPath,
      spotlightPath,
    );
    canvas.drawPath(combined, scrimPaint);

    // Draw static highlight border box
    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawRRect(spotlightRRect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.targetRect != targetRect ||
      old.spotlightPadding != spotlightPadding ||
      old.borderWidth != borderWidth ||
      old.borderColor != borderColor;
}

// ─────────────────────────────────────────────────────────────────────────────
// COACHMARK CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CoachmarkCard extends StatelessWidget {
  final SqaCoachmarkStep step;
  final Rect targetRect;
  final int currentIndex;
  final int totalSteps;
  final Animation<double> fadeAnimation;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final VoidCallback onSkip;

  static const double _cardWidth = 280.0;
  static const double _cardMargin = 16.0;

  const _CoachmarkCard({
    required this.step,
    required this.targetRect,
    required this.currentIndex,
    required this.totalSteps,
    required this.fadeAnimation,
    required this.onNext,
    this.onPrevious,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenSize = MediaQuery.of(context).size;
    final position = _calculatePosition(screenSize);
    final isLast = currentIndex == totalSteps - 1;

    return Positioned(
      left: position.left,
      top: position.top,
      right: position.right,
      bottom: position.bottom,
      width: _cardWidth,
      child: Semantics(
        focused: true,
        explicitChildNodes: true,
        scopesRoute: true,
        child: FadeTransition(
          opacity: fadeAnimation,
        child: Material(
          color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: SqaTokens.borderRadiusLarge,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(SqaTokens.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SqaTokens.spacingSmall,
                        vertical: SqaTokens.spacingXXSmall,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: SqaTokens.borderRadiusSmall,
                      ),
                      child: Text(
                        '${currentIndex + 1} / $totalSteps',
                        style: GoogleFonts.dmSans(
                          fontSize: SqaTokens.fontSizeTiny,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    // Skip button
                    GestureDetector(
                      onTap: onSkip,
                      child: Semantics(
                        button: true,
                        label: 'Skip tutorial',
                        child: Padding(
                          padding: const EdgeInsets.all(
                            SqaTokens.spacingXXSmall,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Skip',
                                style: GoogleFonts.dmSans(
                                  fontSize: SqaTokens.fontSizeTiny,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: SqaTokens.spacingXXSmall),
                              Icon(
                                Symbols.close,
                                size: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SqaTokens.spacingMedium),

                // Title
                Text(
                  step.title,
                  style: GoogleFonts.dmSans(
                    fontSize: SqaTokens.fontSizeMedium,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: SqaTokens.spacingXSmall),

                // Description
                Text(
                  step.description,
                  style: GoogleFonts.dmSans(
                    fontSize: SqaTokens.fontSizeSmall,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: SqaTokens.spacingLarge),

                // Navigation buttons
                Row(
                  children: [
                    if (onPrevious != null) ...[
                      SqaButton.outlined(
                        label: 'Back',
                        icon: Symbols.arrow_back,
                        onPressed: onPrevious,
                      ),
                      const SizedBox(width: SqaTokens.spacingSmall),
                    ],
                    Expanded(
                      child: SqaButton.primary(
                        label: isLast ? 'Done' : 'Next',
                        icon: isLast ? Symbols.check : Symbols.arrow_forward,
                        onPressed: onNext,
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ), // Padding
          ), // Container
        ), // Material
        ), // FadeTransition
      ), // Semantics
    ); // Positioned
  }

  /// Calculates the position for the card so it stays on screen and
  /// respects the [step.contentAlign] preference.
  _CardPosition _calculatePosition(Size screenSize) {
    const padding = 12.0 + _cardMargin;
    const cardHeight = 250.0; // conservative estimate for fallback checks

    if (targetRect.width == 0 && targetRect.height == 0) {
      return _CardPosition(
        left: (screenSize.width - _cardWidth) / 2,
        top: (screenSize.height - cardHeight) / 2,
      );
    }

    double? left;
    double? top;
    double? right;
    double? bottom;

    switch (step.contentAlign) {
      case CoachmarkContentAlign.top:
        left = _clampHorizontal(targetRect.center.dx, screenSize.width);
        // Position card above the target. Clamp so card never goes off the top.
        final preferredBottom = screenSize.height - targetRect.top + padding;
        bottom = preferredBottom.clamp(
          _cardMargin,
          screenSize.height - cardHeight - _cardMargin,
        );
        break;

      case CoachmarkContentAlign.bottom:
        left = _clampHorizontal(targetRect.center.dx, screenSize.width);
        // Position card below the target. Clamp so card never goes off the bottom.
        final preferredTop = targetRect.bottom + padding;
        top = preferredTop.clamp(
          _cardMargin,
          screenSize.height - cardHeight - _cardMargin,
        );
        break;

      case CoachmarkContentAlign.left:
        top = _clampVertical(targetRect.center.dy, screenSize.height);
        right = screenSize.width - targetRect.left + padding;
        break;

      case CoachmarkContentAlign.right:
        top = _clampVertical(targetRect.center.dy, screenSize.height);
        left = targetRect.right + padding;
        break;
    }

    return _CardPosition(left: left, top: top, right: right, bottom: bottom);
  }

  double _clampHorizontal(double centerX, double screenWidth) {
    double left = centerX - _cardWidth / 2;
    return left.clamp(_cardMargin, screenWidth - _cardWidth - _cardMargin);
  }

  double _clampVertical(double centerY, double screenHeight) {
    const cardHeight = 200.0;
    double top = centerY - cardHeight / 2;
    return top.clamp(_cardMargin, screenHeight - cardHeight - _cardMargin);
  }
}

class _CardPosition {
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  _CardPosition({this.left, this.top, this.right, this.bottom});
}

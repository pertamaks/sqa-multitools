import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/coffee_shop_service.dart';
import '../../plugins/settings/providers/settings_debug_provider.dart';
import '../../core/providers/plugin_provider.dart';



class SquashTheBugOverlay extends ConsumerStatefulWidget {
  static final GlobalKey<SquashTheBugOverlayState> bugKey = GlobalKey();
  const SquashTheBugOverlay({super.key});

  @override
  ConsumerState<SquashTheBugOverlay> createState() =>
      SquashTheBugOverlayState();
}

class SquashTheBugOverlayState extends ConsumerState<SquashTheBugOverlay>
    with TickerProviderStateMixin {
  // -- Movement (Ticker-driven constant velocity) --
  Ticker? _moveTicker;
  Duration _lastTickTime = Duration.zero;
  double _bugPositionX = 0.0;
  double _bugPositionY = 0.0;
  bool _isHorizontal = true;

  /// +1 = moving right/down, -1 = moving left/up
  int _moveDirection = 1;
  Matrix4 _bugTransform = Matrix4.identity();
  bool _isVisible = false;

  // -- Splat --
  late AnimationController _splatController;
  double _splatPositionX = 0.0;
  double _splatPositionY = 0.0;
  bool _isSplatted = false;

  final _random = Random();

  /// Peak speed in logical pixels per second during the "lurch" phase.
  static const double kCaterpillarSpeed = 10.0;

  /// Tune this to match the caterpillar GIF's animation loop (1.68s based on GIF data).
  static const double kInchPeriod = 1.68;

  /// Fraction of the cycle spent moving (the rest is a stationary pause).
  /// 0.5 = move half, rest half. 0.3 = quick lurch, long pause.
  static const double kInchMoveFraction = 0.7;

  // Reference to height from MainToolbar (56)
  static const double kToolbarHeight = 56;

  // Sizing constants for alignment
  static const double kBugSize = 32.0;
  static const double kSplatSize = 32.0;

  /// Off-screen buffer for spawn/despawn.
  static const double kSpawnOffset = 50.0;

  void triggerBug(int side) {
    if (!mounted) return;
    _runBug(isHorizontal: side < 2, isTopOrLeft: side == 0 || side == 2);
  }

  @override
  void initState() {
    super.initState();

    _splatController =
        AnimationController(
          duration: const Duration(milliseconds: 1000),
          vsync: this,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() {
              _isSplatted = false;
            });
          }
        });

    _scheduleNextBug();
  }

  void _scheduleNextBug() {
    // Wait between 10 and 30 minutes (600 to 1800 seconds)
    final delay = _random.nextInt(1201) + 600;
    Future.delayed(Duration(seconds: delay), () {
      if (mounted) _showBug();
    });
  }

  Future<void> _showBug() async {
    if (!mounted) return;
    if (!await windowManager.isVisible()) {
      _scheduleNextBug();
      return;
    }
    final activePlugin = ref.read(activePluginProvider);
    final hasPlugin = activePlugin != null;
    final bool isHorizontal = _random.nextBool();
    final bool isTopOrLeft = _random.nextBool();
    _runBug(
      isHorizontal: isHorizontal,
      isTopOrLeft: isTopOrLeft,
      hasPlugin: hasPlugin,
    );
  }

  void _runBug({
    required bool isHorizontal,
    required bool isTopOrLeft,
    bool? hasPlugin,
  }) {
    if (!mounted) return;
    final bool effectiveHasPlugin =
        hasPlugin ?? ref.read(activePluginProvider) != null;
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    _isHorizontal = isHorizontal;

    // Stop any existing movement ticker
    _moveTicker?.stop();
    _moveTicker?.dispose();
    _moveTicker = null;

    setState(() {
      _isVisible = true;
      if (_isHorizontal) {
        final bool isToolbar = !effectiveHasPlugin || isTopOrLeft;
        final isMovingRight = _random.nextBool();
        _moveDirection = isMovingRight ? 1 : -1;
        _bugPositionY = isToolbar ? kToolbarHeight - 19 : height - 19;
        _bugPositionX = isMovingRight ? -kSpawnOffset : width + kSpawnOffset;

        // GIF default orientation: head-left (←), tail-right (→)
        // Moving right → flip horizontally so head points right
        // Moving left → identity (head already points left)
        if (isToolbar) {
          _bugTransform = isMovingRight
              ? Matrix4.diagonal3Values(-1.0, 1.0, 1.0)
              : Matrix4.identity();
        } else {
          _bugTransform = isMovingRight
              ? Matrix4.diagonal3Values(-1.0, 1.0, 1.0)
              : Matrix4.identity();
        }
      } else {
        final isLeftBorder = isTopOrLeft;
        final isMovingDown = _random.nextBool();
        _moveDirection = isMovingDown ? 1 : -1;
        _bugPositionX = isLeftBorder ? -13 : width - 19;
        _bugPositionY = isMovingDown ? -kSpawnOffset : height + kSpawnOffset;

        // Vertical orientation (preserve existing rotation logic)
        if (isLeftBorder) {
          if (isMovingDown) {
            _bugTransform = Matrix4.rotationZ(pi / 2)
              ..multiply(Matrix4.diagonal3Values(-1.0, 1.0, 1.0));
          } else {
            _bugTransform = Matrix4.rotationZ(pi / 2);
          }
        } else {
          if (isMovingDown) {
            _bugTransform = Matrix4.rotationZ(-pi / 2);
          } else {
            _bugTransform = Matrix4.rotationZ(-pi / 2)
              ..multiply(Matrix4.diagonal3Values(-1.0, 1.0, 1.0));
          }
        }
      }
    });

    // Start the movement ticker
    _lastTickTime = Duration.zero;
    _moveTicker = createTicker(_onMoveTick);
    _moveTicker!.start();
  }

  /// Frame-driven inching movement: lurches forward in sync with the GIF cycle,
  /// then pauses. Speed is constant regardless of window size.
  void _onMoveTick(Duration elapsed) {
    if (!mounted || !_isVisible) {
      _moveTicker?.stop();
      return;
    }

    // Calculate delta time in seconds
    final double dt = _lastTickTime == Duration.zero
        ? 0.0
        : (elapsed - _lastTickTime).inMicroseconds / 1000000.0;
    _lastTickTime = elapsed;

    if (dt == 0.0) return; // Skip the very first frame

    // --- Inch cycle: lurch then pause ---
    final totalSeconds = elapsed.inMicroseconds / 1000000.0;
    final cycleT = (totalSeconds % kInchPeriod) / kInchPeriod; // 0.0 → 1.0

    double inchMultiplier;
    if (cycleT < kInchMoveFraction) {
      // Move phase: smooth sine pulse (accelerate → decelerate)
      inchMultiplier = sin((cycleT / kInchMoveFraction) * pi);
    } else {
      // Rest phase: stationary (body bunching up)
      inchMultiplier = 0.0;
    }

    final double displacement = kCaterpillarSpeed * inchMultiplier * dt;

    // Dynamic bounds check against CURRENT window size (resize-safe)
    final size = MediaQuery.of(context).size;

    setState(() {
      if (_isHorizontal) {
        _bugPositionX += displacement * _moveDirection;
        if (_bugPositionX > size.width + kSpawnOffset ||
            _bugPositionX < -kSpawnOffset - kBugSize) {
          _hideBug();
          _scheduleNextBug();
        }
      } else {
        _bugPositionY += displacement * _moveDirection;
        if (_bugPositionY > size.height + kSpawnOffset ||
            _bugPositionY < -kSpawnOffset - kBugSize) {
          _hideBug();
          _scheduleNextBug();
        }
      }
    });
  }

  void _hideBug() {
    setState(() => _isVisible = false);
    _moveTicker?.stop();
  }

  void _squash() async {
    if (!_isVisible) return;
    final prefs = ref.read(preferencesServiceProvider);
    final count = prefs.getBugsSquashed();
    await prefs.setBugsSquashed(count + 1);



    // Trigger Splat Animation
    setState(() {
      _splatPositionX = _bugPositionX;
      _splatPositionY = _bugPositionY;
      _isSplatted = true;
    });
    _splatController.forward(from: 0);

    _hideBug();
    _scheduleNextBug();
  }

  @override
  void dispose() {
    _moveTicker?.stop();
    _moveTicker?.dispose();
    _splatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for external diagnostic triggers
    ref.listen(bugTriggerProvider, (previous, next) {
      if (next != null) {
        triggerBug(next);
      }
    });

    final supporterTier = ref.watch(supporterTierProvider);
    final isEnabled = ref.watch(bugSquashEnabledProvider);
    if (supporterTier < 3 || !isEnabled) return const SizedBox.shrink();

    return Stack(
      children: [
        if (_isVisible)
          Positioned(
            top: _bugPositionY,
            left: _bugPositionX,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _squash,
                child: Transform(
                  transform: _bugTransform,
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/caterpillar.gif',
                    width: kBugSize,
                    height: kBugSize,
                  ),
                ),
              ),
            ),
          ),
        if (_isSplatted) ...[
          // Main splat image with impact bounce
          Positioned(
            top: _splatPositionY + (kBugSize - kSplatSize) / 2,
            left: _splatPositionX + (kBugSize - kSplatSize) / 2,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _splatController,
                builder: (context, child) {
                  final double t = _splatController.value;

                  // Impact: 0→0.1 scale 0.5→1.2 (overshoot bounce)
                  // Settle: 0.1→0.3 scale 1.2→1.0
                  // Hold:   0.3→0.5 scale 1.0
                  // Fade:   0.5→1.0 opacity 1.0→0.0
                  double scale;
                  if (t < 0.1) {
                    scale = 0.5 + 0.7 * Curves.easeOutBack.transform(t / 0.1);
                  } else if (t < 0.3) {
                    final st = (t - 0.1) / 0.2;
                    scale = 1.2 - 0.2 * Curves.easeInOut.transform(st);
                  } else {
                    scale = 1.0;
                  }

                  final double opacity = t < 0.5
                      ? 1.0
                      : 1.0 - Curves.easeIn.transform((t - 0.5) / 0.5);

                  return Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: Image.asset(
                  'assets/bug_splat.png',
                  width: kSplatSize,
                  height: kSplatSize,
                  color: const Color(0xFF79AE6F),
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }


}

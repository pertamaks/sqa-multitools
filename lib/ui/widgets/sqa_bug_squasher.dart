import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/coffee_shop_service.dart';
import '../../plugins/settings/providers/settings_debug_provider.dart';
import '../../core/providers/plugin_provider.dart';
import 'sqa_toast.dart';

class SquashTheBugOverlay extends ConsumerStatefulWidget {
  static final GlobalKey<SquashTheBugOverlayState> bugKey = GlobalKey();
  const SquashTheBugOverlay({super.key});

  @override
  ConsumerState<SquashTheBugOverlay> createState() =>
      SquashTheBugOverlayState();
}

class SquashTheBugOverlayState extends ConsumerState<SquashTheBugOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _splatController;
  late Animation<double> _animation;
  late Animation<double> _splatScaleDown;
  double _bugPositionX = 0.0;
  double _bugPositionY = 0.0;
  double _splatPositionX = 0.0;
  double _splatPositionY = 0.0;
  bool _isHorizontal = true;
  Matrix4 _bugTransform = Matrix4.identity();
  bool _isVisible = false;
  bool _isSplatted = false;
  final _random = Random();

  // Reference to height from MainToolbar (56)
  static const double kToolbarHeight = 56;

  void triggerBug(int side) {
    if (!mounted) return;
    _runBug(isHorizontal: side < 2, isTopOrLeft: side == 0 || side == 2);
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: const Duration(seconds: 45), vsync: this)
          ..addListener(() {
            if (_isVisible) {
              setState(() {
                if (_isHorizontal) {
                  _bugPositionX = _animation.value;
                } else {
                  _bugPositionY = _animation.value;
                }
              });
            }
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _hideBug();
              _scheduleNextBug();
            }
          });

    _splatController =
        AnimationController(
          duration: const Duration(milliseconds: 1000),
          vsync: this,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() => _isSplatted = false);
          }
        });

    _splatScaleDown = CurvedAnimation(
      parent: _splatController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    );

    _animation = const AlwaysStoppedAnimation(0.0);
    _scheduleNextBug();
  }

  void _scheduleNextBug() {
    final delay = _random.nextInt(180) + 120;
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
    setState(() {
      _isVisible = true;
      if (_isHorizontal) {
        final bool isToolbar = !effectiveHasPlugin || isTopOrLeft;
        final isMovingRight = _random.nextBool();
        _bugPositionY = isToolbar ? kToolbarHeight - 19 : height - 19;
        final double startX = isMovingRight ? -50.0 : width + 50.0;
        final double endX = isMovingRight ? width + 50.0 : -50.0;
        _bugPositionX = startX;
        _bugTransform = Matrix4.identity();
        if (isToolbar) {
          if (isMovingRight) {
            _bugTransform = Matrix4.diagonal3Values(-1.0, 1.0, 1.0);
          } else {
            _bugTransform = Matrix4.diagonal3Values(1.0, 1.0, 1.0);
          }
        } else {
          if (isMovingRight) {
            _bugTransform = Matrix4.diagonal3Values(-1.0, 1.0, 1.0);
          } else {
            _bugTransform = Matrix4.identity();
          }
        }
        _animation = Tween<double>(
          begin: startX,
          end: endX,
        ).animate(_controller);
      } else {
        final isLeftBorder = isTopOrLeft;
        final isMovingDown = _random.nextBool();
        _bugPositionX = isLeftBorder ? -13 : width - 19;
        final double startY = isMovingDown ? -50.0 : height + 50.0;
        final double endY = isMovingDown ? height + 50.0 : -50.0;
        _bugPositionY = startY;
        _bugTransform = Matrix4.identity();
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
        _animation = Tween<double>(
          begin: startY,
          end: endY,
        ).animate(_controller);
      }
    });
    _controller.stop();
    _controller.forward(from: 0);
  }

  void _hideBug() {
    setState(() => _isVisible = false);
    _controller.stop();
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
    _controller.dispose();
    _splatController.dispose();
    super.dispose();
  }

  // Sizing constants for alignment
  static const double kBugSize = 32.0;
  static const double kSplatSize = 32.0;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            if (_isVisible)
              Positioned(
                top: _bugPositionY,
                left: _bugPositionX,
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
            if (_isSplatted)
              Positioned(
                // Perfectly center the splat over the bug regardless of size
                top: _splatPositionY + (kBugSize - kSplatSize) / 2,
                left: _splatPositionX + (kBugSize - kSplatSize) / 2,
                child: IgnorePointer(
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
                      CurvedAnimation(
                        parent: _splatController,
                        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
                      ),
                    ),
                    child: ScaleTransition(
                      scale: _splatScaleDown,
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
              ),
          ],
        );
      },
    );
  }
}

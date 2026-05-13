import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'sqa_styles.dart';

enum SqaToastType { success, error, info, warning }

class SqaToast {
  static OverlayEntry? _currentEntry;
  static DateTime? _lastShown;

  static void show(
    BuildContext context,
    String message, {
    SqaToastType type = SqaToastType.info,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    // Prevent rapid-fire duplicate toasts
    final now = DateTime.now();
    if (_lastShown != null && now.difference(_lastShown!) < const Duration(milliseconds: 300)) {
      return;
    }
    _lastShown = now;

    // Remove existing toast immediately if new one comes in
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color iconColor;
    IconData icon;

    switch (type) {
      case SqaToastType.success:
        icon = Symbols.check_circle;
        iconColor = Colors.green.shade600;
        break;
      case SqaToastType.error:
        icon = Symbols.error;
        iconColor = colorScheme.error;
        break;
      case SqaToastType.warning:
        icon = Symbols.warning;
        iconColor = Colors.orange.shade800;
        break;
      case SqaToastType.info:
        icon = Symbols.info;
        iconColor = colorScheme.primary;
        break;
    }

    final textStyle = SqaTextStyles.labelBold(context).copyWith(
      color: colorScheme.onSurface,
      fontSize: 11,
    );

    _currentEntry = OverlayEntry(
      builder: (context) => _SqaToastWidget(
        message: message,
        icon: icon,
        iconColor: iconColor,
        style: textStyle,
        backgroundColor: colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
        borderColor: colorScheme.outlineVariant.withValues(alpha: 0.5),
        duration: duration,
        onDismissed: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }
}

class _SqaToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color iconColor;
  final TextStyle style;
  final Color backgroundColor;
  final Color borderColor;
  final Duration duration;
  final VoidCallback onDismissed;

  const _SqaToastWidget({
    required this.message,
    required this.icon,
    required this.iconColor,
    required this.style,
    required this.backgroundColor,
    required this.borderColor,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_SqaToastWidget> createState() => _SqaToastWidgetState();
}

class _SqaToastWidgetState extends State<_SqaToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _show();
  }

  Future<void> _show() async {
    await _controller.forward();
    await Future.delayed(widget.duration);
    if (mounted) {
      await _controller.reverse();
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: FadeTransition(
            opacity: _opacity,
            child: SlideTransition(
              position: _offset,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: SqaStyles.radiusLarge,
                  border: Border.all(color: widget.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: widget.iconColor, size: 18),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: widget.style,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

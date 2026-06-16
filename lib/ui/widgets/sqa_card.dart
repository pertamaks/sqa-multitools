import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';
import 'sqa_popup_menu.dart';

class SqaCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final BorderSide? borderSide;
  final List<BoxShadow>? boxShadow;

  const SqaCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
    this.borderSide,
    this.boxShadow,
  });

  @override
  State<SqaCard> createState() => _SqaCardState();
}

class _SqaCardState extends State<SqaCard> {
  bool _isHovered = false;
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? SqaTokens.borderRadiusLarge;
    final theme = Theme.of(context);
    
    Widget content = Padding(
      padding: widget.padding ?? const EdgeInsets.all(SqaTokens.spacingLarge),
      child: widget.child,
    );

    // If there's an onTap action, we add flawless hover interactions
    if (widget.onTap != null) {
      content = NotificationListener<SqaMenuOpenNotification>(
        onNotification: (notification) {
          setState(() {
            _isMenuOpen = notification.isOpen;
            if (_isMenuOpen) {
              _isHovered = false;
            }
          });
          return false;
        },
        child: MouseRegion(
          onEnter: (_) {
            if (!_isMenuOpen) setState(() => _isHovered = true);
          },
          onExit: (_) {
            setState(() => _isHovered = false);
          },
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            behavior: HitTestBehavior.opaque,
            child: ValueListenableBuilder<bool>(
              valueListenable: sqaGlobalMenuOpenState,
              builder: (context, isAnyMenuOpen, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: _isHovered && !isAnyMenuOpen
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.04) 
                        : Colors.transparent,
                    borderRadius: effectiveRadius,
                  ),
                  child: child,
                );
              },
              child: content,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        borderRadius: effectiveRadius,
        boxShadow: widget.boxShadow,
        border: Border.fromBorderSide(
          widget.borderSide ?? const BorderSide(color: Colors.transparent),
        ),
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: content,
      ),
    );
  }
}

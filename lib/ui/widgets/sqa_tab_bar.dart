import 'package:flutter/material.dart';
import 'sqa_styles.dart';
import 'sqa_fade_wrapper.dart';

class SqaTabBar extends StatelessWidget implements PreferredSizeWidget {
  static const double kSqaTabBarHeight = 60.0;
  final List<Tab> tabs;
  final TabController? controller;
  final bool isScrollable;

  const SqaTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.isScrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Account for the standardized 24px horizontal padding from SqaPluginLayout
        const double horizontalPadding = 48.0; // 24 * 2
        final double effectiveMaxWidth = constraints.maxWidth - horizontalPadding;

        // 1. Measure Tab Widths (Zero-visual-impact measurement)
        final List<double> tabWidths = tabs.map((tab) {
          final textPainter = TextPainter(
            text: TextSpan(
              text: tab.text ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();

          // In a vertical Tab layout, width is max(text, icon)
          double contentWidth = textPainter.width;
          if (tab.icon != null) {
            contentWidth = contentWidth > 18 ? contentWidth : 18;
          }
          return contentWidth + 32; // Standard labelPadding (16*2)
        }).toList();

        final double maxTabWidth = tabWidths.reduce((a, b) => a > b ? a : b).ceilToDouble() + 1.0;
        final double totalUniformWidth = maxTabWidth * tabs.length;
        final double totalIntrinsicWidth = tabWidths.reduce((a, b) => a + b).ceilToDouble() + (tabs.length * 1.0);

        // 2. Determine State & Build
        Widget tabBar;
        bool fitsUniform = totalUniformWidth <= effectiveMaxWidth;
        bool fitsIntrinsic = totalIntrinsicWidth <= effectiveMaxWidth;

        if (fitsUniform) {
          // State 1: Centric Uniform (Grouped in middle, all same width)
          tabBar = Center(
            child: SizedBox(
              width: totalUniformWidth,
              child: _buildTabBar(context, isScrollable: false, alignment: TabAlignment.fill),
            ),
          );
        } else if (fitsIntrinsic) {
          // State 2: Elastic Symmetry (Fill width, but all same width/equivalent)
          tabBar = _buildTabBar(context, isScrollable: false, alignment: TabAlignment.fill);
        } else {
          // State 3: Overflow Scroll
          tabBar = _buildTabBar(context, isScrollable: true, alignment: TabAlignment.center);
        }

        final bool needsFade = !fitsIntrinsic;

        return SizedBox(
          height: kSqaTabBarHeight,
          child: Material(
            color: colorScheme.surfaceContainerLow,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SqaFadeWrapper(
                axis: Axis.horizontal,
                showStart: needsFade,
                showEnd: needsFade,
                child: tabBar,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabBar(BuildContext context, {required bool isScrollable, required TabAlignment alignment}) {
    final colorScheme = Theme.of(context).colorScheme;
    return TabBar(
      controller: controller,
      isScrollable: isScrollable,
      tabAlignment: alignment,
      dividerColor: Colors.transparent,
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      overlayColor: SqaStyles.buttonOverlay(context),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
      padding: EdgeInsets.zero,
      indicatorWeight: 3,
      tabs: tabs.map((tab) {
        return Tab(
          key: tab.key,
          icon: tab.icon != null
              ? IconTheme.merge(
                  data: const IconThemeData(size: 18),
                  child: tab.icon!,
                )
              : null,
          text: tab.text,
          iconMargin: const EdgeInsets.only(bottom: 4),
          child: tab.child,
        );
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kSqaTabBarHeight);
}

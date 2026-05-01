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

    return SizedBox(
      height: kSqaTabBarHeight,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        child: SqaFadeWrapper(
          axis: Axis.horizontal,
          child: TabBar(
            controller: controller,
            isScrollable: isScrollable,
            tabAlignment: isScrollable ? TabAlignment.start : TabAlignment.fill,
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
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kSqaTabBarHeight);
}

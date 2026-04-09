import 'package:flutter/material.dart';
import 'sqa_styles.dart';

class SqaTabBar extends StatelessWidget implements PreferredSizeWidget {
  static const double kSqaTabBarHeight = 60.0;
  final List<Tab> tabs;
  final TabController? controller;

  const SqaTabBar({super.key, required this.tabs, this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: kSqaTabBarHeight,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        child: TabBar(
          controller: controller,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kSqaTabBarHeight);
}

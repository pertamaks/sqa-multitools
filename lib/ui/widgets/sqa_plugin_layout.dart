import 'package:flutter/material.dart';
import 'sqa_plugin_header.dart';
import 'sqa_tab_bar.dart';
import 'sqa_window_size_toggle.dart';

/// A standardized layout wrapper for all SQA plugins.
///
/// It integrates [SqaPluginHeader] and optionally [SqaTabBar] with consistent
/// padding and spacing.
class SqaPluginLayout extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String description;
  final Widget? titleWidget;
  final Color? color;
  final Widget? trailing;
  final List<Tab>? tabs;
  final TabController? tabController;
  final Widget child;
  final VoidCallback? onBack;
  final bool useMask;
  final bool isTabScrollable;

  const SqaPluginLayout({
    super.key,
    this.icon,
    this.title = '',
    this.description = '',
    this.titleWidget,
    this.color,
    this.trailing,
    this.tabs,
    this.tabController,
    required this.child,
    this.onBack,
    this.useMask = true,
    this.isTabScrollable = false,
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: SqaPluginHeader(
                    icon: icon,
                    title: title,
                    description: description,
                    titleWidget: titleWidget,
                    color: color,
                    trailing: trailing,
                    onBack: onBack,
                  ),
                ),
                if (tabs != null && tabs!.isNotEmpty)
                  SqaTabBar(
                    tabs: tabs!,
                    controller: tabController,
                    isScrollable: isTabScrollable,
                  ),
                Expanded(child: child),
              ],
            ),
          ),
        ),
        const Positioned(
          bottom: 4,
          right: 4,
          child: SqaWindowSizeToggle(),
        ),
      ],
    );
  }
}

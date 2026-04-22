import 'package:flutter/material.dart';
import 'sqa_plugin_header.dart';
import 'sqa_tab_bar.dart';
import 'sqa_fade_wrapper.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (useMask) {
      content = SqaFadeWrapper(child: child);
    }

    return Column(
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
          SqaTabBar(tabs: tabs!, controller: tabController),
        Expanded(child: content),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'sqa_plugin_header.dart';
import 'sqa_tab_bar.dart';
import 'sqa_window_size_toggle.dart';
import 'sqa_search_filter_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/window_provider.dart';

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
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;
  final Widget? filterOptions;
  final bool isFilterActive;

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
    this.searchController,
    this.onSearchChanged,
    this.searchHint = 'Search...',
    this.filterOptions,
    this.isFilterActive = false,
  });
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final mode = ref.watch(windowSizeModeProvider);
        final isSquare = mode == WindowSizeMode.squareMode;

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
                    // Standardized Search Bar (Square Mode Only)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.vertical,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: (isSquare && searchController != null)
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                              child: SqaSearchFilterBar(
                                controller: searchController!,
                                hintText: searchHint,
                                onChanged: onSearchChanged,
                                filterOptions: filterOptions,
                                isFilterActive: isFilterActive,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    if (tabs != null && tabs!.isNotEmpty)
                      DefaultTabController(
                        key: ValueKey(tabs!.length),
                        length: tabs!.length,
                        child: Expanded(
                          child: Column(
                            children: [
                              SqaTabBar(
                                tabs: tabs!,
                                controller: tabController,
                                isScrollable: isTabScrollable,
                              ),
                              Expanded(child: this.child),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(child: this.child),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: ListenableBuilder(
                listenable: searchController ?? TextEditingController(),
                builder: (context, _) {
                  final bool hasSearchText =
                      searchController != null &&
                      searchController!.text.isNotEmpty;
                  return SqaWindowSizeToggle(
                    isSearchActive: hasSearchText,
                    onClearSearch: () {
                      searchController?.clear();
                      onSearchChanged?.call('');
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

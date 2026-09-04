import 'package:flutter/material.dart';
import 'sqa_design_tokens.dart';
import 'sqa_plugin_header.dart';
import 'sqa_tab_bar.dart';
import 'sqa_window_size_toggle.dart';
import 'sqa_search_filter_bar.dart';
import 'sqa_hover_icon_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/window_provider.dart';
import 'package:material_symbols_icons/symbols.dart';

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
  final Widget? secondaryHeader;
  final int initialTabIndex;
  final Key? tabBarKey;

  /// When non-null, a (?) help button appears in the plugin header trailing
  /// area. Tapping it re-triggers the coachmark tour for this plugin.
  final VoidCallback? onShowCoachmark;

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
    this.secondaryHeader,
    this.initialTabIndex = 0,
    this.tabBarKey,
    this.onShowCoachmark,
  });

  /// Combines the optional [trailing] widget with the (?) coachmark button.
  Widget? _buildTrailing(BuildContext context) {
    final helpButton = onShowCoachmark != null
        ? SqaHoverIconButton(
            icon: Symbols.help_outline,
            onPressed: onShowCoachmark!,
            tooltip: 'Show usage guide',
            iconSize: 18,
            padding: 4,
          )
        : null;

    if (trailing == null && helpButton == null) return null;
    if (trailing == null) return helpButton;
    if (helpButton == null) return trailing;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [trailing!, const SizedBox(width: 4), helpButton],
    );
  }

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
                      padding: const EdgeInsets.fromLTRB(
                        SqaTokens.spacingXLarge,
                        SqaTokens.spacingLarge,
                        SqaTokens.spacingXLarge,
                        SqaTokens.spacingMedium,
                      ),
                      child: SqaPluginHeader(
                        icon: icon,
                        title: title,
                        description: description,
                        titleWidget: titleWidget,
                        color: color,
                        trailing: _buildTrailing(context),
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
                              padding: const EdgeInsets.fromLTRB(
                                SqaTokens.spacingXLarge,
                                0,
                                SqaTokens.spacingXLarge,
                                SqaTokens.spacingMedium,
                              ),
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
                        key: ValueKey('${tabs!.length}_$initialTabIndex'),
                        length: tabs!.length,
                        initialIndex: initialTabIndex,
                        child: Expanded(
                          child: Column(
                            children: [
                              SqaTabBar(
                                contentKey: tabBarKey,
                                tabs: tabs!,
                                controller: tabController,
                                isScrollable: isTabScrollable,
                              ),
                              ?secondaryHeader,
                              Expanded(child: this.child),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: Column(
                          children: [
                            ?secondaryHeader,
                            Expanded(child: this.child),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: SqaTokens.spacingTiny,
              right: SqaTokens.spacingTiny,
              child: searchController == null
                  ? SqaWindowSizeToggle(
                      isSearchActive: false,
                      onClearSearch: () {},
                    )
                  : ListenableBuilder(
                      listenable: searchController!,
                      builder: (context, _) {
                        final bool hasSearchText =
                            searchController!.text.isNotEmpty;
                        return SqaWindowSizeToggle(
                          isSearchActive: hasSearchText,
                          onClearSearch: () {
                            searchController!.clear();
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

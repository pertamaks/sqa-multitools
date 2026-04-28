import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'sqa_styles.dart';

class SqaSearchFilterBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Widget? filterOptions;
  final bool isFilterActive;

  const SqaSearchFilterBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.filterOptions,
    this.isFilterActive = false,
  });

  @override
  State<SqaSearchFilterBar> createState() => _SqaSearchFilterBarState();
}

class _SqaSearchFilterBarState extends State<SqaSearchFilterBar> {
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _isHovered = false;
  bool _isFilterMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _isFocused
              ? colorScheme.primaryContainer.withValues(alpha: 0.15)
              : (_isHovered
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
                  : colorScheme.surfaceContainerLow.withValues(alpha: 0.2)),
          borderRadius: SqaStyles.radiusLarge,
          border: Border.all(
            color: _isFocused
                ? colorScheme.primary.withValues(alpha: 0.3)
                : (_isHovered
                    ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                    : colorScheme.outlineVariant.withValues(alpha: 0.1)),
          ),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              alignment: Alignment.centerLeft,
              children: <Widget>[
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          child: _isFilterMode && widget.filterOptions != null
              ? _buildFilterMode(theme, colorScheme)
              : _buildSearchMode(theme, colorScheme),
        ),
      ),
    );
  }

  Widget _buildSearchMode(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      key: const ValueKey('search_mode'),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0),
          child: Icon(
            Symbols.search,
            size: 18,
            color: _isFocused ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Focus(
            onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
            child: TextField(
              controller: _controller,
              onChanged: (val) {
                widget.onChanged?.call(val);
                setState(() {});
              },
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 0,
                ),
              ),
            ),
          ),
        ),
        if (_controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              icon: const Icon(Symbols.close, size: 16),
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
                setState(() {});
              },
              color: colorScheme.onSurfaceVariant,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        if (widget.filterOptions != null)
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: Icon(
                Symbols.tune, 
                size: 18, 
                color: widget.isFilterActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
              onPressed: () => setState(() => _isFilterMode = true),
              tooltip: 'Show Filters',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterMode(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      key: const ValueKey('filter_mode'),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 8.0),
          child: IconButton(
            icon: Icon(Symbols.search, size: 18, color: colorScheme.onSurfaceVariant),
            onPressed: () => setState(() => _isFilterMode = false),
            tooltip: 'Back to Search',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        Container(
          height: 20,
          width: 1,
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          margin: const EdgeInsets.only(right: 4.0),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: widget.filterOptions!,
          ),
        ),
      ],
    );
  }
}

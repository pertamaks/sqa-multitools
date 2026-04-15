import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'sqa_card.dart';
import 'sqa_styles.dart';

/// Data model for a tile-style picker item (with optional thumbnail image).
class SqaPickerTile {
  final String label;
  final String? imagePath;
  final String? badge;

  const SqaPickerTile({
    required this.label,
    this.imagePath,
    this.badge,
  });
}

/// Data model for a list-style picker item (icon + label).
class SqaPickerItem {
  final IconData icon;
  final String label;
  final String? subtitle;

  const SqaPickerItem({
    required this.icon,
    required this.label,
    this.subtitle,
  });
}

/// A centralized picker dialog supporting two visual modes:
///
/// - **Tile mode** (`SqaPickerDialog.tile`): Cards with thumbnail previews,
///   labels, and optional badges. Ideal for monitor/display selection.
///
/// - **List mode** (`SqaPickerDialog.list`): Simple icon + label list tiles.
///   Ideal for window or file selection.
///
/// Both modes are generic over `<T>` and return the selected item on tap.
class SqaPickerDialog<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final bool isTileMode;
  final VoidCallback? onRefresh;

  // Tile mode
  final SqaPickerTile Function(T item, int index)? tileBuilder;

  // List mode
  final SqaPickerItem Function(T item, int index)? itemBuilder;
  final bool isLoading;
  final IconData emptyIcon;
  final String emptyLabel;

  /// Creates a **tile-style** picker with thumbnail image cards.
  const SqaPickerDialog.tile({
    super.key,
    required this.title,
    required this.items,
    required this.tileBuilder,
    this.onRefresh,
  })  : isTileMode = true,
        itemBuilder = null,
        isLoading = false,
        emptyIcon = Symbols.search_off,
        emptyLabel = 'No items found';

  /// Creates a **list-style** picker with simple icon + label rows.
  const SqaPickerDialog.list({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.isLoading = false,
    this.emptyIcon = Symbols.search_off,
    this.emptyLabel = 'No items found',
    this.onRefresh,
  })  : isTileMode = false,
        tileBuilder = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 16),
              onPressed: onRefresh,
              tooltip: 'Refresh',
            ),
        ],
      ),
      content: SizedBox(
        width: isTileMode ? 320 : 500,
        height: isTileMode ? null : 400,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? _buildEmpty(theme)
                : isTileMode
                    ? _buildTileContent(context, theme)
                    : _buildListContent(context, theme),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(emptyIcon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            emptyLabel,
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTileContent(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final tile = tileBuilder!(item, index);

          return SqaCard(
            margin: const EdgeInsets.only(bottom: 12),
            onTap: () => Navigator.of(context).pop(item),
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: AspectRatio(
                    aspectRatio: 32 / 9,
                    child: tile.imagePath != null
                        ? Image.file(
                            File(tile.imagePath!),
                            fit: BoxFit.cover,
                            key: ValueKey(
                              tile.imagePath! +
                                  DateTime.now().millisecond.toString(),
                            ),
                          )
                        : Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Symbols.desktop_windows,
                                size: 32,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                  ),
                ),
                // Label + Badge
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tile.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (tile.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tile.badge!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildListContent(BuildContext context, ThemeData theme) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final listItem = itemBuilder!(item, index);

        return SqaCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(listItem.icon, size: 20),
            title: Text(
              listItem.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: listItem.subtitle != null
                ? Text(
                    listItem.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall,
                  )
                : null,
            onTap: () => Navigator.of(context).pop(item),
          ),
        );
      },
    );
  }
}

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

  const SqaPickerTile({required this.label, this.imagePath, this.badge});
}

/// Data model for a list-style picker item (icon + label).
class SqaPickerItem {
  final IconData icon;
  final String label;
  final String? subtitle;

  const SqaPickerItem({required this.icon, required this.label, this.subtitle});
}

/// A centralized modal system supporting selection pickers and confirmation prompts.
class SqaModal<T> extends StatelessWidget {
  final String title;
  final String? message;
  final List<T> items;
  final bool isTileMode;
  final bool isConfirmMode;
  final VoidCallback? onRefresh;

  // Selection mode
  final SqaPickerTile Function(T item, int index)? tileBuilder;
  final SqaPickerItem Function(T item, int index)? itemBuilder;
  final bool isLoading;
  final IconData emptyIcon;
  final String emptyLabel;

  // Confirm mode
  final String? confirmLabel;
  final String? cancelLabel;
  final Color? confirmColor;
  final IconData? icon;

  /// Creates a **tile-style** picker with thumbnail image cards.
  const SqaModal.tile({
    super.key,
    required this.title,
    required this.items,
    required this.tileBuilder,
    this.onRefresh,
  }) : isTileMode = true,
       isConfirmMode = false,
       itemBuilder = null,
       isLoading = false,
       emptyIcon = Symbols.search_off,
       emptyLabel = 'No items found',
       message = null,
       confirmLabel = null,
       cancelLabel = null,
       confirmColor = null,
       icon = null;

  /// Creates a **list-style** picker with simple icon + label rows.
  const SqaModal.list({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    this.isLoading = false,
    this.emptyIcon = Symbols.search_off,
    this.emptyLabel = 'No items found',
    this.onRefresh,
  }) : isTileMode = false,
       isConfirmMode = false,
       tileBuilder = null,
       message = null,
       confirmLabel = null,
       cancelLabel = null,
       confirmColor = null,
       icon = null;

  /// Creates a **confirmation** modal with a title and message.
  const SqaModal.confirm({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.icon,
  }) : isTileMode = false,
       isConfirmMode = true,
       items = const [],
       tileBuilder = null,
       itemBuilder = null,
       isLoading = false,
       emptyIcon = Symbols.search_off,
       emptyLabel = '',
       onRefresh = null;

  /// Static helper to show a confirmation dialog.
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => SqaModal<void>.confirm(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            confirmColor: confirmColor,
            icon: icon,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: confirmColor ?? theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
      content:
          isConfirmMode
              ? (message != null ? Text(message!) : null)
              : SizedBox(
                width: isTileMode ? 320 : 500,
                height: isTileMode ? null : 400,
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : items.isEmpty
                        ? _buildEmpty(theme)
                        : isTileMode
                        ? _buildTileContent(context, theme)
                        : _buildListContent(context, theme),
              ),
      actions: [
        if (isConfirmMode) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style:
                confirmColor != null
                    ? FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                    )
                    : null,
            child: Text(confirmLabel ?? 'Confirm'),
          ),
        ] else
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
        children:
            items.asMap().entries.map((entry) {
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: 32 / 9,
                        child:
                            tile.imagePath != null
                                ? Image.file(
                                  File(tile.imagePath!),
                                  fit: BoxFit.cover,
                                  key: ValueKey(
                                    tile.imagePath! +
                                        DateTime.now().millisecond.toString(),
                                  ),
                                )
                                : Container(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                                horizontal: 6,
                                vertical: 2,
                              ),
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
            subtitle:
                listItem.subtitle != null
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

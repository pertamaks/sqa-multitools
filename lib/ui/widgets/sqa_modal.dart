import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'sqa_card.dart';
import 'sqa_styles.dart';
import 'sqa_fade_wrapper.dart';

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
class SqaModal<T> extends StatefulWidget {
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

  // Custom mode
  final Widget? child;
  final List<Widget>? customActions;
  final String? confirmLabel;
  final String? cancelLabel;
  final Color? confirmColor;
  final IconData? icon;
  final Widget? topBar;
  final Widget? leading;

  /// Creates a **tile-style** picker with thumbnail image cards.
  const SqaModal.tile({
    super.key,
    required this.title,
    required this.items,
    required this.tileBuilder,
    this.onRefresh,
    this.topBar,
    this.leading,
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
       icon = null,
       child = null,
       customActions = null;

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
    this.topBar,
    this.leading,
  }) : isTileMode = false,
       isConfirmMode = false,
       tileBuilder = null,
       message = null,
       confirmLabel = null,
       cancelLabel = null,
       confirmColor = null,
       icon = null,
       child = null,
       customActions = null;

  /// Creates a **confirmation** modal with a title and message.
  const SqaModal.confirm({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.icon,
    this.topBar,
    this.leading,
  }) : isTileMode = false,
       isConfirmMode = true,
       items = const [],
       tileBuilder = null,
       itemBuilder = null,
       isLoading = false,
       emptyIcon = Symbols.search_off,
       emptyLabel = '',
       onRefresh = null,
       child = null,
       customActions = null;

  /// Creates a **custom** modal with a title and arbitrary child content.
  const SqaModal.custom({
    super.key,
    required this.title,
    required this.child,
    this.customActions,
    this.confirmLabel,
    this.cancelLabel,
    this.confirmColor,
    this.icon,
    this.topBar,
    this.leading,
  }) : isTileMode = false,
       isConfirmMode = false,
       items = const [],
       tileBuilder = null,
       itemBuilder = null,
       isLoading = false,
       emptyIcon = Symbols.search_off,
       emptyLabel = '',
       onRefresh = null,
       message = null;

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
      builder: (context) => SqaModal<void>.confirm(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
  }

  /// Static helper to show a danger/destructive confirmation dialog.
  static Future<bool?> showDanger(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    IconData icon = Symbols.delete,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SqaModal<void>.confirm(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        confirmColor: Theme.of(context).colorScheme.error,
        icon: icon,
      ),
    );
  }

  /// Static helper to show a prompt dialog with a text field.
  static Future<String?> showPrompt(
    BuildContext context, {
    required String title,
    required String message,
    String initialValue = '',
    String confirmLabel = 'Save',
    String cancelLabel = 'Cancel',
    IconData icon = Symbols.edit,
    String? Function(String)? validator,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (context) => _PromptDialog(
        title: title,
        message: message,
        initialValue: initialValue,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        icon: icon,
        validator: validator,
      ),
    );
  }

  @override
  State<SqaModal<T>> createState() => _SqaModalState<T>();
}

class _PromptDialog extends StatefulWidget {
  final String title;
  final String message;
  final String initialValue;
  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;
  final String? Function(String)? validator;

  const _PromptDialog({
    required this.title,
    required this.message,
    required this.initialValue,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.icon,
    this.validator,
  });

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late TextEditingController _controller;
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: widget.initialValue)
      ..selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.initialValue.length,
      );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.validator?.call(_currentValue);
    final isValid = error == null;

    return SqaModal<void>.custom(
      title: widget.title,
      icon: widget.icon,
      confirmLabel: widget.confirmLabel,
      cancelLabel: widget.cancelLabel,
      confirmColor: isValid ? null : Colors.grey,
      customActions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        const SizedBox(width: 4),
        FilledButton(
          onPressed: isValid
              ? () => Navigator.of(context).pop(_currentValue)
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            autofocus: true,
            controller: _controller,
            onChanged: (v) {
              setState(() => _currentValue = v);
            },
            onSubmitted: isValid ? (v) => Navigator.of(context).pop(v) : null,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              errorText: error,
              errorStyle: const TextStyle(fontSize: 10),
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SqaModalState<T> extends State<SqaModal<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: SqaStyles.radiusLarge),
      titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      title: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 8),
          ] else if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: 20,
              color: widget.confirmColor ?? theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              widget.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize:
                    20, // Match SqaPluginHeader standard for consistent branding
              ),
            ),
          ),
          if (widget.onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 16),
              onPressed: widget.onRefresh,
              tooltip: 'Refresh',
            ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      content: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: widget.isTileMode 
              ? 320 
              : MediaQuery.of(context).size.width * 0.85 < 500 
                  ? MediaQuery.of(context).size.width * 0.85 
                  : 500,
          maxWidth: widget.isTileMode 
              ? 320 
              : MediaQuery.of(context).size.width * 0.85 > 900 
                  ? 900 
                  : MediaQuery.of(context).size.width * 0.85,
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: widget.isLoading
            ? const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              )
            : (widget.isConfirmMode
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: widget.message != null
                          ? Text(
                              widget.message!,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            )
                          : const SizedBox.shrink(),
                    )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.topBar != null) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                                bottom: 16,
                              ),
                              child: widget.topBar!,
                            ),
                          ],
                          Flexible(
                            child: ScrollConfiguration(
                              behavior: const _NoScrollbarBehavior(),
                              child: Scrollbar(
                                controller: _scrollController,
                                thumbVisibility: true,
                                thickness: 6.0,
                                radius: const Radius.circular(3),
                                child: SqaFadeWrapper(
                                  depth:
                                      0.08, // Increased for better visibility in modal
                                  threshold: 20.0, // Trigger sooner
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 16,
                                    ), // Align scrollbar with buttons
                                    child: (widget.child != null)
                                        ? SingleChildScrollView(
                                            controller: _scrollController,
                                            padding: const EdgeInsets.only(
                                              left: 24,
                                              right: 12,
                                            ),
                                            child: widget.child!,
                                          )
                                        : (widget.items.isEmpty
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 24,
                                                      ),
                                                  child: _buildEmpty(theme),
                                                )
                                              : (widget.isTileMode
                                                    ? _buildTileContent(
                                                        context,
                                                        theme,
                                                      )
                                                    : _buildListContent(
                                                        context,
                                                        theme,
                                                      ))),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      actionsAlignment: MainAxisAlignment.end,
      actions:
          widget.customActions ??
          [
            if (widget.isConfirmMode || widget.child != null) ...[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: Text(widget.cancelLabel ?? 'Cancel'),
              ),
              const SizedBox(width: 4), // Tighter internal spacing
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style:
                    (widget.confirmColor != null
                            ? FilledButton.styleFrom(
                                backgroundColor: widget.confirmColor,
                                foregroundColor: Colors.white,
                              )
                            : FilledButton.styleFrom())
                        .copyWith(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                child: Text(widget.confirmLabel ?? 'Confirm'),
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
          Icon(widget.emptyIcon, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            widget.emptyLabel,
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTileContent(BuildContext context, ThemeData theme) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final tile = widget.tileBuilder!(item, index);

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
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    11, // Standard Label size per GEMINI.md
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
      ),
    );
  }

  Widget _buildListContent(BuildContext context, ThemeData theme) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ListView.separated(
        controller: _scrollController,
        itemCount: widget.items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final listItem = widget.itemBuilder!(item, index);

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
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11, // Standard Label size per GEMINI.md
                      ),
                    )
                  : null,
              onTap: () => Navigator.of(context).pop(item),
            ),
          );
        },
      ),
    );
  }
}

class _NoScrollbarBehavior extends MaterialScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

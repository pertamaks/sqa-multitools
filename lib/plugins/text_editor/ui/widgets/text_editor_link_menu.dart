import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:sqa_multitools/ui/widgets/sqa_toast.dart';
import 'package:sqa_multitools/ui/widgets/sqa_hover_icon_button.dart';
import 'package:sqa_multitools/ui/widgets/sqa_design_tokens.dart';

class SqaLinkMenuWidget extends StatefulWidget {
  final String? initialUrl;
  final void Function(String) onSubmitted;
  final VoidCallback onRemove;

  const SqaLinkMenuWidget({
    super.key,
    this.initialUrl,
    required this.onSubmitted,
    required this.onRemove,
  });

  @override
  State<SqaLinkMenuWidget> createState() => SqaLinkMenuWidgetState();
}

class SqaLinkMenuWidgetState extends State<SqaLinkMenuWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialUrl);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(SqaTokens.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Symbols.link, size: SqaTokens.spacingLarge, color: theme.colorScheme.primary),
              const SizedBox(width: SqaTokens.spacingSmall),
              Text(
                widget.initialUrl == null ? 'Add Link' : 'Edit Link',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                  fontSize: SqaTokens.fontSizeSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: SqaTokens.spacingLarge),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: SqaTokens.fontSizeSmall),
            decoration: InputDecoration(
              hintText: 'Paste or type a link...',
              hintStyle: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SqaTokens.spacingMedium,
                vertical: SqaTokens.spacingMedium,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              border: OutlineInputBorder(
                borderRadius: SqaStyles.radiusMedium,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SqaStyles.radiusMedium,
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
              suffixIcon: SqaHoverIconButton(
                icon: Symbols.check_circle,
                iconSize: SqaTokens.spacingLarge + SqaTokens.spacingExtraSmall,
                color: theme.colorScheme.primary,
                onPressed: () => widget.onSubmitted(_controller.text),
                tooltip: 'Apply Link',
                padding: SqaTokens.spacingMedium,
              ),
            ),
            onSubmitted: widget.onSubmitted,
          ),
          if (widget.initialUrl != null && widget.initialUrl!.isNotEmpty) ...[
            const SizedBox(height: SqaTokens.spacingMedium),
            const Divider(height: 1, thickness: 0.5),
            const SizedBox(height: SqaTokens.spacingSmall),
            _buildLinkMenuItem(
              icon: Symbols.open_in_new,
              label: 'Open Link',
              onTap: () async {
                final uri = Uri.tryParse(widget.initialUrl!);
                if (uri != null) {
                  await launchUrl(uri);
                }
              },
            ),
            _buildLinkMenuItem(
              icon: Symbols.content_copy,
              label: 'Copy Link',
              onTap: () {
                Clipboard.setData(ClipboardData(text: widget.initialUrl!));
                SqaToast.show(context, 'Link copied to clipboard');
              },
            ),
            _buildLinkMenuItem(
              icon: Symbols.link_off,
              label: 'Remove Link',
              color: theme.colorScheme.error,
              onTap: widget.onRemove,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLinkMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: SqaStyles.radiusMedium,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SqaTokens.spacingSmall,
          vertical: SqaTokens.spacingMedium,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: color ?? theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: SqaTokens.spacingMedium),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color ?? theme.colorScheme.onSurface,
                fontSize: SqaTokens.fontSizeSmall,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sqa_design_tokens.dart';
import 'sqa_modal.dart';
import 'sqa_button.dart';
import 'sqa_styles.dart';
import 'sqa_markdown_viewer.dart';
import 'sqa_scroll_behavior.dart';
import '../../core/models/update_info.dart';

class SqaUpdateModal extends StatefulWidget {
  final UpdateInfo updateInfo;

  const SqaUpdateModal({super.key, required this.updateInfo});

  static Future<void> show(BuildContext context, UpdateInfo updateInfo) {
    return showDialog(
      context: context,
      barrierDismissible: !updateInfo.isCritical,
      builder: (context) => SqaUpdateModal(updateInfo: updateInfo),
    );
  }

  @override
  State<SqaUpdateModal> createState() => _SqaUpdateModalState();
}

class _SqaUpdateModalState extends State<SqaUpdateModal> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _launchDownload() async {
    final url = Uri.parse(widget.updateInfo.downloadUrl);
    if (!await launchUrl(url)) {
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final updateInfo = widget.updateInfo;

    return SqaModal<void>.custom(
      title: 'Update Available',
      icon: Symbols.update,
      confirmLabel: 'Download Now',
      cancelLabel: updateInfo.isCritical ? null : 'Later',
      confirmColor: colorScheme.primary,
      customActions: [
        if (!updateInfo.isCritical)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
        const SizedBox(width: SqaTokens.spacingSmall),
        SqaButton(
          label: 'Download Now',
          icon: Symbols.download,
          onPressed: _launchDownload,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Version ${updateInfo.version}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              if (updateInfo.isCritical) ...[
                const SizedBox(width: SqaTokens.spacingSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SqaTokens.spacingXSmall - 2,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: SqaTokens.borderRadiusSmall,
                  ),
                  child: Text(
                    'CRITICAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'What\'s New:',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            padding: const EdgeInsets.all(SqaTokens.spacingSmall + 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: SqaStyles.radiusLarge,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: ScrollConfiguration(
              behavior: SqaMouseDragScrollBehavior(),
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: SqaMarkdownViewer(
                    markdown: updateInfo.releaseNotes,
                    useScrollable: false,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

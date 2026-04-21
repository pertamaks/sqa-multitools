import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'sqa_card.dart';
import 'sqa_button.dart';
import '../../core/providers/ffmpeg_provider.dart';

class SqaDependencyCard extends ConsumerWidget {
  final String pluginName;

  const SqaDependencyCard({super.key, required this.pluginName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(ffmpegProvider);
    final notifier = ref.read(ffmpegProvider.notifier);
    final theme = Theme.of(context);

    if (status.isReady && !status.isDownloading) {
      return const SizedBox.shrink();
    }

    return SqaCard(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                status.error != null ? Symbols.error : Symbols.warning,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                status.error != null
                    ? 'Download Failed'
                    : 'Missing Dependencies',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status.error ??
                'The $pluginName requires a lightweight video encoding engine (FFmpeg, ~30MB) to function fully.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (status.isDownloading)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value:
                      status.downloadProgress != null &&
                           status.downloadProgress! >= 0
                      ? status.downloadProgress
                      : null,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
                const SizedBox(height: 4),
                Text(
                  status.downloadProgress != null &&
                          status.downloadProgress! >= 0
                      ? 'Downloading: ${(status.downloadProgress! * 100).toInt()}%'
                      : 'Extracting...',
                  style: theme.textTheme.labelSmall,
                ),
              ],
            )
          else
            SqaButton.tonal(
              onPressed: () => notifier.download(),
              icon: Symbols.download,
              label: status.error != null ? 'Try Again' : 'Download Engine',
            ),
        ],
      ),
    );
  }
}

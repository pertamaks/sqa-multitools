import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/curl_requester_provider.dart';
import '../../models/curl_transaction.dart';
import '../../services/curl_parser_service.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_status_badge.dart';
import '../../../../ui/widgets/sqa_styles.dart';

class HistoryTab extends ConsumerWidget {
  final ScrollController scrollController;
  final VoidCallback onTransactionTap;
  final Function(CurlTransaction) showTransactionModal;

  const HistoryTab({
    super.key,
    required this.scrollController,
    required this.onTransactionTap,
    required this.showTransactionModal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(curlRequesterProvider).history;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.history, size: 64, color: Colors.grey.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            const Text(
              'No request history yet',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Scrollbar(
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        itemCount: history.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final transaction = history[index];
          final displayRequest = transaction.resolvedRequest ?? transaction.request;
          
          // Better URI parsing that handles lack of scheme
          String url = displayRequest.url;
          if (!url.startsWith('http')) url = 'http://$url';
          final uri = Uri.tryParse(url);
          
          String path = uri?.path ?? '/';
          if (path.isEmpty) path = '/';
          
          // Append query params to path for the title if they exist
          final qParams = displayRequest.queryParameters.entries
              .where((e) => !displayRequest.inactiveQueryParameters.contains(e.key))
              .map((e) => '${e.key}=${e.value}')
              .join('&');
          final displayPath = qParams.isNotEmpty ? '$path?$qParams' : path;

          final statusColor = transaction.statusCode >= 200 && transaction.statusCode < 300
              ? Colors.green
              : (transaction.statusCode >= 400 || transaction.statusCode == 0 
                  ? Colors.red 
                  : Colors.orange);

          return SqaCard(
            onTap: () {
              showTransactionModal(transaction);
            },
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SqaStatusBadge(
                      text: transaction.statusCode == 0 ? 'ERR' : '${transaction.statusCode}',
                      color: statusColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${displayRequest.method} $displayPath',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatRelativeTime(transaction.timestamp),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    CurlParserService.stringify(displayRequest),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

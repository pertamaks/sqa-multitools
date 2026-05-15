import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/curl_transaction.dart';
import '../../services/curl_parser_service.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_status_badge.dart';
import '../../../../ui/widgets/sqa_metadata_item.dart';
import '../../../../ui/widgets/sqa_segmented_button.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';

enum ModalTab { request, response }

class TransactionInspectorModal extends StatefulWidget {
  final CurlTransaction? transaction;
  final bool isHistory;
  final VoidCallback? onSendAgain;

  const TransactionInspectorModal({
    super.key,
    this.transaction,
    this.isHistory = false,
    this.onSendAgain,
  });

  static Future<bool?> show(
    BuildContext context, {
    CurlTransaction? transaction,
    bool isHistory = false,
    VoidCallback? onSendAgain,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => TransactionInspectorModal(
        transaction: transaction,
        isHistory: isHistory,
        onSendAgain: onSendAgain,
      ),
    );
  }

  @override
  State<TransactionInspectorModal> createState() => _TransactionInspectorModalState();
}

class _TransactionInspectorModalState extends State<TransactionInspectorModal> {
  ModalTab _modalTab = ModalTab.response;

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final statusColor = transaction != null
        ? (transaction.statusCode >= 200 && transaction.statusCode < 300
            ? Colors.green
            : (transaction.statusCode >= 400 || transaction.statusCode == 0 
                ? Colors.red 
                : Colors.orange))
        : Colors.green;

    return SqaModal<bool>.custom(
      title: widget.isHistory ? 'Transaction Inspector' : 'Response',
      scrollable: false,
      leading: SqaStatusBadge(
        text: transaction != null 
            ? (transaction.statusCode == 0 ? 'ERR' : '${transaction.statusCode}') 
            : '...',
        color: statusColor,
      ),
      confirmLabel: 'Done',
      customActions: [
        SqaButton.tonal(
          icon: Symbols.send,
          onPressed: () {
            Navigator.of(context).pop(false);
            widget.onSendAgain?.call();
          },
          label: widget.transaction == null ? 'Send' : 'Send Again',
        ),
        const SizedBox(width: SqaTokens.spacingSmall),
        SqaButton.primary(
          onPressed: () => Navigator.of(context).pop(true),
          label: 'Done',
        ),
      ],
      topBar: Row(
        children: [
          Expanded(
            flex: 3,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  SqaMetadataItem(
                    icon: Symbols.timer,
                    text: transaction != null
                        ? '${transaction.latency.inMilliseconds} ms'
                        : '0 ms',
                  ),
                  const SizedBox(width: SqaTokens.spacingMedium),
                  SqaMetadataItem(
                    icon: Symbols.database,
                    text: transaction != null
                        ? '${(transaction.responseSize / 1024).toStringAsFixed(2)} KB'
                        : '0 KB',
                  ),
                ],
              ),
            ),
          ),
          if (widget.isHistory) ...[
            const SizedBox(width: SqaTokens.spacingLarge),
            SqaSegmentedButton<ModalTab>(
              stretches: false,
              minScale: 0.8,
              segments: const [
                ButtonSegment(
                  value: ModalTab.request,
                  label: Text('REQ'),
                  icon: Icon(Symbols.send, size: SqaTokens.spacingLarge),
                ),
                ButtonSegment(
                  value: ModalTab.response,
                  label: Text('RES'),
                  icon: Icon(Symbols.data_object, size: SqaTokens.spacingLarge),
                ),
              ],
              selected: {_modalTab},
              onSelectionChanged: (v) {
                setState(() => _modalTab = v.first);
              },
            ),
          ],
        ],
      ),
      child: _modalTab == ModalTab.request
          ? _buildRequestModalContent(context, transaction)
          : _buildResponseContent(context, transaction),
    );
  }

  Widget _buildRequestModalContent(BuildContext context, CurlTransaction? transaction) {
    return SqaField(
      label: 'cURL Command',
      showLabel: false,
      isMonospace: true,
      readOnly: true,
      isMultiline: true,
      maxLines: null,
      expands: true,
      fontSize: SqaTokens.fontSizeSmall,
      showCopyButton: false,
      showLineNumbers: true,
      initialValue: transaction != null
          ? CurlParserService.stringify(transaction.resolvedRequest ?? transaction.request)
          : 'No request data available',
    );
  }

  Widget _buildResponseContent(BuildContext context, CurlTransaction? transaction) {
    return SqaField(
      label: 'Response Output',
      showLabel: false,
      isMonospace: true,
      readOnly: true,
      isMultiline: true,
      maxLines: null,
      expands: true,
      fontSize: SqaTokens.fontSizeSmall,
      showCopyButton: false,
      showLineNumbers: true,
      initialValue: transaction?.responseBody ?? 'No response data available',
    );
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../security_payload_models.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_field.dart';

class PayloadCard extends StatefulWidget {
  final SecurityPayload payload;

  const PayloadCard({super.key, required this.payload});

  @override
  State<PayloadCard> createState() => _PayloadCardState();
}

class _PayloadCardState extends State<PayloadCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.payload;

    return SqaCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SqaField(
            label: p.name,
            initialValue: p.payload,
            readOnly: true,
            isMonospace: true,
            trailing: IconButton(
              icon: Icon(
                _isExpanded ? Symbols.expand_less : Symbols.info,
                size: 16,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              tooltip: 'Learn more about this payload',
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildInfoRow('Description', p.description),
            const SizedBox(height: 8),
            _buildInfoRow('How to Test', p.howToTest),
            const SizedBox(height: 8),
            _buildInfoRow(
              'Success Indicator',
              p.successIndicator,
              isHighlight: true,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'RISK LEVEL: ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                _buildRiskBadge(p.risk),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            fontWeight: isHighlight ? FontWeight.w500 : FontWeight.normal,
            color: isHighlight ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskBadge(PayloadRisk risk) {
    Color color;
    switch (risk) {
      case PayloadRisk.low:
        color = Colors.green;
        break;
      case PayloadRisk.medium:
        color = Colors.orange;
        break;
      case PayloadRisk.high:
        color = Colors.red;
        break;
      case PayloadRisk.critical:
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        risk.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

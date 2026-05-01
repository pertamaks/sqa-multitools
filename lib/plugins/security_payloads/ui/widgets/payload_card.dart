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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final p = widget.payload;

    return SqaCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildRiskIndicator(p.risk),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isExpanded ? Symbols.expand_less : Symbols.info,
                  size: 20,
                  color: _isExpanded
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                tooltip: 'Learn more about this payload',
              ),
            ],
          ),
          const SizedBox(height: 12),
          SqaField(
            label: 'PAYLOAD',
            initialValue: p.payload,
            readOnly: true,
            isMonospace: true,
            showCopyButton: true,
            wrap: false, // Enable horizontal scrolling for long content
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow('HOW TO TEST', p.howToTest, Symbols.experiment),
            const SizedBox(height: 12),
            _buildDetailRow(
              'SUCCESS INDICATOR',
              p.successIndicator,
              Symbols.check_circle,
              isHighlight: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon,
      {bool isHighlight = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color:
              isHighlight ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: isHighlight ? FontWeight.w500 : FontWeight.normal,
                  color: isHighlight ? colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskIndicator(PayloadRisk risk) {
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
      case PayloadRisk.info:
        color = Colors.blue;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../security_payload_models.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';

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
      margin: const EdgeInsets.only(bottom: SqaTokens.spacingMedium),
      padding: const EdgeInsets.all(SqaTokens.spacingLarge),
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
                        fontSize: SqaTokens.spacingLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: SqaTokens.spacingSmall),
                    Row(
                      children: [
                        _buildRiskIndicator(p.risk),
                        const SizedBox(width: SqaTokens.spacingMedium),
                        Expanded(
                          child: Text(
                            p.description,
                            style: TextStyle(
                              fontSize: SqaTokens.spacingMedium,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SqaHoverIconButton(
                icon: _isExpanded ? Symbols.expand_less : Symbols.info,
                iconSize: SqaTokens.spacingXLarge,
                color: _isExpanded
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                tooltip: 'Learn more about this payload',
              ),
            ],
          ),
          const SizedBox(height: SqaTokens.spacingMedium),
          SqaField(
            label: 'PAYLOAD',
            initialValue: p.payload,
            readOnly: true,
            isMonospace: true,
            showCopyButton: true,
            wrap: false, // Enable horizontal scrolling for long content
          ),
          if (_isExpanded) ...[
            const SizedBox(height: SqaTokens.spacingLarge),
            const Divider(),
            const SizedBox(height: SqaTokens.spacingLarge),
            _buildDetailRow('HOW TO TEST', p.howToTest, Symbols.experiment),
            const SizedBox(height: SqaTokens.spacingMedium),
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

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon, {
    bool isHighlight = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: SqaTokens.spacingLarge,
          color: isHighlight
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: SqaTokens.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: SqaTokens.fontSizeSmall,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: SqaTokens.spacingXSmall),
              Text(
                value,
                style: TextStyle(
                  fontSize: SqaTokens.spacingMedium,
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
      width: SqaTokens.spacingSmall,
      height: SqaTokens.spacingSmall,
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

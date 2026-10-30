import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:intl/intl.dart';
import '../../models/omniconverter_state.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../ui/widgets/sqa_status_badge.dart';

class JwtInspectorCard extends StatelessWidget {
  final OmniConverterState state;

  const JwtInspectorCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final jwt = state.jwtInfo;
    if (jwt == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return SqaCard(
      padding: const EdgeInsets.all(SqaTokens.spacingMedium),
      margin: const EdgeInsets.only(bottom: SqaTokens.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.verified_user, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: SqaTokens.spacingSmall),
              Text(
                'JWT CLAIMS & STATUS',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              if (jwt.isExpired)
                const SqaStatusBadge(
                  text: 'EXPIRED',
                  color: Colors.red,
                )
              else if (jwt.expiresAt != null)
                const SqaStatusBadge(
                  text: 'ACTIVE',
                  color: Colors.green,
                ),

            ],
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
          Wrap(
            spacing: SqaTokens.spacingLarge,
            runSpacing: SqaTokens.spacingXSmall,
            children: [
              if (jwt.header['alg'] != null)
                _buildInfoItem(context, 'Algorithm', jwt.header['alg'].toString()),
              if (jwt.expiresAt != null)
                _buildInfoItem(context, 'Expires At (exp)', dateFormat.format(jwt.expiresAt!)),
              if (jwt.issuedAt != null)
                _buildInfoItem(context, 'Issued At (iat)', dateFormat.format(jwt.issuedAt!)),
              if (jwt.payload['sub'] != null)
                _buildInfoItem(context, 'Subject (sub)', jwt.payload['sub'].toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

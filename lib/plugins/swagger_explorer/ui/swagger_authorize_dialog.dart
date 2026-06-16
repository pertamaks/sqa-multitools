import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../providers/swagger_provider.dart';

class SwaggerAuthorizeDialog extends ConsumerWidget {
  const SwaggerAuthorizeDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(swaggerProvider);
    final schemas = state.activeSchema?.securitySchemes ?? {};
    final activeValues = state.activeSecurityValues;

    if (schemas.isEmpty) {
      return AlertDialog(
        title: const Text('Available Authorizations'),
        content: const Text('No security schemes are defined in this API.'),
        actions: [
          SqaButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
            type: SqaButtonType.primary,
          ),
        ],
      );
    }

    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Symbols.lock, color: theme.colorScheme.primary),
          const SizedBox(width: SqaTokens.spacingMedium),
          const Text('Available Authorizations'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: schemas.entries.map((entry) {
              final key = entry.key;
              final scheme = entry.value;
              final currentValue = activeValues[key];

              return Container(
                margin: const EdgeInsets.only(bottom: SqaTokens.spacingLarge),
                padding: const EdgeInsets.all(SqaTokens.spacingMedium),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: SqaTokens.borderRadiusSmall,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          key,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentValue != null && currentValue.isNotEmpty)
                          Text(
                            'Authorized',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: SqaTokens.spacingSmall),
                    if (scheme.type.isNotEmpty)
                      Text('Type: ${scheme.type}', style: theme.textTheme.bodySmall),
                    if (scheme.inLocation != null)
                      Text('In: ${scheme.inLocation}', style: theme.textTheme.bodySmall),
                    if (scheme.name != null)
                      Text('Name: ${scheme.name}', style: theme.textTheme.bodySmall),
                    if (scheme.scheme != null)
                      Text('Scheme: ${scheme.scheme}', style: theme.textTheme.bodySmall),
                    if (scheme.description != null && scheme.description!.isNotEmpty) ...[
                      const SizedBox(height: SqaTokens.spacingSmall),
                      Text(scheme.description!, style: theme.textTheme.bodyMedium),
                    ],
                    const SizedBox(height: SqaTokens.spacingMedium),
                    SqaField(
                      label: 'Value',
                      initialValue: currentValue,
                      onChanged: (val) {
                        if (val.trim().isEmpty) {
                          ref.read(swaggerProvider.notifier).removeSecurityValue(key);
                        } else {
                          ref.read(swaggerProvider.notifier).setSecurityValue(key, val.trim());
                        }
                      },
                    ),
                    if (currentValue != null && currentValue.isNotEmpty) ...[
                      const SizedBox(height: SqaTokens.spacingMedium),
                      SqaButton(
                        label: 'Logout',
                        type: SqaButtonType.tonal,
                        onPressed: () {
                          ref.read(swaggerProvider.notifier).removeSecurityValue(key);
                        },
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        SqaButton(
          label: 'Close',
          onPressed: () => Navigator.pop(context),
          type: SqaButtonType.primary,
        ),
      ],
    );
  }
}

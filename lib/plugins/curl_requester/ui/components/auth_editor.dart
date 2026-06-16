import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/curl_requester_provider.dart';
import '../../models/curl_command.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'curl_requester_grid_row.dart';

class AuthEditor extends ConsumerWidget {
  final VoidCallback onSyncRaw;

  const AuthEditor({super.key, required this.onSyncRaw});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(curlRequesterProvider);
    final command = state.currentCommand;
    final notifier = ref.read(curlRequesterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AUTHORIZATION',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: SqaTokens.fontSizeSmall,
                  ),
            ),
            SqaPopupMenu(
              icon: Symbols.arrow_drop_down,
              builder: (context, controller, child) {
                String label = command.authMethod.name;
                if (command.authMethod == AuthMethod.none) label = 'No Auth';
                if (command.authMethod == AuthMethod.bearerToken) label = 'Bearer Token';
                if (command.authMethod == AuthMethod.basicAuth) label = 'Basic Auth';
                if (command.authMethod == AuthMethod.apiKey) label = 'API Key';
                return InkWell(
                  onTap: () {
                    if (controller.isOpen) {
                      controller.close();
                    } else {
                      controller.open();
                    }
                  },
                  borderRadius: SqaTokens.borderRadiusSmall,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingXSmall, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Symbols.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                );
              },
              children: AuthMethod.values.map((m) {
                String label = m.name;
                if (m == AuthMethod.none) label = 'No Auth';
                if (m == AuthMethod.bearerToken) label = 'Bearer Token';
                if (m == AuthMethod.basicAuth) label = 'Basic Auth';
                if (m == AuthMethod.apiKey) label = 'API Key';
                return SqaPopupMenuItem(
                  onPressed: () {
                    notifier.updateCommand(command.copyWith(authMethod: m));
                    onSyncRaw();
                  },
                  icon: const Icon(Symbols.security, size: 16),
                  label: label,
                );
              }).toList(),
            ),
          ],
        ),
        const SizedBox(height: SqaTokens.spacingMedium),
        SqaCard(
          child: Column(
            children: [
              if (command.authMethod == AuthMethod.none)
                const Padding(
                  padding: EdgeInsets.all(SqaTokens.spacingXXLarge),
                  child: Center(child: Text('This request does not use any authorization.')),
                ),
              if (command.authMethod == AuthMethod.bearerToken)
                CurlRequesterGridRow(
                  label: 'Token',
                  value: command.authData['token'] ?? '',
                  readOnlyValue: false,
                  showCheckbox: false,
                  onChanged: (_, v) {
                    final data = Map<String, String>.from(command.authData);
                    data['token'] = v;
                    notifier.updateCommand(command.copyWith(authData: data));
                    onSyncRaw();
                  },
                ),
              if (command.authMethod == AuthMethod.basicAuth) ...[
                CurlRequesterGridRow(
                  label: 'Username',
                  value: command.authData['username'] ?? '',
                  readOnlyValue: false,
                  showCheckbox: false,
                  onChanged: (_, v) {
                    final data = Map<String, String>.from(command.authData);
                    data['username'] = v;
                    notifier.updateCommand(command.copyWith(authData: data));
                    onSyncRaw();
                  },
                ),
                const Divider(height: 1, indent: SqaTokens.spacingLarge, endIndent: SqaTokens.spacingLarge),
                CurlRequesterGridRow(
                  label: 'Password',
                  value: command.authData['password'] ?? '',
                  readOnlyValue: false,
                  showCheckbox: false,
                  onChanged: (_, v) {
                    final data = Map<String, String>.from(command.authData);
                    data['password'] = v;
                    notifier.updateCommand(command.copyWith(authData: data));
                    onSyncRaw();
                  },
                ),
              ],
              if (command.authMethod == AuthMethod.apiKey) ...[
                CurlRequesterGridRow(
                  label: 'Key',
                  value: command.authData['key'] ?? '',
                  readOnlyValue: false,
                  showCheckbox: false,
                  onChanged: (_, v) {
                    final data = Map<String, String>.from(command.authData);
                    data['key'] = v;
                    notifier.updateCommand(command.copyWith(authData: data));
                    onSyncRaw();
                  },
                ),
                const Divider(height: 1, indent: SqaTokens.spacingLarge, endIndent: SqaTokens.spacingLarge),
                CurlRequesterGridRow(
                  label: 'Value',
                  value: command.authData['value'] ?? '',
                  readOnlyValue: false,
                  showCheckbox: false,
                  onChanged: (_, v) {
                    final data = Map<String, String>.from(command.authData);
                    data['value'] = v;
                    notifier.updateCommand(command.copyWith(authData: data));
                    onSyncRaw();
                  },
                ),
                const Divider(height: 1, indent: SqaTokens.spacingLarge, endIndent: SqaTokens.spacingLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingLarge, vertical: SqaTokens.spacingSmall),
                  child: Row(
                    children: [
                      const Expanded(flex: 2, child: Text('Add To', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(
                        flex: 3,
                        child: SqaPopupMenu(
                          icon: Symbols.arrow_drop_down,
                          builder: (context, controller, child) {
                            return InkWell(
                              onTap: () {
                                if (controller.isOpen) {
                                  controller.close();
                                } else {
                                  controller.open();
                                }
                              },
                              borderRadius: SqaTokens.borderRadiusSmall,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingXSmall, vertical: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(command.authData['addTo'] ?? 'Header', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 4),
                                    const Icon(Symbols.arrow_drop_down, size: 16),
                                  ],
                                ),
                              ),
                            );
                          },
                          children: ['Header', 'Query Parameter'].map((m) {
                            return SqaPopupMenuItem(
                              onPressed: () {
                                final data = Map<String, String>.from(command.authData);
                                data['addTo'] = m;
                                notifier.updateCommand(command.copyWith(authData: data));
                                onSyncRaw();
                              },
                              icon: const Icon(Symbols.list, size: 16),
                              label: m,
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

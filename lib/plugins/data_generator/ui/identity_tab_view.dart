import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../models/identity_state.dart';
import '../providers/identity_provider.dart';
import '../widgets/identity_config_panel.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';

class IdentityTabView extends ConsumerStatefulWidget {
  const IdentityTabView({super.key});

  @override
  ConsumerState<IdentityTabView> createState() => _IdentityTabViewState();
}

class _IdentityTabViewState extends ConsumerState<IdentityTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(identityProvider);
    final notifier = ref.read(identityProvider.notifier);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaSegmentedButton<IdentityType>(
            segments: const [
              ButtonSegment(
                value: IdentityType.name,
                label: Text('Name'),
                icon: Icon(Symbols.person),
              ),
              ButtonSegment(
                value: IdentityType.email,
                label: Text('Email'),
                icon: Icon(Symbols.mail),
              ),
              ButtonSegment(
                value: IdentityType.address,
                label: Text('Address'),
                icon: Icon(Symbols.home),
              ),
              ButtonSegment(
                value: IdentityType.phone,
                label: Text('Phone'),
                icon: Icon(Symbols.call),
              ),
              ButtonSegment(
                value: IdentityType.internet,
                label: Text('Net'),
                icon: Icon(Symbols.language),
              ),
              ButtonSegment(
                value: IdentityType.company,
                label: Text('Work'),
                icon: Icon(Symbols.business),
              ),
            ],
            selected: {state.selectedType},
            onSelectionChanged: (set) => notifier.setType(set.first),
          ),
          const SizedBox(height: 12),
          Text(
            _getUsageDescription(state.selectedType),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const IdentityConfigPanel(),
          if ((state.resultsMap[state.selectedType] ?? <String>[])
              .isNotEmpty) ...[
            const SizedBox(height: 24),
            SqaField(
              label: 'Result',
              initialValue: state.includeFormatting
                  ? (state.resultsMap[state.selectedType] ?? <String>[])
                        .map((String e) => '• $e')
                        .join('\n')
                  : (state.resultsMap[state.selectedType] ?? <String>[]).join(
                      '\n',
                    ),
              icon: Symbols.content_copy,
              isMultiline: true,
              collapsedMaxLines: 10,
            ),
          ],
        ],
      ),
    );
  }

  String _getUsageDescription(IdentityType type) {
    switch (type) {
      case IdentityType.email:
        return 'Generate realistic email addresses with optional custom domains.';
      case IdentityType.address:
        return 'Generate localized physical mailing addresses.';
      case IdentityType.phone:
        return 'Generate formatted phone numbers with optional extensions.';
      case IdentityType.internet:
        return 'Generate mock URLs, User-Agents, and IP addresses.';
      case IdentityType.company:
        return 'Generate company names, job titles, and professional catchphrases.';
      case IdentityType.name:
        return 'Generate localized full names including first and last names.';
    }
  }
}

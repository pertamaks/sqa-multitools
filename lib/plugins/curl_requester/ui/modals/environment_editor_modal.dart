import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../models/environment.dart';
import '../../providers/environments_provider.dart';

class EnvironmentEditorModal extends ConsumerStatefulWidget {
  final Environment environment;

  const EnvironmentEditorModal({super.key, required this.environment});

  static Future<void> show(BuildContext context, Environment env) {
    return showDialog<void>(
      context: context,
      builder: (context) => EnvironmentEditorModal(environment: env),
    );
  }

  @override
  ConsumerState<EnvironmentEditorModal> createState() => _EnvironmentEditorModalState();
}

class _EnvironmentEditorModalState extends ConsumerState<EnvironmentEditorModal> {
  late TextEditingController _nameController;
  late List<MapEntry<TextEditingController, TextEditingController>> _variables;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.environment.name);
    _variables = widget.environment.variables.entries.map((e) => 
      MapEntry(TextEditingController(text: e.key), TextEditingController(text: e.value))
    ).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final e in _variables) {
      e.key.dispose();
      e.value.dispose();
    }
    super.dispose();
  }

  void _save() {
    final Map<String, String> newVars = {};
    for (final e in _variables) {
      final k = e.key.text.trim();
      if (k.isNotEmpty) {
        newVars[k] = e.value.text;
      }
    }

    final newEnv = widget.environment.copyWith(
      name: _nameController.text.trim().isEmpty ? 'Unnamed' : _nameController.text.trim(),
      variables: newVars,
    );

    ref.read(environmentsProvider.notifier).updateEnvironment(newEnv);
    Navigator.of(context).pop();
  }

  void _delete() async {
    final theme = Theme.of(context);
    final confirm = await SqaModal.showConfirm(
      context,
      title: 'Delete Environment',
      message: 'Are you sure you want to delete this environment?',
      confirmLabel: 'Delete',
      confirmColor: theme.colorScheme.error,
      icon: Symbols.delete_forever,
    );
    if (confirm == true) {
      ref.read(environmentsProvider.notifier).removeEnvironment(widget.environment.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SqaModal<void>.custom(
      title: 'Edit Environment',
      icon: Symbols.language,
      customActions: [
        if (widget.environment.id != 'default')
          TextButton.icon(
            onPressed: _delete,
            icon: Icon(Symbols.delete, color: theme.colorScheme.error),
            label: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: SqaTokens.spacingSmall),
        SqaButton.primary(
          label: 'Save',
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaField(
            label: 'Environment Name',
            controller: _nameController,
            hintText: 'e.g., Production, Staging',
            readOnly: widget.environment.id == 'default',
          ),
          const SizedBox(height: SqaTokens.spacingLarge),
          Text(
            'Variables',
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ..._variables.asMap().entries.map((entry) {
                    final index = entry.key;
                    final row = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: SqaTokens.spacingSmall),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isCompact = constraints.maxWidth < 450;
                          
                          final keyField = SqaField(
                            label: '',
                            showLabel: false,
                            hintText: 'Variable Name (e.g. API_URL)',
                            controller: row.key,
                            isMonospace: true,
                          );

                          final valueField = SqaField(
                            label: '',
                            showLabel: false,
                            hintText: 'Value',
                            controller: row.value,
                            isMonospace: true,
                          );

                          final deleteBtn = SqaHoverIconButton(
                            icon: Symbols.delete,
                            onPressed: () {
                              setState(() {
                                _variables.removeAt(index);
                              });
                            },
                            tooltip: 'Delete Variable',
                            color: theme.colorScheme.error,
                          );

                          if (isCompact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: keyField),
                                    const SizedBox(width: SqaTokens.spacingSmall),
                                    deleteBtn,
                                  ],
                                ),
                                const SizedBox(height: SqaTokens.spacingXXSmall),
                                Row(
                                  children: [
                                    const SizedBox(width: SqaTokens.spacingXLarge),
                                    const Icon(Symbols.subdirectory_arrow_right, size: 16, color: Colors.grey),
                                    const SizedBox(width: SqaTokens.spacingSmall),
                                    Expanded(child: valueField),
                                  ],
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: keyField),
                              const SizedBox(width: SqaTokens.spacingSmall),
                              Expanded(flex: 2, child: valueField),
                              const SizedBox(width: SqaTokens.spacingSmall),
                              deleteBtn,
                            ],
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: SqaTokens.spacingSmall),
                  SqaButton.tonal(
                    label: 'Add Variable',
                    icon: Symbols.add,
                    onPressed: () {
                      setState(() {
                        _variables.add(MapEntry(TextEditingController(), TextEditingController()));
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../providers/environments_provider.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../core/services/faker_resolution_service.dart';

class CurlVariableInfoButton extends ConsumerStatefulWidget {
  final TextEditingController controller;

  const CurlVariableInfoButton({super.key, required this.controller});

  @override
  ConsumerState<CurlVariableInfoButton> createState() =>
      _CurlVariableInfoButtonState();
}

class _CurlVariableInfoButtonState
    extends ConsumerState<CurlVariableInfoButton> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant CurlVariableInfoButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to update the tooltip string
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final RegExp varPattern = RegExp(r'\{\{(.*?)\}\}');
    final matches = varPattern.allMatches(text);

    if (matches.isEmpty) {
      return const SizedBox.shrink();
    }

    final envs = ref.watch(environmentsProvider);
    final activeId = ref.watch(activeEnvironmentIdProvider);
    final activeEnv = envs.firstWhere(
      (e) => e.id == activeId,
      orElse: () => envs.first,
    );

    final List<String> lines = [];
    final Set<String> processedVars = {};

    for (final match in matches) {
      final varName = match.group(1)!.trim();
      if (processedVars.contains(varName)) continue;
      processedVars.add(varName);

      if (varName.startsWith('faker.')) {
        try {
          final resolved = FakerResolutionService.resolve('{{$varName}}');
          lines.add('$varName = $resolved (Dynamic)');
        } catch (e) {
          lines.add('$varName = (Undefined Faker variable)');
        }
      } else {
        if (activeEnv.variables.containsKey(varName)) {
          lines.add('$varName = ${activeEnv.variables[varName]}');
        } else {
          lines.add('$varName = (Undefined)');
        }
      }
    }

    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final tooltipText = lines.join('\n');

    return Tooltip(
      message: tooltipText,
      waitDuration: const Duration(milliseconds: 300),
      textStyle: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
      child: SqaHoverIconButton(
        icon: Symbols.info,
        color: Theme.of(context).colorScheme.primary,
        onPressed: () {
          // Just an info button, doing nothing on press but shows tooltip on hover
        },
      ),
    );
  }
}

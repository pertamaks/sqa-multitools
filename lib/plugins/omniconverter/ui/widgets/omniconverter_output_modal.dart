import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/omniconverter_state.dart';
import '../../models/conversion_types.dart';
import 'jwt_inspector_card.dart';
import 'hash_results_list.dart';
import '../../../../ui/widgets/sqa_modal.dart';
import '../../../../ui/widgets/sqa_button.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_toast.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';

class OmniConverterOutputModal extends StatelessWidget {
  final OmniConverterState state;

  const OmniConverterOutputModal({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final title = _getModalTitle(state);

    return SqaModal<void>.custom(
      title: title,
      scrollable: false,
      confirmLabel: 'Close',
      customActions: [
        if (state.category != ConversionCategory.hash)
          SqaButton.tonal(
            label: 'Copy',
            icon: Symbols.content_copy,
            onPressed: () {
              if (state.output.isNotEmpty) {
                Clipboard.setData(ClipboardData(text: state.output));
                SqaToast.show(
                  context,
                  'Output copied to clipboard',
                  type: SqaToastType.success,
                );
              }
            },
          ),
        const SizedBox(width: SqaTokens.spacingSmall),
        SqaButton.primary(
          label: 'Close',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (state.category == ConversionCategory.jwt && state.jwtInfo != null)
            JwtInspectorCard(state: state),
          Expanded(
            child: state.category == ConversionCategory.hash
                ? HashResultsList(hashes: state.hashes)
                : SqaField(
                    label: 'Output',
                    showLabel: false,
                    isMonospace: true,
                    readOnly: true,
                    isMultiline: true,
                    maxLines: null,
                    expands: true,
                    fontSize: SqaTokens.spacingMedium,
                    showLineNumbers: true,
                    showCopyButton: false,
                    initialValue: state.output,
                  ),
          ),
        ],
      ),
    );
  }

  String _getModalTitle(OmniConverterState state) {
    switch (state.category) {
      case ConversionCategory.encoding:
        final mode = state.encodingMode.name.toUpperCase();
        final dir = state.direction == ConversionDirection.forward ? 'ENCODED' : 'DECODED';
        return '$mode $dir Result';
      case ConversionCategory.format:
        return 'Formatted Output';
      case ConversionCategory.jwt:
        return 'Decoded JWT Payload';
      case ConversionCategory.hash:
        return 'Generated Hashes & Checksums';
      case ConversionCategory.textCase:
        return 'Transformed Text';
    }
  }
}

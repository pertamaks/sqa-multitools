import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_toast.dart';

class ConversionEditorPanel extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String placeholder;
  final bool isReadOnly;
  final Widget? trailingHeader;
  final VoidCallback? onClear;
  final ValueChanged<String>? onChanged;

  const ConversionEditorPanel({
    super.key,
    required this.title,
    required this.controller,
    required this.placeholder,
    this.isReadOnly = false,
    this.trailingHeader,
    this.onClear,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SqaCard(
      padding: const EdgeInsets.all(SqaTokens.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              ?trailingHeader,
              if (!isReadOnly && onClear != null)


                SqaHoverIconButton(
                  icon: Symbols.clear_all,
                  tooltip: 'Clear input',
                  onPressed: onClear!,
                ),
              SqaHoverIconButton(
                icon: Symbols.content_copy,
                tooltip: 'Copy to clipboard',
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: controller.text));
                    SqaToast.show(context, 'Copied to clipboard');
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: SqaTokens.spacingSmall),
          Expanded(
            child: SqaField(
              label: title,
              showLabel: false,
              controller: controller,
              readOnly: isReadOnly,
              isMultiline: true,
              isMonospace: true,
              expands: true,
              hintText: placeholder,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(height: SqaTokens.spacingXSmall),

          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final chars = value.text.length;
              final lines = value.text.isEmpty ? 0 : value.text.split('\n').length;
              return Text(
                '$chars chars • $lines lines',
                textAlign: TextAlign.end,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

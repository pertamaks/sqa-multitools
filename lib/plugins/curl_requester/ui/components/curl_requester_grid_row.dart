import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';

class CurlRequesterGridRow extends StatelessWidget {
  final String label;
  final String value;
  final bool? hasFaker;
  final int depth;
  final bool isParent;
  final bool showCheckbox;
  final void Function(String label, String value)? onChanged;

  const CurlRequesterGridRow({
    super.key,
    required this.label,
    required this.value,
    this.hasFaker,
    this.depth = 0,
    this.isParent = false,
    this.showCheckbox = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final showFaker = hasFaker ?? !isParent;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0 + (depth * 24.0), 8, 16, 8),
      child: Row(
        children: [
          if (showCheckbox) ...[
            SqaHoverIconButton(
              icon: Symbols.check_box,
              onPressed: () {
                // TODO(Logic): Implement toggle active state for the row in the provider
              },
              tooltip: 'Toggle Active',
              iconSize: 20,
              color: !isParent
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 4),
          ],
          if (isParent)
            const Icon(
              Symbols.keyboard_arrow_down,
              size: 16,
              color: Colors.grey,
            )
          else
            const SizedBox(width: 16),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: SqaField(
              label: '',
              showLabel: false,
              initialValue: label,
              isMonospace: true,
              fontSize: 12,
              showCopyButton: false,
              onChanged: (String v) {
                // TODO(Logic): Wire up label changes to the onChanged callback
                onChanged?.call(v, value);
              },
              fontWeight: isParent ? FontWeight.bold : FontWeight.normal,
              color: isParent
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(Symbols.chevron_right, size: 16, color: Colors.grey),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: SqaField(
                    label: '',
                    showLabel: false,
                    initialValue: value,
                    isMonospace: true,
                    fontSize: 12,
                    showCopyButton: false,
                    onChanged: (String v) {
                      // TODO(Logic): Wire up value changes to the onChanged callback
                      onChanged?.call(label, v);
                    },
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (showFaker) ...[
                  const SizedBox(width: 8),
                  SqaPopupMenu(
                    icon: const Icon(Symbols.magic_button),
                    tooltip: 'Faker Data',
                    children: [
                      SqaPopupMenuItem(
                        icon: const Icon(Symbols.person),
                        label: 'Full Name',
                        onPressed: () {
                          // TODO(Logic): Implement Faker Full Name injection
                        },
                      ),
                      SqaPopupMenuItem(
                        icon: const Icon(Symbols.mail),
                        label: 'Email',
                        onPressed: () {
                          // TODO(Logic): Implement Faker Email injection
                        },
                      ),
                      SqaPopupMenuItem(
                        icon: const Icon(Symbols.location_on),
                        label: 'City',
                        onPressed: () {
                          // TODO(Logic): Implement Faker City injection
                        },
                      ),
                      SqaPopupMenuItem(
                        icon: const Icon(Symbols.fingerprint),
                        label: 'Guid',
                        onPressed: () {
                          // TODO(Logic): Implement Faker Guid injection
                        },
                      ),
                    ],
                  ),
                ],
                // TODO(UI): Add a trailing 'Delete Row' icon button here
              ],
            ),
          ),
        ],
      ),
    );
  }
}

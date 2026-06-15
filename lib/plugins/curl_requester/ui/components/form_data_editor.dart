import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';
import 'package:file_selector/file_selector.dart';
import '../../providers/curl_requester_provider.dart';
import '../../providers/environments_provider.dart';
import '../../models/form_data_item.dart';
import 'curl_variable_info_button.dart';
import '../../../../ui/widgets/sqa_card.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';
import '../../../../ui/widgets/sqa_design_tokens.dart';

class FormDataEditor extends ConsumerWidget {
  final VoidCallback onSyncRaw;
  final bool isUrlEncoded;

  const FormDataEditor({super.key, required this.onSyncRaw, this.isUrlEncoded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(curlRequesterProvider);
    final command = state.currentCommand;
    final notifier = ref.read(curlRequesterProvider.notifier);

    final items = isUrlEncoded ? command.urlEncodedData : command.formData;

    void updateItems(List<FormDataItem> newItems) {
      if (isUrlEncoded) {
        notifier.updateCommand(command.copyWith(urlEncodedData: newItems));
      } else {
        notifier.updateCommand(command.copyWith(formData: newItems));
      }
      onSyncRaw();
    }

    Set<String> getVars() {
      final envs = ref.read(environmentsProvider);
      final activeId = ref.read(activeEnvironmentIdProvider);
      return envs.firstWhere((e) => e.id == activeId, orElse: () => envs.first).variables.keys.toSet();
    }

    return SqaCard(
      child: Column(
        children: [
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(SqaTokens.spacingXXLarge),
              child: Center(child: Text('No form data provided')),
            ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              key: ValueKey('form_data_${item.id}'),
              children: [
                _buildFormDataRow(context, item, (FormDataItem newItem) {
                  final newItems = List<FormDataItem>.from(items);
                  newItems[index] = newItem;
                  updateItems(newItems);
                }, () {
                  final newItems = List<FormDataItem>.from(items);
                  newItems.removeAt(index);
                  updateItems(newItems);
                }, getVars),
                const Divider(height: 1, indent: SqaTokens.spacingLarge, endIndent: SqaTokens.spacingLarge),
              ],
            );
          }),
          Padding(
            padding: const EdgeInsets.all(SqaTokens.spacingSmall),
            child: Center(
              child: SqaHoverIconButton(
                icon: Symbols.add,
                onPressed: () {
                  final newItems = List<FormDataItem>.from(items);
                  newItems.add(FormDataItem(id: const Uuid().v4()));
                  updateItems(newItems);
                },
                tooltip: 'Add new row',
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormDataRow(BuildContext context, FormDataItem item, void Function(FormDataItem) onChanged, VoidCallback onDelete, Set<String> Function() getKnownVariables) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 450;
        
        final checkbox = SqaHoverIconButton(
          icon: item.isActive ? Symbols.check_box : Symbols.check_box_outline_blank,
          onPressed: () => onChanged(item.copyWith(isActive: !item.isActive)),
          tooltip: 'Toggle Active',
          iconSize: SqaTokens.spacingXLarge,
          color: item.isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        );
        
        final keyField = SqaField(
          label: '',
          showLabel: false,
          initialValue: item.key,
          isMonospace: true,
          highlightVariables: true,
          getKnownVariables: getKnownVariables,
          fontSize: SqaTokens.spacingMedium,
          showCopyButton: false,
          onChanged: (v) => onChanged(item.copyWith(key: v)),
          color: item.isActive ? Theme.of(context).colorScheme.onSurface : Colors.grey,
        );

        final typeSelector = isUrlEncoded ? const SizedBox.shrink() : SqaPopupMenu(
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
                    Text(item.isFile ? 'File' : 'Text', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 4),
                    const Icon(Symbols.arrow_drop_down, size: 16),
                  ],
                ),
              ),
            );
          },
          children: [false, true].map((isFile) {
            return SqaPopupMenuItem(
              onPressed: () => onChanged(item.copyWith(isFile: isFile)),
              icon: Icon(isFile ? Symbols.file_present : Symbols.text_fields, size: 16),
              label: isFile ? 'File' : 'Text',
            );
          }).toList(),
        );

        final valueField = item.isFile && !isUrlEncoded
            ? Row(
                children: [
                  Expanded(
                    child: Text(
                      item.filePath?.isNotEmpty == true ? item.filePath! : 'Select file...',
                      style: TextStyle(
                        color: item.filePath?.isNotEmpty == true ? Theme.of(context).colorScheme.onSurface : Colors.grey,
                        fontStyle: item.filePath?.isNotEmpty == true ? FontStyle.normal : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SqaHoverIconButton(
                    icon: Symbols.file_open,
                    onPressed: () async {
                      final XFile? file = await openFile();
                      if (file != null) {
                        onChanged(item.copyWith(filePath: file.path));
                      }
                    },
                    tooltip: 'Browse',
                  ),
                ],
              )
            : SqaField(
                label: '',
                showLabel: false,
                initialValue: item.value,
                isMonospace: true,
                highlightVariables: true,
                getKnownVariables: getKnownVariables,
                fontSize: SqaTokens.spacingMedium,
                showCopyButton: false,
                extraFloatingButtonBuilder: (ctrl) => CurlVariableInfoButton(controller: ctrl),
                onChanged: (v) => onChanged(item.copyWith(value: v)),
                color: item.isActive ? Theme.of(context).colorScheme.onSurface : Colors.grey,
              );

        final deleteBtn = SqaHoverIconButton(
          icon: Symbols.delete,
          onPressed: onDelete,
          tooltip: 'Delete Row',
          iconSize: SqaTokens.spacingLarge + 2,
          color: Colors.grey.withValues(alpha: 0.5),
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            SqaTokens.spacingLarge,
            SqaTokens.spacingSmall,
            SqaTokens.spacingLarge,
            SqaTokens.spacingSmall,
          ),
          child: isCompact ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  checkbox,
                  const SizedBox(width: SqaTokens.spacingSmall),
                  Expanded(child: keyField),
                  deleteBtn,
                ],
              ),
              const SizedBox(height: SqaTokens.spacingXXSmall),
              Row(
                children: [
                  const SizedBox(width: SqaTokens.spacingXLarge + SqaTokens.spacingSmall),
                  Icon(Symbols.subdirectory_arrow_right, size: 16, color: item.isActive ? Colors.grey : Colors.grey.withValues(alpha: 0.5)),
                  if (!isUrlEncoded) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingSmall),
                    child: typeSelector,
                  ),
                  const SizedBox(width: SqaTokens.spacingSmall),
                  Expanded(child: valueField),
                ],
              ),
            ],
          ) : Row(
            children: [
              checkbox,
              const SizedBox(width: SqaTokens.spacingSmall),
              Expanded(flex: 2, child: keyField),
              if (!isUrlEncoded) Padding(
                padding: const EdgeInsets.symmetric(horizontal: SqaTokens.spacingSmall),
                child: typeSelector,
              ),
              const SizedBox(width: SqaTokens.spacingSmall),
              Expanded(flex: 3, child: valueField),
              const SizedBox(width: SqaTokens.spacingSmall),
              deleteBtn,
            ],
          ),
        );
      },
    );
  }
}

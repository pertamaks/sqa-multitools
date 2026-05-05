import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../ui/widgets/sqa_field.dart';
import '../../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../../ui/widgets/sqa_popup_menu.dart';

class CurlRequesterGridRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isActive;
  final bool? hasFaker;
  final int depth;
  final bool isParent;
  final bool showCheckbox;
  final bool readOnlyValue;
  final void Function(String label, String value)? onChanged;
  final void Function(bool isActive)? onToggle;
  final VoidCallback? onDelete;

  const CurlRequesterGridRow({
    super.key,
    required this.label,
    required this.value,
    this.isActive = true,
    this.hasFaker,
    this.depth = 0,
    this.isParent = false,
    this.showCheckbox = true,
    this.readOnlyValue = false,
    this.onChanged,
    this.onToggle,
    this.onDelete,
  });

  @override
  State<CurlRequesterGridRow> createState() => _CurlRequesterGridRowState();
}

class _CurlRequesterGridRowState extends State<CurlRequesterGridRow> {
  late TextEditingController _labelController;
  late TextEditingController _valueController;
  late FocusNode _labelFocusNode;
  late FocusNode _valueFocusNode;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.label);
    _valueController = TextEditingController(text: widget.value);
    _labelFocusNode = FocusNode();
    _valueFocusNode = FocusNode();

    _labelFocusNode.addListener(_onFocusChange);
    _valueFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(CurlRequesterGridRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.label != _labelController.text && !_labelFocusNode.hasFocus) {
      _labelController.text = widget.label;
    }
    if (widget.value != _valueController.text && !_valueFocusNode.hasFocus) {
      _valueController.text = widget.value;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    _labelFocusNode.removeListener(_onFocusChange);
    _valueFocusNode.removeListener(_onFocusChange);
    _labelFocusNode.dispose();
    _valueFocusNode.dispose();
    super.dispose();
  }

  bool _isDeleting = false;

  void _onFocusChange() {
    if (!_labelFocusNode.hasFocus && !_valueFocusNode.hasFocus) {
      _commitChanges();
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  void _handleDelete() {
    if (_isDeleting) {
      widget.onDelete?.call();
    } else {
      setState(() => _isDeleting = true);
      // Auto-reset after 3 seconds if not clicked again
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isDeleting) {
          setState(() => _isDeleting = false);
        }
      });
    }
  }

  void _commitChanges() {
    if (_labelController.text != widget.label || _valueController.text != widget.value) {
      widget.onChanged?.call(_labelController.text, _valueController.text);
    }
    // Explicitly remove focus to hide the cursor
    _labelFocusNode.unfocus();
    _valueFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final showFaker = widget.hasFaker ?? !widget.isParent;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: widget.isActive ? 1.0 : 0.4,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0 + (widget.depth * 24.0), 8, 16, 8),
        child: Row(
          children: [
            if (widget.showCheckbox) ...[
              SqaHoverIconButton(
                icon: widget.isActive ? Symbols.check_box : Symbols.check_box_outline_blank,
                onPressed: () => widget.onToggle?.call(!widget.isActive),
                tooltip: 'Toggle Active',
                iconSize: 20,
                color: widget.isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 0),
            ],
            if (widget.isParent)
              Icon(
                Symbols.keyboard_arrow_down,
                size: 16,
                color: widget.isActive ? Colors.grey : Colors.grey.withValues(alpha: 0.5),
              )
            else
              const SizedBox(width: 4),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: SqaField(
                label: '',
                showLabel: false,
                controller: _labelController,
                focusNode: _labelFocusNode,
                isMonospace: true,
                fontSize: 12,
                showCopyButton: false,
                onSubmitted: (_) => _commitChanges(),
                onTapOutside: (_) => _commitChanges(),
                fontWeight: widget.isParent ? FontWeight.bold : FontWeight.normal,
                color: widget.isParent
                    ? (widget.isActive ? Theme.of(context).colorScheme.primary : Colors.grey)
                    : (widget.isActive ? Theme.of(context).colorScheme.onSurface : Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0),
              child: Icon(
                Symbols.chevron_right,
                size: 16,
                color: widget.isActive ? Colors.grey : Colors.grey.withValues(alpha: 0.5),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    child: SqaField(
                      label: '',
                      showLabel: false,
                      controller: _valueController,
                      focusNode: _valueFocusNode,
                      isMonospace: true,
                      fontSize: 12,
                      showCopyButton: false,
                      readOnly: widget.readOnlyValue,
                      onSubmitted: (_) => _commitChanges(),
                      onTapOutside: (_) => _commitChanges(),
                      color: widget.isActive
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.grey,
                    ),
                  ),
                  if (showFaker) ...[
                    const SizedBox(width: 0),
                    SqaPopupMenu(
                      icon: Icon(
                        Symbols.magic_button,
                        color: widget.isActive ? null : Colors.grey.withValues(alpha: 0.5),
                      ),
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
                  if (!widget.isParent && widget.onDelete != null) ...[
                    const SizedBox(width: 0),
                    SqaHoverIconButton(
                      icon: Symbols.delete,
                      onPressed: _handleDelete,
                      tooltip: _isDeleting ? 'Click again to confirm' : 'Delete Row',
                      iconSize: 18,
                      color: _isDeleting
                          ? Theme.of(context).colorScheme.error
                          : Colors.grey.withValues(alpha: 0.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

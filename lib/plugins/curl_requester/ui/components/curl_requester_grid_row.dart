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
  final void Function(String placeholder)? onFakerSelected;
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
    this.onFakerSelected,
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
                      icon: (widget.key.hashCode % 2 == 0) ? Symbols.ifl : Symbols.casino,
                      tooltip: 'Faker Data',
                      children: [
                        SubmenuButton(
                          submenuIcon: const WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14, color: Colors.grey)),
                          menuStyle: MenuStyle(
                            padding: WidgetStateProperty.all(const EdgeInsets.all(4)),
                          ),
                          menuChildren: [
                            _fakerItem(Symbols.person, 'Full Name', 'name'),
                            _fakerItem(Symbols.person_outline, 'First Name', 'firstName'),
                            _fakerItem(Symbols.person_outline, 'Last Name', 'lastName'),
                            _fakerItem(Symbols.work, 'Job Title', 'jobTitle'),
                          ],
                          child: _categoryLabel(Symbols.person, 'Personal'),
                        ),
                        SubmenuButton(
                          submenuIcon: const WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14, color: Colors.grey)),
                          menuChildren: [
                            _fakerItem(Symbols.mail, 'Email', 'email'),
                            _fakerItem(Symbols.account_circle, 'Username', 'username'),
                            _fakerItem(Symbols.password, 'Password', 'password'),
                            _fakerItem(Symbols.phone, 'Phone Number', 'phone'),
                          ],
                          child: _categoryLabel(Symbols.contact_mail, 'Contact'),
                        ),
                        SubmenuButton(
                          submenuIcon: const WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14, color: Colors.grey)),
                          menuChildren: [
                            _fakerItem(Symbols.location_on, 'City', 'city'),
                            _fakerItem(Symbols.home, 'Street Address', 'street'),
                            _fakerItem(Symbols.public, 'Country', 'country'),
                          ],
                          child: _categoryLabel(Symbols.map, 'Location'),
                        ),
                        SubmenuButton(
                          submenuIcon: const WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14, color: Colors.grey)),
                          menuChildren: [
                            _fakerItem(Symbols.fingerprint, 'GUID / UUID', 'guid'),
                            _fakerItem(Symbols.lan, 'IPv4 Address', 'ipv4'),
                            _fakerItem(Symbols.link, 'URL', 'url'),
                            _fakerItem(Symbols.palette, 'Color hex', 'color'),
                          ],
                          child: _categoryLabel(Symbols.terminal, 'Technical'),
                        ),
                        SubmenuButton(
                          submenuIcon: const WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14, color: Colors.grey)),
                          menuChildren: [
                            _fakerItem(Symbols.business, 'Company Name', 'company'),
                            _fakerItem(Symbols.shopping_cart, 'Product Name', 'product'),
                            _fakerItem(Symbols.payments, 'Price', 'price'),
                          ],
                          child: _categoryLabel(Symbols.inventory_2, 'Business'),
                        ),
                        SubmenuButton(
                          submenuIcon: const WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14, color: Colors.grey)),
                          menuChildren: [
                            _fakerItem(Symbols.credit_card, 'Credit Card', 'creditCard'),
                            _fakerItem(Symbols.currency_exchange, 'Currency Code', 'currency'),
                            _fakerItem(Symbols.payments, 'Amount', 'amount'),
                            _fakerItem(Symbols.account_balance, 'Account Number', 'account'),
                          ],
                          child: _categoryLabel(Symbols.savings, 'Finance'),
                        ),
                        SubmenuButton(
                          submenuIcon: const WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14, color: Colors.grey)),
                          menuChildren: [
                            _fakerItem(Symbols.history, 'Past Date', 'pastDate'),
                            _fakerItem(Symbols.update, 'Future Date', 'futureDate'),
                            _fakerItem(Symbols.today, 'Recent Date', 'recentDate'),
                            _fakerItem(Symbols.calendar_month, 'Month', 'month'),
                            _fakerItem(Symbols.calendar_view_day, 'Weekday', 'weekday'),
                          ],
                          child: _categoryLabel(Symbols.calendar_today, 'Date'),
                        ),
                        SubmenuButton(
                          submenuIcon: const WidgetStatePropertyAll(Icon(Symbols.chevron_right, size: 14, color: Colors.grey)),
                          menuChildren: [
                            _fakerItem(Symbols.title, 'Single Word', 'word'),
                            _fakerItem(Symbols.notes, 'Sentence', 'sentence'),
                            _fakerItem(Symbols.description, 'Paragraph', 'paragraph'),
                          ],
                          child: _categoryLabel(Symbols.article, 'Text'),
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

  Widget _categoryLabel(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _fakerItem(IconData icon, String label, String fakerType) {
    return SqaPopupMenuItem(
      icon: Icon(icon),
      label: label,
      onPressed: () {
        _valueController.text = '{{faker.$fakerType}}';
        _commitChanges();
        widget.onFakerSelected?.call('{{faker.$fakerType}}');
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../widgets/sqa_styles.dart';
import '../widgets/sqa_toast.dart';
import '../../core/models/hotkey_info.dart';

class SqaHotkeyField extends StatefulWidget {
  final HotkeyInfo value;
  final void Function(HotkeyInfo) onSave;
  final String? label;

  const SqaHotkeyField({
    super.key,
    required this.value,
    required this.onSave,
    this.label,
  });

  @override
  State<SqaHotkeyField> createState() => _SqaHotkeyFieldState();
}

class _SqaHotkeyFieldState extends State<SqaHotkeyField> {
  bool _isRecording = false;
  final FocusNode _focusNode = FocusNode();
  
  LogicalKeyboardKey? _lastKey;
  final Set<HotKeyModifier> _modifiers = {};

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _lastKey = null;
      _modifiers.clear();
    });
    _focusNode.requestFocus();
  }

  void _stopRecording(bool save) {
    if (save && _lastKey != null) {
      if (_modifiers.isEmpty) {
        SqaToast.show(
          context,
          'Safety Check: Global hotkeys MUST include at least one modifier (Alt, Ctrl, or Shift).',
          type: SqaToastType.error,
        );
        // Don't stop yet if they haven't added a modifier? 
        // Actually it's better to stop and show error like the notifier does.
      }
      
      final info = HotkeyInfo(
        keyCode: _lastKey!.keyId,
        modifierIndices: _modifiers.map((m) => m.index).toList(),
      );
      widget.onSave(info);
    }
    
    setState(() {
      _isRecording = false;
    });
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (!_isRecording) return KeyEventResult.ignored;

        if (event is KeyDownEvent) {
          final key = event.logicalKey;

          // Detect modifiers
          if (key == LogicalKeyboardKey.altLeft ||
              key == LogicalKeyboardKey.altRight) {
            setState(() => _modifiers.add(HotKeyModifier.alt));
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.shiftLeft ||
              key == LogicalKeyboardKey.shiftRight) {
            setState(() => _modifiers.add(HotKeyModifier.shift));
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.controlLeft ||
              key == LogicalKeyboardKey.controlRight) {
            setState(() => _modifiers.add(HotKeyModifier.control));
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.metaLeft ||
              key == LogicalKeyboardKey.metaRight) {
            setState(() => _modifiers.add(HotKeyModifier.meta));
            return KeyEventResult.handled;
          }

          // Detect final key
          // We explicitly check for SPACE and other keys while excluding ESC, ENTER, and TAB
          if (key != LogicalKeyboardKey.escape &&
              key != LogicalKeyboardKey.enter &&
              key != LogicalKeyboardKey.tab) {
            setState(() => _lastKey = key);
            _stopRecording(true);
            return KeyEventResult.handled;
          }

          if (key == LogicalKeyboardKey.escape) {
            _stopRecording(false);
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
          ],
          GestureDetector(
            onTap: _startRecording,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color:
                    _isRecording
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.4,
                        ),
                borderRadius: SqaStyles.radiusSmall,
                border: Border.all(
                  color:
                      _isRecording
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.5),
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isRecording
                        ? Symbols.keyboard
                        : Symbols.keyboard_command_key,
                    size: 16,
                    color:
                        _isRecording
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isRecording
                          ? (_modifiers.isEmpty && _lastKey == null
                              ? 'Press keys...'
                              : _formatRecording())
                          : widget.value.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            _isRecording
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isRecording)
                    const Text(
                      'ESC',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                  else
                    Icon(
                      Symbols.edit,
                      size: 14,
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.5,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRecording() {
    final List<String> parts = [];
    if (_modifiers.contains(HotKeyModifier.alt)) parts.add('ALT');
    if (_modifiers.contains(HotKeyModifier.shift)) parts.add('SHIFT');
    if (_modifiers.contains(HotKeyModifier.control)) parts.add('CTRL');
    if (_modifiers.contains(HotKeyModifier.meta)) parts.add('META');
    
    if (_lastKey != null) {
      parts.add(_lastKey!.keyLabel.toUpperCase());
    }
    
    return parts.join(' + ');
  }
}

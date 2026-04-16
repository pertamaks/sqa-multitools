import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

class HotkeyInfo {
  final int keyCode;
  final List<int> modifierIndices;

  const HotkeyInfo({
    required this.keyCode,
    required this.modifierIndices,
  });

  /// Converts this info to a hotkey_manager HotKey object.
  HotKey toHotKey({String? identifier, HotKeyScope scope = HotKeyScope.system}) {
    return HotKey(
      key: LogicalKeyboardKey(keyCode),
      modifiers: modifierIndices.map((index) => HotKeyModifier.values[index]).toList(),
      identifier: identifier,
      scope: scope,
    );
  }

  /// Creates HotkeyInfo from a hotkey_manager HotKey object.
  factory HotkeyInfo.fromHotKey(HotKey hotKey) {
    final key = hotKey.key;
    int keyCode = 0;
    if (key is LogicalKeyboardKey) {
      keyCode = key.keyId;
    } else if (key is PhysicalKeyboardKey) {
      // Fallback for physical keys if encountered
      keyCode = key.usbHidUsage;
    }
    
    return HotkeyInfo(
      keyCode: keyCode,
      modifierIndices: hotKey.modifiers?.map((m) => m.index).toList() ?? [],
    );
  }

  /// Serialization for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'keyCode': keyCode,
      'modifiers': modifierIndices,
    };
  }

  factory HotkeyInfo.fromJson(Map<String, dynamic> json) {
    return HotkeyInfo(
      keyCode: json['keyCode'] as int,
      modifierIndices: (json['modifiers'] as List).cast<int>(),
    );
  }

  @override
  String toString() {
    final modifiers = modifierIndices
        .map((i) => HotKeyModifier.values[i].toString().split('.').last.toUpperCase())
        .join(' + ');
    final keyLabel = LogicalKeyboardKey(keyCode).keyLabel;
    final key = (keyLabel == ' ' || keyLabel.isEmpty) ? 'SPACE' : keyLabel.toUpperCase();
    return modifiers.isEmpty ? key : '$modifiers + $key';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HotkeyInfo &&
          runtimeType == other.runtimeType &&
          keyCode == other.keyCode &&
          _listEquals(modifierIndices, other.modifierIndices);

  @override
  int get hashCode => keyCode.hashCode ^ modifierIndices.hashCode;
  
  bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
    }
    return true;
  }
}

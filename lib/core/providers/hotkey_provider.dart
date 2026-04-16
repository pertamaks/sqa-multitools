import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../models/hotkey_info.dart';
import '../services/preferences_service.dart';

class HotkeySettings {
  final HotkeyInfo showToolbar;
  final HotkeyInfo recordToggle;

  const HotkeySettings({
    required this.showToolbar,
    required this.recordToggle,
  });

  HotkeySettings copyWith({
    HotkeyInfo? showToolbar,
    HotkeyInfo? recordToggle,
  }) {
    return HotkeySettings(
      showToolbar: showToolbar ?? this.showToolbar,
      recordToggle: recordToggle ?? this.recordToggle,
    );
  }
}

class HotkeySettingsNotifier extends Notifier<HotkeySettings> {
  VoidCallback? _onToolbarToggle;

  @override
  HotkeySettings build() {
    final prefs = ref.watch(preferencesServiceProvider);

    final toolbar =
        prefs.getHotkey(PreferencesService.keyHotkeyShowToolbar) ??
        HotkeyInfo(
          keyCode: LogicalKeyboardKey.space.keyId,
          modifierIndices: [HotKeyModifier.alt.index],
        ); // Alt + Space

    final recorder =
        prefs.getHotkey(PreferencesService.keyHotkeyRecordToggle) ??
        HotkeyInfo(
          keyCode: LogicalKeyboardKey.keyR.keyId,
          modifierIndices: [HotKeyModifier.alt.index],
        ); // Alt + R

    final settings = HotkeySettings(
      showToolbar: toolbar,
      recordToggle: recorder,
    );

    // Initial registration after building
    Future.microtask(() => _registerAll(settings));

    return settings;
  }

  /// Sets the callback to be executed when the toolbar hotkey is pressed.
  void setToolbarCallback(VoidCallback callback) {
    _onToolbarToggle = callback;
    _registerAll(state); // Re-register to apply the new callback
  }

  Future<void> _registerAll(HotkeySettings settings) async {
    await hotKeyManager.unregisterAll();

    // Register Toolbar
    await hotKeyManager.register(
      settings.showToolbar.toHotKey(identifier: 'show_toolbar'),
      keyDownHandler: (_) {
        if (_onToolbarToggle != null) {
          _onToolbarToggle!();
        }
      },
    );

    // Recorder registration is typically managed by ScreenRecorderNotifier 
    // to avoid conflicts with its internal state machine, but we store the preference here.
  }

  /// Updates a hotkey if no conflicts are found and modifiers are present.
  /// Returns null on success, or an error message on failure.
  String? updateHotkey(String key, HotkeyInfo info) {
    // ... validation logic ...
    final error = _validate(key, info);
    if (error != null) return error;

    // 3. Persist and Update State
    final prefs = ref.read(preferencesServiceProvider);
    prefs.setHotkey(key, info);

    if (key == PreferencesService.keyHotkeyShowToolbar) {
      state = state.copyWith(showToolbar: info);
    } else {
      state = state.copyWith(recordToggle: info);
    }

    _registerAll(state);

    return null;
  }

  String? _validate(String key, HotkeyInfo info) {
    if (info.modifierIndices.isEmpty) {
      return 'Safety Check: Global hotkeys MUST include at least one modifier (Alt, Ctrl, or Shift).';
    }

    if (key == PreferencesService.keyHotkeyShowToolbar) {
      if (info == state.recordToggle) {
        return 'Conflict: This shortcut is already assigned to Screen Recorder.';
      }
    } else if (key == PreferencesService.keyHotkeyRecordToggle) {
      if (info == state.showToolbar) {
        return 'Conflict: This shortcut is already assigned to Show Toolbar.';
      }
    }
    return null;
  }
}

final hotkeySettingsProvider = NotifierProvider<HotkeySettingsNotifier, HotkeySettings>(() {
  return HotkeySettingsNotifier();
});

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../models/hotkey_info.dart';
import '../services/preferences_service.dart';

class HotkeySettings {
  final HotkeyInfo showToolbar;
  final HotkeyInfo recordToggle;
  final HotkeyInfo screenshotToggle;

  const HotkeySettings({
    required this.showToolbar,
    required this.recordToggle,
    required this.screenshotToggle,
  });

  HotkeySettings copyWith({
    HotkeyInfo? showToolbar,
    HotkeyInfo? recordToggle,
    HotkeyInfo? screenshotToggle,
  }) {
    return HotkeySettings(
      showToolbar: showToolbar ?? this.showToolbar,
      recordToggle: recordToggle ?? this.recordToggle,
      screenshotToggle: screenshotToggle ?? this.screenshotToggle,
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

    final screenshot =
        prefs.getHotkey(PreferencesService.keyHotkeyScreenshotToggle) ??
        HotkeyInfo(
          keyCode: LogicalKeyboardKey.keyS.keyId,
          modifierIndices: [HotKeyModifier.alt.index],
        ); // Alt + S

    final settings = HotkeySettings(
      showToolbar: toolbar,
      recordToggle: recorder,
      screenshotToggle: screenshot,
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
    } else if (key == PreferencesService.keyHotkeyRecordToggle) {
      state = state.copyWith(recordToggle: info);
    } else if (key == PreferencesService.keyHotkeyScreenshotToggle) {
      state = state.copyWith(screenshotToggle: info);
    }

    _registerAll(state);

    return null;
  }

  String? _validate(String key, HotkeyInfo info) {
    if (info.modifierIndices.isEmpty) {
      return 'Safety Check: Global hotkeys MUST include at least one modifier (Alt, Ctrl, or Shift).';
    }

    if (key == PreferencesService.keyHotkeyShowToolbar) {
      if (info == state.recordToggle)
        return 'Conflict: Shortcut already assigned to Screen Recorder.';
      if (info == state.screenshotToggle)
        return 'Conflict: Shortcut already assigned to Screenshot.';
    } else if (key == PreferencesService.keyHotkeyRecordToggle) {
      if (info == state.showToolbar)
        return 'Conflict: Shortcut already assigned to Show Toolbar.';
      if (info == state.screenshotToggle)
        return 'Conflict: Shortcut already assigned to Screenshot.';
    } else if (key == PreferencesService.keyHotkeyScreenshotToggle) {
      if (info == state.showToolbar)
        return 'Conflict: Shortcut already assigned to Show Toolbar.';
      if (info == state.recordToggle)
        return 'Conflict: Shortcut already assigned to Screen Recorder.';
    }
    return null;
  }
}

final hotkeySettingsProvider =
    NotifierProvider<HotkeySettingsNotifier, HotkeySettings>(() {
      return HotkeySettingsNotifier();
    });

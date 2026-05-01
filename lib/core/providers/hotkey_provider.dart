import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import '../models/hotkey_info.dart';
import '../services/preferences_service.dart';

class HotkeySettings {
  final HotkeyInfo? showToolbar;
  final HotkeyInfo? recordToggle;
  final HotkeyInfo? screenshotToggle;
  final HotkeyInfo? areaRecordToggle;

  const HotkeySettings({
    this.showToolbar,
    this.recordToggle,
    this.screenshotToggle,
    this.areaRecordToggle,
  });

  HotkeySettings copyWith({
    HotkeyInfo? showToolbar,
    HotkeyInfo? recordToggle,
    HotkeyInfo? screenshotToggle,
    HotkeyInfo? areaRecordToggle,
  }) {
    return HotkeySettings(
      showToolbar: showToolbar ?? this.showToolbar,
      recordToggle: recordToggle ?? this.recordToggle,
      screenshotToggle: screenshotToggle ?? this.screenshotToggle,
      areaRecordToggle: areaRecordToggle ?? this.areaRecordToggle,
    );
  }
}

class HotkeySettingsNotifier extends Notifier<HotkeySettings> {
  VoidCallback? _onToolbarToggle;
  VoidCallback? _onAreaRecordToggle;
  VoidCallback? _onRecordToggle;
  VoidCallback? _onScreenshotToggle;

  @override
  HotkeySettings build() {
    final prefs = ref.watch(preferencesServiceProvider);

    final toolbar = prefs.getHotkey(PreferencesService.keyHotkeyShowToolbar);
    final recorder = prefs.getHotkey(PreferencesService.keyHotkeyRecordToggle);
    final screenshot = prefs.getHotkey(PreferencesService.keyHotkeyScreenshotToggle);
    final areaRecord = prefs.getHotkey(PreferencesService.keyHotkeyAreaRecord);

    final settings = HotkeySettings(
      showToolbar: toolbar,
      recordToggle: recorder,
      screenshotToggle: screenshot,
      areaRecordToggle: areaRecord,
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
 
  /// Sets the callback to be executed when the Quick Area Record hotkey is pressed.
  void setAreaRecordCallback(VoidCallback callback) {
    _onAreaRecordToggle = callback;
    _registerAll(state);
  }
 
  /// Sets the callback to be executed when the Record Toggle hotkey is pressed.
  void setRecordToggleCallback(VoidCallback callback) {
    _onRecordToggle = callback;
    _registerAll(state);
  }
 
  /// Sets the callback to be executed when the Screenshot Toggle hotkey is pressed.
  void setScreenshotToggleCallback(VoidCallback callback) {
    _onScreenshotToggle = callback;
    _registerAll(state);
  }

  Future<void> _registerAll(HotkeySettings settings) async {
    await hotKeyManager.unregisterAll();

    // Register Toolbar
    if (settings.showToolbar != null) {
      await hotKeyManager.register(
        settings.showToolbar!.toHotKey(identifier: 'show_toolbar'),
        keyDownHandler: (_) {
          if (_onToolbarToggle != null) {
            _onToolbarToggle!();
          }
        },
      );
    }
 
    // Register Quick Area Record
    if (settings.areaRecordToggle != null) {
      await hotKeyManager.register(
        settings.areaRecordToggle!.toHotKey(identifier: 'area_record'),
        keyDownHandler: (_) {
          if (_onAreaRecordToggle != null) {
            _onAreaRecordToggle!();
          }
        },
      );
    }
 
    // Register Record Toggle
    if (settings.recordToggle != null) {
      await hotKeyManager.register(
        settings.recordToggle!.toHotKey(identifier: 'record_toggle'),
        keyDownHandler: (_) {
          if (_onRecordToggle != null) {
            _onRecordToggle!();
          }
        },
      );
    }
 
    // Register Screenshot Toggle
    if (settings.screenshotToggle != null) {
      await hotKeyManager.register(
        settings.screenshotToggle!.toHotKey(identifier: 'screenshot_toggle'),
        keyDownHandler: (_) {
          if (_onScreenshotToggle != null) {
            _onScreenshotToggle!();
          }
        },
      );
    }
 
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
    } else if (key == PreferencesService.keyHotkeyAreaRecord) {
      state = state.copyWith(areaRecordToggle: info);
    }

    _registerAll(state);

    return null;
  }

  String? _validate(String key, HotkeyInfo info) {
    if (info.modifierIndices.isEmpty) {
      return 'Safety Check: Global hotkeys MUST include at least one modifier (Alt, Ctrl, or Shift).';
    }

    if (key == PreferencesService.keyHotkeyShowToolbar) {
      if (state.recordToggle != null && info == state.recordToggle) {
        return 'Conflict: Shortcut already assigned to Screen Recorder.';
      }
      if (state.screenshotToggle != null && info == state.screenshotToggle) {
        return 'Conflict: Shortcut already assigned to Screenshot.';
      }
    } else if (key == PreferencesService.keyHotkeyRecordToggle) {
      if (state.showToolbar != null && info == state.showToolbar) {
        return 'Conflict: Shortcut already assigned to Show Toolbar.';
      }
      if (state.screenshotToggle != null && info == state.screenshotToggle) {
        return 'Conflict: Shortcut already assigned to Screenshot.';
      }
    } else if (key == PreferencesService.keyHotkeyScreenshotToggle) {
      if (state.showToolbar != null && info == state.showToolbar) {
        return 'Conflict: Shortcut already assigned to Show Toolbar.';
      }
      if (state.recordToggle != null && info == state.recordToggle) {
        return 'Conflict: Shortcut already assigned to Screen Recorder.';
      }
    } else if (key == PreferencesService.keyHotkeyAreaRecord) {
      if (state.showToolbar != null && info == state.showToolbar) {
        return 'Conflict: Shortcut already assigned to Show Toolbar.';
      }
      if (state.recordToggle != null && info == state.recordToggle) {
        return 'Conflict: Shortcut already assigned to Screen Recorder.';
      }
      if (state.screenshotToggle != null && info == state.screenshotToggle) {
        return 'Conflict: Shortcut already assigned to Screenshot.';
      }
    }
    return null;
  }
}

final hotkeySettingsProvider =
    NotifierProvider<HotkeySettingsNotifier, HotkeySettings>(() {
      return HotkeySettingsNotifier();
    });

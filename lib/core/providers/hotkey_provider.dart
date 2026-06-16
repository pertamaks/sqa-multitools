import 'dart:io';
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
  final HotkeyInfo? ssFullscreen;
  final HotkeyInfo? ssArea;
  final HotkeyInfo? ssLong;
  final HotkeyInfo? recFullscreen;

  const HotkeySettings({
    this.showToolbar,
    this.recordToggle,
    this.screenshotToggle,
    this.areaRecordToggle,
    this.ssFullscreen,
    this.ssArea,
    this.ssLong,
    this.recFullscreen,
  });

  HotkeySettings copyWith({
    HotkeyInfo? showToolbar,
    HotkeyInfo? recordToggle,
    HotkeyInfo? screenshotToggle,
    HotkeyInfo? areaRecordToggle,
    HotkeyInfo? ssFullscreen,
    HotkeyInfo? ssArea,
    HotkeyInfo? ssLong,
    HotkeyInfo? recFullscreen,
    bool clearSsFullscreen = false,
    bool clearSsArea = false,
    bool clearSsLong = false,
    bool clearRecFullscreen = false,
    bool clearShowToolbar = false,
    bool clearRecordToggle = false,
    bool clearScreenshotToggle = false,
    bool clearAreaRecordToggle = false,
  }) {
    return HotkeySettings(
      showToolbar:
          clearShowToolbar ? null : (showToolbar ?? this.showToolbar),
      recordToggle:
          clearRecordToggle ? null : (recordToggle ?? this.recordToggle),
      screenshotToggle: clearScreenshotToggle
          ? null
          : (screenshotToggle ?? this.screenshotToggle),
      areaRecordToggle: clearAreaRecordToggle
          ? null
          : (areaRecordToggle ?? this.areaRecordToggle),
      ssFullscreen:
          clearSsFullscreen ? null : (ssFullscreen ?? this.ssFullscreen),
      ssArea: clearSsArea ? null : (ssArea ?? this.ssArea),
      ssLong: clearSsLong ? null : (ssLong ?? this.ssLong),
      recFullscreen: clearRecFullscreen
          ? null
          : (recFullscreen ?? this.recFullscreen),
    );
  }

  /// All hotkey entries as (prefKey, hotkeyInfo) pairs for iteration.
  List<(String, HotkeyInfo?)> get entries => [
        (PreferencesService.keyHotkeyShowToolbar, showToolbar),
        (PreferencesService.keyHotkeyRecordToggle, recordToggle),
        (PreferencesService.keyHotkeyScreenshotToggle, screenshotToggle),
        (PreferencesService.keyHotkeyAreaRecord, areaRecordToggle),
        (PreferencesService.keyHotkeySsFullscreen, ssFullscreen),
        (PreferencesService.keyHotkeySsArea, ssArea),
        (PreferencesService.keyHotkeySsLong, ssLong),
        (PreferencesService.keyHotkeyRecFullscreen, recFullscreen),
      ];
}

class HotkeySettingsNotifier extends Notifier<HotkeySettings> {
  VoidCallback? _onToolbarToggle;
  VoidCallback? _onAreaRecordToggle;
  VoidCallback? _onRecordToggle;
  VoidCallback? _onScreenshotToggle;
  VoidCallback? _onSsFullscreen;
  VoidCallback? _onSsArea;
  VoidCallback? _onSsLong;
  VoidCallback? _onRecFullscreen;

  @override
  HotkeySettings build() {
    final prefs = ref.watch(preferencesServiceProvider);

    final settings = HotkeySettings(
      showToolbar: prefs.getHotkey(PreferencesService.keyHotkeyShowToolbar),
      recordToggle:
          prefs.getHotkey(PreferencesService.keyHotkeyRecordToggle),
      screenshotToggle:
          prefs.getHotkey(PreferencesService.keyHotkeyScreenshotToggle),
      areaRecordToggle:
          prefs.getHotkey(PreferencesService.keyHotkeyAreaRecord),
      ssFullscreen:
          prefs.getHotkey(PreferencesService.keyHotkeySsFullscreen),
      ssArea: prefs.getHotkey(PreferencesService.keyHotkeySsArea),
      ssLong: prefs.getHotkey(PreferencesService.keyHotkeySsLong),
      recFullscreen:
          prefs.getHotkey(PreferencesService.keyHotkeyRecFullscreen),
    );

    Future.microtask(() => _registerAll(settings));
    return settings;
  }

  void setToolbarCallback(VoidCallback callback) {
    _onToolbarToggle = callback;
    _registerAll(state);
  }

  void setAreaRecordCallback(VoidCallback callback) {
    _onAreaRecordToggle = callback;
    _registerAll(state);
  }

  void setRecordToggleCallback(VoidCallback callback) {
    _onRecordToggle = callback;
    _registerAll(state);
  }

  void setScreenshotToggleCallback(VoidCallback callback) {
    _onScreenshotToggle = callback;
    _registerAll(state);
  }

  void setSsFullscreenCallback(VoidCallback callback) {
    _onSsFullscreen = callback;
    _registerAll(state);
  }

  void setSsAreaCallback(VoidCallback callback) {
    _onSsArea = callback;
    _registerAll(state);
  }

  void setSsLongCallback(VoidCallback callback) {
    _onSsLong = callback;
    _registerAll(state);
  }

  void setRecFullscreenCallback(VoidCallback callback) {
    _onRecFullscreen = callback;
    _registerAll(state);
  }

  Future<void> _registerAll(HotkeySettings settings) async {
    if (Platform.isLinux) return; // Prevent Wayland crashes from X11 hotkey bindings
    await hotKeyManager.unregisterAll();

    final registrations = [
      (settings.showToolbar, 'show_toolbar', _onToolbarToggle),
      (settings.recordToggle, 'record_toggle', _onRecordToggle),
      (settings.screenshotToggle, 'screenshot_toggle', _onScreenshotToggle),
      (settings.areaRecordToggle, 'area_record', _onAreaRecordToggle),
      (settings.ssFullscreen, 'ss_fullscreen', _onSsFullscreen),
      (settings.ssArea, 'ss_area', _onSsArea),
      (settings.ssLong, 'ss_long', _onSsLong),
      (settings.recFullscreen, 'rec_fullscreen', _onRecFullscreen),
    ];

    for (final (hotkey, id, callback) in registrations) {
      if (hotkey != null && callback != null) {
        await hotKeyManager.register(
          hotkey.toHotKey(identifier: id),
          keyDownHandler: (_) => callback(),
        );
      }
    }
  }

  String? updateHotkey(String key, HotkeyInfo info) {
    final error = _validate(key, info);
    if (error != null) return error;

    final prefs = ref.read(preferencesServiceProvider);
    prefs.setHotkey(key, info);

    switch (key) {
      case PreferencesService.keyHotkeyShowToolbar:
        state = state.copyWith(showToolbar: info);
      case PreferencesService.keyHotkeyRecordToggle:
        state = state.copyWith(recordToggle: info);
      case PreferencesService.keyHotkeyScreenshotToggle:
        state = state.copyWith(screenshotToggle: info);
      case PreferencesService.keyHotkeyAreaRecord:
        state = state.copyWith(areaRecordToggle: info);
      case PreferencesService.keyHotkeySsFullscreen:
        state = state.copyWith(ssFullscreen: info);
      case PreferencesService.keyHotkeySsArea:
        state = state.copyWith(ssArea: info);
      case PreferencesService.keyHotkeySsLong:
        state = state.copyWith(ssLong: info);
      case PreferencesService.keyHotkeyRecFullscreen:
        state = state.copyWith(recFullscreen: info);
    }

    _registerAll(state);
    return null;
  }

  String? _validate(String key, HotkeyInfo info) {
    if (info.modifierIndices.isEmpty) {
      return 'Safety Check: Global hotkeys MUST include at least one modifier (Alt, Ctrl, or Shift).';
    }

    for (final (existingKey, existingInfo) in state.entries) {
      if (existingKey != key && existingInfo != null && existingInfo == info) {
        final label = _hotkeyLabel(existingKey);
        return 'Conflict: Shortcut already assigned to $label.';
      }
    }

    return null;
  }

  String _hotkeyLabel(String key) {
    switch (key) {
      case PreferencesService.keyHotkeyShowToolbar:
        return 'Show Toolbar';
      case PreferencesService.keyHotkeyRecordToggle:
        return 'Start/Stop Recording';
      case PreferencesService.keyHotkeyScreenshotToggle:
        return 'Start Capture';
      case PreferencesService.keyHotkeyAreaRecord:
        return 'Quick Area Record';
      case PreferencesService.keyHotkeySsFullscreen:
        return 'Screenshot: Full Screen';
      case PreferencesService.keyHotkeySsArea:
        return 'Screenshot: Area';
      case PreferencesService.keyHotkeySsLong:
        return 'Screenshot: Long SS';
      case PreferencesService.keyHotkeyRecFullscreen:
        return 'Recorder: Full Screen';
      default:
        return key;
    }
  }
}

final hotkeySettingsProvider =
    NotifierProvider<HotkeySettingsNotifier, HotkeySettings>(() {
      return HotkeySettingsNotifier();
    });

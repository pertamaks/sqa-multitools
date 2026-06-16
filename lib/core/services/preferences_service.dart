import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/hotkey_info.dart';
import 'coffee_shop_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'linux_integration_service.dart';

part 'preferences_service.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
}

@Riverpod(keepAlive: true)
FlutterSecureStorage secureStorage(Ref ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    wOptions: WindowsOptions(),
  );
}

class PreferencesService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secure;

  PreferencesService(this._prefs, this._secure);

  SharedPreferences get rawPrefs => _prefs;

  static const String keyEnabledPlugins = 'enabled_plugins';
  static const String keyPluginOrder = 'plugin_order';
  static const String keyAppVersion = 'app_version';
  static const String keyPrefsVersion = 'prefs_version';
  static const int currentPrefsVersion =
      2; // Incremented for encryption migration

  static const String keyThemeMode = 'theme_mode';
  static const String keySeedColor = 'seed_color';
  static const String keyUseDynamicColor = 'use_dynamic_color';
  static const String keySupporterTier = 'supporter_tier';
  static const String keySupporterCode = 'supporter_code';
  static const String keySupporterEmail = 'supporter_email';
  static const String keySupporterSignature = 'supporter_signature';
  static const String keyBugsSquashed = 'bugs_squashed';
  static const String keyBugSquashEnabled = 'bug_squash_enabled';
  static const String keyBeautifierAutoFormat = 'beautifier_auto_format';
  static const String keyBeautifierInputWrapText = 'beautifier_input_wrap_text';
  static const String keyBeautifierOutputWrapText =
      'beautifier_output_wrap_text';
  static const String keyBeautifierIndentWidth = 'beautifier_indent_width';
  static const String keyOracleMode = 'oracle_mode';
  static const String keyAlwaysOnTop = 'always_on_top';
  static const String keyHotkeyShowToolbar = 'hotkey_show_toolbar';
  static const String keyHotkeyRecordToggle = 'hotkey_record_toggle';
  static const String keyHotkeyScreenshotToggle = 'hotkey_screenshot_toggle';
  static const String keyHotkeyAreaRecord = 'hotkey_area_record';
  static const String keyHotkeySsFullscreen = 'hotkey_ss_fullscreen';
  static const String keyHotkeySsArea = 'hotkey_ss_area';
  static const String keyHotkeySsLong = 'hotkey_ss_long';
  static const String keyHotkeyRecFullscreen = 'hotkey_rec_fullscreen';
  static const String keyAppOpacity = 'app_opacity';
  static const String keyTransparencyMode = 'transparency_mode';
  static const String keyShowTaskbarIcon = 'show_taskbar_icon';
  static const String keyLinuxSystemIntegration = 'linux_system_integration';

  static const String keyScreenshotSaveDir = 'screenshot_save_dir';
  static const String keyScreenshotFormat = 'screenshot_format';
  static const String keyScreenshotDelay = 'screenshot_delay';
  static const String keyTextEditorSaveDir = 'text_editor_save_dir';
  static const String keyFakerLocale = 'faker_locale';
  static const String keyCurlHistory = 'plugin_curl_requester_history_v1';
  static const String keyCurlEnvironments =
      'plugin_curl_requester_environments_v1';

  List<String>? getEnabledPluginIds() {
    return _prefs.getStringList(keyEnabledPlugins);
  }

  Future<void> setEnabledPluginIds(List<String> pluginIds) async {
    await _prefs.setStringList(keyEnabledPlugins, pluginIds);
  }

  List<String>? getPluginOrder() {
    return _prefs.getStringList(keyPluginOrder);
  }

  Future<void> setPluginOrder(List<String> order) async {
    await _prefs.setStringList(keyPluginOrder, order);
  }

  int getThemeModeIndex() {
    return _prefs.getInt(keyThemeMode) ?? 0; // 0 = system, 1 = light, 2 = dark
  }

  Future<void> setThemeModeIndex(int index) async {
    await _prefs.setInt(keyThemeMode, index);
  }

  int getSeedColorValue() {
    return _prefs.getInt(keySeedColor) ?? 0xFF009688; // Default Teal
  }

  Future<void> setSeedColorValue(int value) async {
    await _prefs.setInt(keySeedColor, value);
  }

  bool getUseDynamicColor() {
    return _prefs.getBool(keyUseDynamicColor) ?? false;
  }

  Future<void> setUseDynamicColor(bool useDynamic) async {
    await _prefs.setBool(keyUseDynamicColor, useDynamic);
  }

  int getSupporterTier() {
    return _prefs.getInt(keySupporterTier) ?? 0;
  }

  Future<void> setSupporterTier(int tier) async {
    await _prefs.setInt(keySupporterTier, tier);
  }

  Future<String?> getSupporterCode() async {
    return _secure.read(key: keySupporterCode);
  }

  Future<void> setSupporterCode(String code) async {
    await _secure.write(key: keySupporterCode, value: code);
  }

  Future<String?> getSupporterEmail() async {
    return _secure.read(key: keySupporterEmail);
  }

  Future<void> setSupporterEmail(String email) async {
    await _secure.write(key: keySupporterEmail, value: email);
  }

  Future<String?> getSupporterSignature() async {
    return _secure.read(key: keySupporterSignature);
  }

  Future<void> setSupporterSignature(String signature) async {
    await _secure.write(key: keySupporterSignature, value: signature);
  }

  int getBugsSquashed() {
    return _prefs.getInt(keyBugsSquashed) ?? 0;
  }

  Future<void> setBugsSquashed(int count) async {
    await _prefs.setInt(keyBugsSquashed, count);
  }

  bool getBugSquashEnabled() {
    return _prefs.getBool(keyBugSquashEnabled) ?? true;
  }

  Future<void> setBugSquashEnabled(bool enabled) async {
    await _prefs.setBool(keyBugSquashEnabled, enabled);
  }

  bool getBeautifierAutoFormat() {
    return _prefs.getBool(keyBeautifierAutoFormat) ?? true;
  }

  double getAppOpacity() {
    return _prefs.getDouble(keyAppOpacity) ?? 1.0;
  }

  Future<void> setAppOpacity(double opacity) async {
    await _prefs.setDouble(keyAppOpacity, opacity);
  }

  bool getTransparencyMode() {
    return _prefs.getBool(keyTransparencyMode) ?? false;
  }

  Future<void> setTransparencyMode(bool enabled) async {
    await _prefs.setBool(keyTransparencyMode, enabled);
  }

  bool getShowTaskbarIcon() {
    return _prefs.getBool(keyShowTaskbarIcon) ?? true;
  }

  Future<void> setShowTaskbarIcon(bool value) async {
    await _prefs.setBool(keyShowTaskbarIcon, value);
  }

  bool getLinuxSystemIntegration() {
    return _prefs.getBool(keyLinuxSystemIntegration) ?? false;
  }

  Future<void> setLinuxSystemIntegration(bool value) async {
    await _prefs.setBool(keyLinuxSystemIntegration, value);
  }

  Future<void> setBeautifierAutoFormat(bool autoFormat) async {
    await _prefs.setBool(keyBeautifierAutoFormat, autoFormat);
  }

  bool getBeautifierInputWrapText() {
    return _prefs.getBool(keyBeautifierInputWrapText) ?? true;
  }

  Future<void> setBeautifierInputWrapText(bool wrapText) async {
    await _prefs.setBool(keyBeautifierInputWrapText, wrapText);
  }

  bool getBeautifierOutputWrapText() {
    return _prefs.getBool(keyBeautifierOutputWrapText) ?? true;
  }

  Future<void> setBeautifierOutputWrapText(bool wrapText) async {
    await _prefs.setBool(keyBeautifierOutputWrapText, wrapText);
  }

  int getBeautifierIndentWidth() {
    return _prefs.getInt(keyBeautifierIndentWidth) ?? 2;
  }

  Future<void> setBeautifierIndentWidth(int width) async {
    await _prefs.setInt(keyBeautifierIndentWidth, width);
  }

  int getOracleModeIndex() {
    return _prefs.getInt(keyOracleMode) ?? 0; // 0 = Savage
  }

  Future<void> setOracleModeIndex(int index) async {
    await _prefs.setInt(keyOracleMode, index);
  }

  bool getAlwaysOnTop() {
    return _prefs.getBool(keyAlwaysOnTop) ?? true;
  }

  Future<void> setAlwaysOnTop(bool value) async {
    await _prefs.setBool(keyAlwaysOnTop, value);
  }

  HotkeyInfo? getHotkey(String key) {
    final jsonStr = _prefs.getString(key);
    if (jsonStr == null) return null;
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return HotkeyInfo.fromJson(decoded);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> setHotkey(String key, HotkeyInfo? info) async {
    if (info == null) {
      await _prefs.remove(key);
    } else {
      await _prefs.setString(key, jsonEncode(info.toJson()));
    }
  }

  String? getTextEditorSaveDir() {
    return _prefs.getString(keyTextEditorSaveDir);
  }

  Future<void> setTextEditorSaveDir(String path) async {
    await _prefs.setString(keyTextEditorSaveDir, path);
  }

  String getFakerLocale() {
    return _prefs.getString(keyFakerLocale) ?? 'en_US';
  }

  Future<void> setFakerLocale(String locale) async {
    await _prefs.setString(keyFakerLocale, locale);
  }

  /// Migrates preferences from older versions to the current schema.
  Future<void> migrate() async {
    final int oldVersion = _prefs.getInt(keyPrefsVersion) ?? 0;
    if (oldVersion >= currentPrefsVersion) return;

    // Migration 1: Move supporter data to Secure Storage (Version 0 -> 1/2)
    if (oldVersion < 2) {
      final oldEmail = _prefs.getString(keySupporterEmail);
      final oldCode = _prefs.getString(keySupporterCode);
      final oldSig = _prefs.getString(keySupporterSignature);

      if (oldEmail != null) {
        await setSupporterEmail(oldEmail);
        await _prefs.remove(keySupporterEmail);
      }
      if (oldCode != null) {
        await setSupporterCode(oldCode);
        await _prefs.remove(keySupporterCode);
      }
      if (oldSig != null) {
        await setSupporterSignature(oldSig);
        await _prefs.remove(keySupporterSignature);
      }
    }

    // Update version after all migrations succeed
    await _prefs.setInt(keyPrefsVersion, currentPrefsVersion);
  }
}

@Riverpod(keepAlive: true)
PreferencesService preferencesService(Ref ref) {
  return PreferencesService(
    ref.watch(sharedPreferencesProvider),
    ref.watch(secureStorageProvider),
  );
}

class ThemeSettingsData {
  final int modeIndex;
  final int seedColorValue;
  final bool useDynamicColor;
  final bool alwaysOnTop;
  final double opacity;
  final bool isTransparencyModeEnabled;
  final bool showTaskbarIcon;
  final bool linuxSystemIntegration;

  const ThemeSettingsData({
    required this.modeIndex,
    required this.seedColorValue,
    required this.useDynamicColor,
    required this.alwaysOnTop,
    required this.opacity,
    required this.isTransparencyModeEnabled,
    required this.showTaskbarIcon,
    required this.linuxSystemIntegration,
  });

  ThemeSettingsData copyWith({
    int? modeIndex,
    int? seedColorValue,
    bool? useDynamicColor,
    bool? alwaysOnTop,
    double? opacity,
    bool? isTransparencyModeEnabled,
    bool? showTaskbarIcon,
    bool? linuxSystemIntegration,
  }) {
    return ThemeSettingsData(
      modeIndex: modeIndex ?? this.modeIndex,
      seedColorValue: seedColorValue ?? this.seedColorValue,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      opacity: opacity ?? this.opacity,
      isTransparencyModeEnabled:
          isTransparencyModeEnabled ?? this.isTransparencyModeEnabled,
      showTaskbarIcon: showTaskbarIcon ?? this.showTaskbarIcon,
      linuxSystemIntegration:
          linuxSystemIntegration ?? this.linuxSystemIntegration,
    );
  }
}

@Riverpod(keepAlive: true)
class ThemeSettings extends _$ThemeSettings {
  @override
  ThemeSettingsData build() {
    final service = ref.watch(preferencesServiceProvider);

    final initialSettings = ThemeSettingsData(
      modeIndex: service.getThemeModeIndex(),
      seedColorValue: service.getSeedColorValue(),
      useDynamicColor: service.getUseDynamicColor(),
      alwaysOnTop: service.getAlwaysOnTop(),
      opacity: service.getAppOpacity(),
      isTransparencyModeEnabled: service.getTransparencyMode(),
      showTaskbarIcon: service.getShowTaskbarIcon(),
      linuxSystemIntegration: service.getLinuxSystemIntegration(),
    );

    return _applyTierConstraints(initialSettings);
  }

  ThemeSettingsData _applyTierConstraints(ThemeSettingsData settings) {
    final tier = ref.read(supporterTierProvider);

    int seedColorValue = settings.seedColorValue;
    bool useDynamicColor = settings.useDynamicColor;
    bool isTransparencyEnabled = settings.isTransparencyModeEnabled;
    double opacity = settings.opacity;

    // Tier 1: Custom Accent Colors (except Teal)
    if (tier < 1 && seedColorValue != 0xFF009688) {
      seedColorValue = 0xFF009688;
    }

    // Tier 2: Dynamic Color Sync
    if (tier < 2) {
      useDynamicColor = false;
    }

    // Tier 3: Transparency Mode
    if (tier < 3) {
      isTransparencyEnabled = false;
      opacity = 1.0;
    }

    // Global enforcement: If transparency mode is OFF, opacity MUST be 1.0
    if (!isTransparencyEnabled) {
      opacity = 1.0;
    }

    return settings.copyWith(
      seedColorValue: seedColorValue,
      useDynamicColor: useDynamicColor,
      isTransparencyModeEnabled: isTransparencyEnabled,
      opacity: opacity,
    );
  }

  void setModeIndex(int index) {
    state = state.copyWith(modeIndex: index);
    ref.read(preferencesServiceProvider).setThemeModeIndex(index);
  }

  void setSeedColor(int colorValue) {
    state = state.copyWith(seedColorValue: colorValue);
    ref.read(preferencesServiceProvider).setSeedColorValue(colorValue);
  }

  void setUseDynamicColor(bool useDynamic) {
    state = state.copyWith(useDynamicColor: useDynamic);
    ref.read(preferencesServiceProvider).setUseDynamicColor(useDynamic);
  }

  void setAlwaysOnTop(bool value) {
    state = state.copyWith(alwaysOnTop: value);
    ref.read(preferencesServiceProvider).setAlwaysOnTop(value);
    windowManager.setAlwaysOnTop(value);
  }

  void setShowTaskbarIcon(bool value) {
    state = state.copyWith(showTaskbarIcon: value);
    ref.read(preferencesServiceProvider).setShowTaskbarIcon(value);
    windowManager.setSkipTaskbar(!value);
  }

  Future<void> setLinuxSystemIntegration(bool value) async {
    state = state.copyWith(linuxSystemIntegration: value);
    ref.read(preferencesServiceProvider).setLinuxSystemIntegration(value);
    final integrationService = ref.read(linuxIntegrationServiceProvider);
    if (value) {
      await integrationService.integrate();
    } else {
      await integrationService.removeIntegration();
    }
  }

  void setOpacity(double value) {
    // Clamping logic: if transparency is enabled, we cap it at 0.85
    // If not, it should generally be 1.0 (opaque)
    double effectiveValue = state.isTransparencyModeEnabled
        ? value.clamp(0.2, 0.85)
        : 1.0;

    // Round to 2 decimal places to avoid floating point drift that can break Sliders
    effectiveValue = double.parse(effectiveValue.toStringAsFixed(2));

    state = state.copyWith(opacity: effectiveValue);
    ref.read(preferencesServiceProvider).setAppOpacity(effectiveValue);
  }

  void toggleTransparencyMode(bool enabled) {
    final service = ref.read(preferencesServiceProvider);
    double newOpacity = state.opacity;

    if (enabled) {
      // Activating mode sets opacity to 0.85 automatically
      newOpacity = 0.85;
    } else {
      // Disabling mode returns to full opacity
      newOpacity = 1.0;
    }

    state = state.copyWith(
      isTransparencyModeEnabled: enabled,
      opacity: newOpacity,
    );

    service.setTransparencyMode(enabled);
    service.setAppOpacity(newOpacity);
  }

  // Temporary preview methods (not saved to prefs)

  void previewSeedColor(int colorValue) {
    state = state.copyWith(seedColorValue: colorValue);
  }

  void previewTransparency(bool enabled) {
    state = state.copyWith(
      isTransparencyModeEnabled: enabled,
      opacity: enabled ? 0.85 : 1.0,
    );
  }

  void previewDynamicColor(bool enabled) {
    state = state.copyWith(useDynamicColor: enabled);
  }

  // Restore state from saved preferences (used when closing settings preview)
  void resetToSaved() {
    final service = ref.read(preferencesServiceProvider);
    final savedSettings = ThemeSettingsData(
      modeIndex: service.getThemeModeIndex(),
      seedColorValue: service.getSeedColorValue(),
      useDynamicColor: service.getUseDynamicColor(),
      alwaysOnTop: service.getAlwaysOnTop(),
      opacity: service.getAppOpacity(),
      isTransparencyModeEnabled: service.getTransparencyMode(),
      showTaskbarIcon: service.getShowTaskbarIcon(),
      linuxSystemIntegration: service.getLinuxSystemIntegration(),
    );

    state = _applyTierConstraints(savedSettings);
  }
}

@Riverpod(keepAlive: true)
class BugSquashEnabled extends _$BugSquashEnabled {
  @override
  bool build() {
    return ref.watch(preferencesServiceProvider).getBugSquashEnabled();
  }

  void setEnabled(bool enabled) {
    state = enabled;
    ref.read(preferencesServiceProvider).setBugSquashEnabled(enabled);
  }
}

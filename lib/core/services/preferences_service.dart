import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main()',
  );
});

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  SharedPreferences get rawPrefs => _prefs;

  static const String keyEnabledPlugins = 'enabled_plugins';
  static const String keyPluginOrder = 'plugin_order';

  static const String keyThemeMode = 'theme_mode';
  static const String keySeedColor = 'seed_color';
  static const String keyUseDynamicColor = 'use_dynamic_color';
  static const String keySupporterTier = 'supporter_tier';
  static const String keySupporterCode = 'supporter_code';
  static const String keyBugsSquashed = 'bugs_squashed';
  static const String keyBugSquashEnabled = 'bug_squash_enabled';
  static const String keyBeautifierAutoFormat = 'beautifier_auto_format';
  static const String keyBeautifierInputWrapText = 'beautifier_input_wrap_text';
  static const String keyBeautifierOutputWrapText =
      'beautifier_output_wrap_text';
  static const String keyBeautifierIndentWidth = 'beautifier_indent_width';
  static const String keyOracleMode = 'oracle_mode';

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

  String? getSupporterCode() {
    return _prefs.getString(keySupporterCode);
  }

  Future<void> setSupporterCode(String code) async {
    await _prefs.setString(keySupporterCode, code);
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
}

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService(ref.watch(sharedPreferencesProvider));
});

class ThemeSettings {
  final int modeIndex;
  final int seedColorValue;
  final bool useDynamicColor;

  const ThemeSettings({
    required this.modeIndex,
    required this.seedColorValue,
    required this.useDynamicColor,
  });

  ThemeSettings copyWith({
    int? modeIndex,
    int? seedColorValue,
    bool? useDynamicColor,
  }) {
    return ThemeSettings(
      modeIndex: modeIndex ?? this.modeIndex,
      seedColorValue: seedColorValue ?? this.seedColorValue,
      useDynamicColor: useDynamicColor ?? this.useDynamicColor,
    );
  }
}

class ThemeSettingsNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    final service = ref.watch(preferencesServiceProvider);
    return ThemeSettings(
      modeIndex: service.getThemeModeIndex(),
      seedColorValue: service.getSeedColorValue(),
      useDynamicColor: service.getUseDynamicColor(),
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

  // Temporary preview method (not saved to prefs)
  void previewSeedColor(int colorValue) {
    state = state.copyWith(seedColorValue: colorValue);
  }

  // Restore state from saved preferences (used when closing settings preview)
  void resetToSaved() {
    final service = ref.read(preferencesServiceProvider);
    state = ThemeSettings(
      modeIndex: service.getThemeModeIndex(),
      seedColorValue: service.getSeedColorValue(),
      useDynamicColor: service.getUseDynamicColor(),
    );
  }
}

final themeSettingsProvider =
    NotifierProvider<ThemeSettingsNotifier, ThemeSettings>(() {
      return ThemeSettingsNotifier();
    });

class BugSquashEnabledNotifier extends Notifier<bool> {
  @override
  bool build() {
    return ref.watch(preferencesServiceProvider).getBugSquashEnabled();
  }

  void setEnabled(bool enabled) {
    state = enabled;
    ref.read(preferencesServiceProvider).setBugSquashEnabled(enabled);
  }
}

final bugSquashEnabledProvider =
    NotifierProvider<BugSquashEnabledNotifier, bool>(() {
      return BugSquashEnabledNotifier();
    });

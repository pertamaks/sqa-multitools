// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plugin_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(availablePlugins)
final availablePluginsProvider = AvailablePluginsProvider._();

final class AvailablePluginsProvider
    extends
        $FunctionalProvider<List<SqaPlugin>, List<SqaPlugin>, List<SqaPlugin>>
    with $Provider<List<SqaPlugin>> {
  AvailablePluginsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availablePluginsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availablePluginsHash();

  @$internal
  @override
  $ProviderElement<List<SqaPlugin>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SqaPlugin> create(Ref ref) {
    return availablePlugins(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SqaPlugin> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SqaPlugin>>(value),
    );
  }
}

String _$availablePluginsHash() => r'00081619b6e6b8676dd3151386bcea9b5ac44a08';

/// Provides all available plugins in their user-defined order

@ProviderFor(orderedAvailablePlugins)
final orderedAvailablePluginsProvider = OrderedAvailablePluginsProvider._();

/// Provides all available plugins in their user-defined order

final class OrderedAvailablePluginsProvider
    extends
        $FunctionalProvider<List<SqaPlugin>, List<SqaPlugin>, List<SqaPlugin>>
    with $Provider<List<SqaPlugin>> {
  /// Provides all available plugins in their user-defined order
  OrderedAvailablePluginsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orderedAvailablePluginsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orderedAvailablePluginsHash();

  @$internal
  @override
  $ProviderElement<List<SqaPlugin>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<SqaPlugin> create(Ref ref) {
    return orderedAvailablePlugins(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SqaPlugin> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SqaPlugin>>(value),
    );
  }
}

String _$orderedAvailablePluginsHash() =>
    r'719f3a2761505370fba12d9fbc07385eea5d1b53';

@ProviderFor(EnabledPlugins)
final enabledPluginsProvider = EnabledPluginsProvider._();

final class EnabledPluginsProvider
    extends $NotifierProvider<EnabledPlugins, List<SqaPlugin>> {
  EnabledPluginsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'enabledPluginsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$enabledPluginsHash();

  @$internal
  @override
  EnabledPlugins create() => EnabledPlugins();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SqaPlugin> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SqaPlugin>>(value),
    );
  }
}

String _$enabledPluginsHash() => r'2c335451e3203e078fcf7fa9c4b41f5fa7c48f3a';

abstract class _$EnabledPlugins extends $Notifier<List<SqaPlugin>> {
  List<SqaPlugin> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<SqaPlugin>, List<SqaPlugin>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SqaPlugin>, List<SqaPlugin>>,
              List<SqaPlugin>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ActivePlugin)
final activePluginProvider = ActivePluginProvider._();

final class ActivePluginProvider
    extends $NotifierProvider<ActivePlugin, SqaPlugin?> {
  ActivePluginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activePluginProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activePluginHash();

  @$internal
  @override
  ActivePlugin create() => ActivePlugin();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SqaPlugin? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SqaPlugin?>(value),
    );
  }
}

String _$activePluginHash() => r'4fd8e12baa114eb914ef2dffbd0b9cce6d68ccca';

abstract class _$ActivePlugin extends $Notifier<SqaPlugin?> {
  SqaPlugin? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SqaPlugin?, SqaPlugin?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SqaPlugin?, SqaPlugin?>,
              SqaPlugin?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(settingsPlugin)
final settingsPluginProvider = SettingsPluginProvider._();

final class SettingsPluginProvider
    extends $FunctionalProvider<SqaPlugin, SqaPlugin, SqaPlugin>
    with $Provider<SqaPlugin> {
  SettingsPluginProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsPluginProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsPluginHash();

  @$internal
  @override
  $ProviderElement<SqaPlugin> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SqaPlugin create(Ref ref) {
    return settingsPlugin(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SqaPlugin value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SqaPlugin>(value),
    );
  }
}

String _$settingsPluginHash() => r'787ce68e556da9871b6960b94309c09c7172109d';

/// Tracks the ID of the plugin we should return to from Settings

@ProviderFor(NavigationHistory)
final navigationHistoryProvider = NavigationHistoryProvider._();

/// Tracks the ID of the plugin we should return to from Settings
final class NavigationHistoryProvider
    extends $NotifierProvider<NavigationHistory, String?> {
  /// Tracks the ID of the plugin we should return to from Settings
  NavigationHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationHistoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationHistoryHash();

  @$internal
  @override
  NavigationHistory create() => NavigationHistory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$navigationHistoryHash() => r'757b687fe6b3c5db4950c2076a783b73dcebc430';

/// Tracks the ID of the plugin we should return to from Settings

abstract class _$NavigationHistory extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Tracks the active tab in the Settings view

@ProviderFor(SettingsTab)
final settingsTabProvider = SettingsTabProvider._();

/// Tracks the active tab in the Settings view
final class SettingsTabProvider extends $NotifierProvider<SettingsTab, int> {
  /// Tracks the active tab in the Settings view
  SettingsTabProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsTabProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsTabHash();

  @$internal
  @override
  SettingsTab create() => SettingsTab();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$settingsTabHash() => r'ae1465347764a7daf9d21642d3c2f111c7912e66';

/// Tracks the active tab in the Settings view

abstract class _$SettingsTab extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PluginEditMode)
final pluginEditModeProvider = PluginEditModeProvider._();

final class PluginEditModeProvider
    extends $NotifierProvider<PluginEditMode, bool> {
  PluginEditModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pluginEditModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pluginEditModeHash();

  @$internal
  @override
  PluginEditMode create() => PluginEditMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$pluginEditModeHash() => r'bace327c9186220355a740879aa06c5fa40eae0f';

abstract class _$PluginEditMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Centralized service for jumping between plugins/settings

@ProviderFor(navigationService)
final navigationServiceProvider = NavigationServiceProvider._();

/// Centralized service for jumping between plugins/settings

final class NavigationServiceProvider
    extends
        $FunctionalProvider<
          NavigationService,
          NavigationService,
          NavigationService
        >
    with $Provider<NavigationService> {
  /// Centralized service for jumping between plugins/settings
  NavigationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'navigationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$navigationServiceHash();

  @$internal
  @override
  $ProviderElement<NavigationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NavigationService create(Ref ref) {
    return navigationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NavigationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NavigationService>(value),
    );
  }
}

String _$navigationServiceHash() => r'7a3048a7132c3c0836ad9d68fca9f83eb14d7fb8';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_debug_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A simple trigger provider to signal from the settings UI to the main toolbar overlay

@ProviderFor(BugTrigger)
final bugTriggerProvider = BugTriggerProvider._();

/// A simple trigger provider to signal from the settings UI to the main toolbar overlay
final class BugTriggerProvider extends $NotifierProvider<BugTrigger, int?> {
  /// A simple trigger provider to signal from the settings UI to the main toolbar overlay
  BugTriggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bugTriggerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bugTriggerHash();

  @$internal
  @override
  BugTrigger create() => BugTrigger();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$bugTriggerHash() => r'3d42555f061f1eb1bda9e40b8f34e6e306d40295';

/// A simple trigger provider to signal from the settings UI to the main toolbar overlay

abstract class _$BugTrigger extends $Notifier<int?> {
  int? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int?, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int?, int?>,
              int?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SettingsDebugActions)
final settingsDebugActionsProvider = SettingsDebugActionsProvider._();

final class SettingsDebugActionsProvider
    extends $NotifierProvider<SettingsDebugActions, void> {
  SettingsDebugActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsDebugActionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsDebugActionsHash();

  @$internal
  @override
  SettingsDebugActions create() => SettingsDebugActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$settingsDebugActionsHash() =>
    r'ccf5b65856adae60eff0a4a7f2f211e0bb3f63fe';

abstract class _$SettingsDebugActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(DebugTapCounter)
final debugTapCounterProvider = DebugTapCounterProvider._();

final class DebugTapCounterProvider
    extends $NotifierProvider<DebugTapCounter, int> {
  DebugTapCounterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugTapCounterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugTapCounterHash();

  @$internal
  @override
  DebugTapCounter create() => DebugTapCounter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$debugTapCounterHash() => r'b4c3bd7c55563a077076c4b56d6c2e7c45aa4a97';

abstract class _$DebugTapCounter extends $Notifier<int> {
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

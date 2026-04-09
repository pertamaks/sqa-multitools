// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A notifier provider that toggles the visibility of developer diagnostics.
/// Activated via a hidden "Cheat Code" (5-tap sequence on Settings).
/// keepAlive is set to true to ensure the state persists during the session.

@ProviderFor(DebugMode)
final debugModeProvider = DebugModeProvider._();

/// A notifier provider that toggles the visibility of developer diagnostics.
/// Activated via a hidden "Cheat Code" (5-tap sequence on Settings).
/// keepAlive is set to true to ensure the state persists during the session.
final class DebugModeProvider extends $NotifierProvider<DebugMode, bool> {
  /// A notifier provider that toggles the visibility of developer diagnostics.
  /// Activated via a hidden "Cheat Code" (5-tap sequence on Settings).
  /// keepAlive is set to true to ensure the state persists during the session.
  DebugModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugModeHash();

  @$internal
  @override
  DebugMode create() => DebugMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$debugModeHash() => r'117a8ce6e925255f4c62f83c3495009b92f684a9';

/// A notifier provider that toggles the visibility of developer diagnostics.
/// Activated via a hidden "Cheat Code" (5-tap sequence on Settings).
/// keepAlive is set to true to ensure the state persists during the session.

abstract class _$DebugMode extends $Notifier<bool> {
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

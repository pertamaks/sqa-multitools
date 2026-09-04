// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coachmark_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Manages the seen-state for all coachmark tours and exposes helpers for
/// the toolbar and plugin windows to check whether to auto-show a tour.
///
/// Persistence is delegated to [PreferencesService].

@ProviderFor(CoachmarkService)
final coachmarkServiceProvider = CoachmarkServiceProvider._();

/// Manages the seen-state for all coachmark tours and exposes helpers for
/// the toolbar and plugin windows to check whether to auto-show a tour.
///
/// Persistence is delegated to [PreferencesService].
final class CoachmarkServiceProvider
    extends $NotifierProvider<CoachmarkService, CoachmarkServiceState> {
  /// Manages the seen-state for all coachmark tours and exposes helpers for
  /// the toolbar and plugin windows to check whether to auto-show a tour.
  ///
  /// Persistence is delegated to [PreferencesService].
  CoachmarkServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachmarkServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachmarkServiceHash();

  @$internal
  @override
  CoachmarkService create() => CoachmarkService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoachmarkServiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoachmarkServiceState>(value),
    );
  }
}

String _$coachmarkServiceHash() => r'f27588c7968e78f4a4bcd1fa098f28ba445b5853';

/// Manages the seen-state for all coachmark tours and exposes helpers for
/// the toolbar and plugin windows to check whether to auto-show a tour.
///
/// Persistence is delegated to [PreferencesService].

abstract class _$CoachmarkService extends $Notifier<CoachmarkServiceState> {
  CoachmarkServiceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CoachmarkServiceState, CoachmarkServiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CoachmarkServiceState, CoachmarkServiceState>,
              CoachmarkServiceState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

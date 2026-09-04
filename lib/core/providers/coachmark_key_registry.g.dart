// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coachmark_key_registry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A centralized registry mapping semantic key names to [GlobalKey] instances.
///
/// Plugins and toolbar widgets register their keys here during [initState]
/// or widget construction. The coachmark engine reads them to locate target
/// widgets on screen.
///
/// ## Usage
/// ```dart
/// // In a plugin's StatefulWidget.initState:
/// ref.read(coachmarkKeyRegistryProvider.notifier).register(
///   'timer.tab.bar',
///   _tabBarKey,
/// );
///
/// // In a SqaCoachmarkStep:
/// SqaCoachmarkStep(
///   targetKey: ref.read(coachmarkKeyRegistryProvider)['timer.tab.bar']
///       ?? GlobalKey(),
///   title: '...',
///   description: '...',
/// )
/// ```

@ProviderFor(CoachmarkKeyRegistry)
final coachmarkKeyRegistryProvider = CoachmarkKeyRegistryProvider._();

/// A centralized registry mapping semantic key names to [GlobalKey] instances.
///
/// Plugins and toolbar widgets register their keys here during [initState]
/// or widget construction. The coachmark engine reads them to locate target
/// widgets on screen.
///
/// ## Usage
/// ```dart
/// // In a plugin's StatefulWidget.initState:
/// ref.read(coachmarkKeyRegistryProvider.notifier).register(
///   'timer.tab.bar',
///   _tabBarKey,
/// );
///
/// // In a SqaCoachmarkStep:
/// SqaCoachmarkStep(
///   targetKey: ref.read(coachmarkKeyRegistryProvider)['timer.tab.bar']
///       ?? GlobalKey(),
///   title: '...',
///   description: '...',
/// )
/// ```
final class CoachmarkKeyRegistryProvider
    extends
        $NotifierProvider<
          CoachmarkKeyRegistry,
          Map<String, GlobalKey<State<StatefulWidget>>>
        > {
  /// A centralized registry mapping semantic key names to [GlobalKey] instances.
  ///
  /// Plugins and toolbar widgets register their keys here during [initState]
  /// or widget construction. The coachmark engine reads them to locate target
  /// widgets on screen.
  ///
  /// ## Usage
  /// ```dart
  /// // In a plugin's StatefulWidget.initState:
  /// ref.read(coachmarkKeyRegistryProvider.notifier).register(
  ///   'timer.tab.bar',
  ///   _tabBarKey,
  /// );
  ///
  /// // In a SqaCoachmarkStep:
  /// SqaCoachmarkStep(
  ///   targetKey: ref.read(coachmarkKeyRegistryProvider)['timer.tab.bar']
  ///       ?? GlobalKey(),
  ///   title: '...',
  ///   description: '...',
  /// )
  /// ```
  CoachmarkKeyRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coachmarkKeyRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coachmarkKeyRegistryHash();

  @$internal
  @override
  CoachmarkKeyRegistry create() => CoachmarkKeyRegistry();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    Map<String, GlobalKey<State<StatefulWidget>>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Map<String, GlobalKey<State<StatefulWidget>>>>(
            value,
          ),
    );
  }
}

String _$coachmarkKeyRegistryHash() =>
    r'6c28e328b61940fedda6a2e720ef10d3edb9d07f';

/// A centralized registry mapping semantic key names to [GlobalKey] instances.
///
/// Plugins and toolbar widgets register their keys here during [initState]
/// or widget construction. The coachmark engine reads them to locate target
/// widgets on screen.
///
/// ## Usage
/// ```dart
/// // In a plugin's StatefulWidget.initState:
/// ref.read(coachmarkKeyRegistryProvider.notifier).register(
///   'timer.tab.bar',
///   _tabBarKey,
/// );
///
/// // In a SqaCoachmarkStep:
/// SqaCoachmarkStep(
///   targetKey: ref.read(coachmarkKeyRegistryProvider)['timer.tab.bar']
///       ?? GlobalKey(),
///   title: '...',
///   description: '...',
/// )
/// ```

abstract class _$CoachmarkKeyRegistry
    extends $Notifier<Map<String, GlobalKey<State<StatefulWidget>>>> {
  Map<String, GlobalKey<State<StatefulWidget>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, GlobalKey<State<StatefulWidget>>>,
              Map<String, GlobalKey<State<StatefulWidget>>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, GlobalKey<State<StatefulWidget>>>,
                Map<String, GlobalKey<State<StatefulWidget>>>
              >,
              Map<String, GlobalKey<State<StatefulWidget>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

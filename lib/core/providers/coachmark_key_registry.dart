import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'coachmark_key_registry.g.dart';

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
@Riverpod(keepAlive: true)
class CoachmarkKeyRegistry extends _$CoachmarkKeyRegistry {
  @override
  Map<String, GlobalKey> build() => {};

  /// Registers a [key] under a [name]. Overwrites any previous key with the
  /// same name so plugin rebuilds stay current.
  void register(String name, GlobalKey key) {
    state = {...state, name: key};
  }

  /// Removes a key from the registry (call from plugin dispose if needed).
  void unregister(String name) {
    state = Map.from(state)..remove(name);
  }

  /// Returns the key for [name], or null if not yet registered.
  GlobalKey? get(String name) => state[name];
}

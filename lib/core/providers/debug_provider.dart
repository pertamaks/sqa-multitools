import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'debug_provider.g.dart';

/// A notifier provider that toggles the visibility of developer diagnostics.
/// Activated via a hidden "Cheat Code" (5-tap sequence on Settings).
/// keepAlive is set to true to ensure the state persists during the session.
@Riverpod(keepAlive: true)
class DebugMode extends _$DebugMode {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

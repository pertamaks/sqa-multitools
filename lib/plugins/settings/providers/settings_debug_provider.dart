import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/services/coffee_shop_service.dart';
import '../../../core/providers/debug_provider.dart';

part 'settings_debug_provider.g.dart';

/// A simple trigger provider to signal from the settings UI to the main toolbar overlay
@riverpod
class BugTrigger extends _$BugTrigger {
  @override
  int? build() => null;

  void trigger(int side) {
    state = side;
    // Auto-reset so we can trigger the same side again if needed
    Future.microtask(() => state = null);
  }
}

@riverpod
class SettingsDebugActions extends _$SettingsDebugActions {
  @override
  void build() {}

  /// Resets all donation-related data and bug squash counters
  Future<void> resetLicense() async {
    final prefs = ref.read(preferencesServiceProvider);
    await ref.read(supporterTierProvider.notifier).reset();
    await prefs.setBugsSquashed(0);

    // Also reset theme to default (non-premium) values
    final themeNotifier = ref.read(themeSettingsProvider.notifier);
    themeNotifier.setSeedColor(0xFF009688); // Default Teal
    themeNotifier.setUseDynamicColor(false);
    themeNotifier.toggleTransparencyMode(false);
  }
}

@Riverpod(keepAlive: true)
class DebugTapCounter extends _$DebugTapCounter {
  @override
  int build() => 0;

  DateTime _lastTap = DateTime.fromMillisecondsSinceEpoch(0);

  /// Increments the tap counter and toggles developer mode if enough taps occurred within the timeframe.
  /// Returns whether developer mode was toggled.
  bool incrementAndCheck() {
    final now = DateTime.now();
    if (now.difference(_lastTap).inSeconds > 2) {
      state = 1;
    } else {
      state++;
    }
    _lastTap = now;

    if (state >= 5) {
      ref.read(debugModeProvider.notifier).toggle();
      state = 0;
      return true;
    }
    return false;
  }
}

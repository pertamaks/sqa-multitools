import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/preferences_service.dart';

part 'coachmark_provider.g.dart';

/// Manages the seen-state for all coachmark tours and exposes helpers for
/// the toolbar and plugin windows to check whether to auto-show a tour.
///
/// Persistence is delegated to [PreferencesService].
@Riverpod(keepAlive: true)
class CoachmarkService extends _$CoachmarkService {
  @override
  CoachmarkServiceState build() {
    final prefs = ref.watch(preferencesServiceProvider);
    return CoachmarkServiceState(
      toolbarSeen: prefs.isToolbarCoachmarkSeen(),
    );
  }

  // ── Toolbar ──────────────────────────────────────────────────────────────

  /// Returns true if the toolbar tour should auto-trigger on this launch.
  bool shouldShowToolbarTour() => !state.toolbarSeen;

  /// Marks the toolbar tour as completed so it won't auto-show again.
  Future<void> markToolbarTourSeen() async {
    await ref.read(preferencesServiceProvider).setToolbarCoachmarkSeen(true);
    state = state.copyWith(toolbarSeen: true);
  }

  // ── Plugin ────────────────────────────────────────────────────────────────

  /// Returns true if the tour for [pluginId] should auto-trigger on first open.
  bool shouldShowPluginTour(String pluginId) {
    return !ref
        .read(preferencesServiceProvider)
        .isPluginCoachmarkSeen(pluginId);
  }

  /// Marks a plugin tour as completed so it won't auto-show again.
  Future<void> markPluginTourSeen(String pluginId) async {
    await ref
        .read(preferencesServiceProvider)
        .setPluginCoachmarkSeen(pluginId, true);
  }

  // ── Manual Trigger ────────────────────────────────────────────────────────

  /// Signals a manual (re-)trigger of the tour for [pluginId].
  ///
  /// This does NOT reset the persistent seen-state — the user can still
  /// re-trigger via the (?) button anytime.
  void requestPluginTour(String pluginId) {
    state = state.copyWith(manualTriggerPluginId: () => pluginId);
  }

  /// Clears the manual trigger after the tour engine has consumed it.
  void clearManualTrigger() {
    state = state.copyWith(manualTriggerPluginId: () => null);
  }

  // ── Debug Reset ───────────────────────────────────────────────────────────

  /// Resets ALL coachmark seen-states (debug use only via 5-tap panel).
  Future<void> resetAll() async {
    await ref.read(preferencesServiceProvider).resetAllCoachmarks();
    state = const CoachmarkServiceState(toolbarSeen: false);
  }
}

/// Immutable state for [CoachmarkService].
class CoachmarkServiceState {
  final bool toolbarSeen;

  /// When non-null, the plugin with this ID has been manually requested to show
  /// its tour by the user pressing the (?) button.
  final String? manualTriggerPluginId;

  const CoachmarkServiceState({
    required this.toolbarSeen,
    this.manualTriggerPluginId,
  });

  CoachmarkServiceState copyWith({
    bool? toolbarSeen,
    String? Function()? manualTriggerPluginId,
  }) {
    return CoachmarkServiceState(
      toolbarSeen: toolbarSeen ?? this.toolbarSeen,
      manualTriggerPluginId: manualTriggerPluginId != null
          ? manualTriggerPluginId()
          : this.manualTriggerPluginId,
    );
  }
}

// Extension for nullable override in copyWith
extension CoachmarkServiceStateX on CoachmarkServiceState {
  CoachmarkServiceState withManualTrigger(String? pluginId) {
    return CoachmarkServiceState(
      toolbarSeen: toolbarSeen,
      manualTriggerPluginId: pluginId,
    );
  }
}

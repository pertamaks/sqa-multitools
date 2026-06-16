import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/preferences_service.dart';

part 'auto_start_provider.g.dart';

@riverpod
class AutoStart extends _$AutoStart {
  @override
  FutureOr<bool> build() async {
    final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool('auto_start_intent') ?? false;
  }

  Future<void> toggle(bool enable) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final SharedPreferences prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('auto_start_intent', enable);

      if (enable) {
        await launchAtStartup.enable();
      } else {
        await launchAtStartup.disable();
      }
      return enable;
    });
  }
}

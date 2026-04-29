import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'todo_provider.dart';
import '../models/todo_item.dart';

part 'todo_notification_provider.g.dart';

@Riverpod(keepAlive: true)
class TodoNotification extends _$TodoNotification {
  Timer? _timer;

  @override
  bool build() {
    // Start a timer to check every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkReminders());
    ref.onDispose(() => _timer?.cancel());
    return false; // hasActiveReminder
  }

  void _checkReminders() async {
    final settings = await ref.read(todoSettingsProvider.future);
    if (settings.wakeHour == null) return;

    final now = DateTime.now();
    final wakeTime = DateTime(now.year, now.month, now.day, settings.wakeHour!, settings.wakeMinute!);
    
    // Calculate 90-minute blocks from wakeTime
    // Blocks: wakeTime, wakeTime + 90m, wakeTime + 180m, ...
    
    // Find if current time is the "start" of a 90-minute block (e.g., within first 5 mins)
    final diffMinutes = now.difference(wakeTime).inMinutes;
    if (diffMinutes < 0) return; // Haven't woken up yet?

    final minutesIntoCycle = diffMinutes % 90;

    // Trigger if we are in the first 2 minutes of a new cycle
    if (minutesIntoCycle >= 0 && minutesIntoCycle < 2) {
      state = true;
      // If auto-open is enabled, we could trigger navigation here, 
      // but we should probably do that in a separate logic to avoid side-effects in build.
    }
  }

  /// Helper to get the current 90-minute block index or info
  int getCurrentCycleIndex(int wakeHour, int wakeMinute) {
    final now = DateTime.now();
    final wakeTime = DateTime(now.year, now.month, now.day, wakeHour, wakeMinute);
    final diffMinutes = now.difference(wakeTime).inMinutes;
    if (diffMinutes < 0) return -1;
    return diffMinutes ~/ 90;
  }

  /// Maps a DateTime to a TimeBlock based on the wake anchor
  TodoTimeBlock suggestTimeBlock(int wakeHour, int wakeMinute, DateTime time) {
    final hour = time.hour;

    if (hour >= 6 && hour < 9) return TodoTimeBlock.morning;
    if (hour >= 9 && hour < 11) return TodoTimeBlock.midMorning;
    if (hour >= 11 && hour < 13) return TodoTimeBlock.noon;
    if (hour >= 13 && hour < 15) return TodoTimeBlock.afternoon;
    if (hour >= 15 && hour < 17) return TodoTimeBlock.lateAfternoon;
    if (hour >= 17 && hour < 20) return TodoTimeBlock.evening;
    return TodoTimeBlock.night;
  } void clearReminder() {
    state = false;
  }
}

/// Provides a list of 90-minute block start times for the current day
@Riverpod(keepAlive: true)
List<DateTime> todoCycles(Ref ref) {
  final settings = ref.watch(todoSettingsProvider).value;
  if (settings == null || settings.wakeHour == null) return [];

  final now = DateTime.now();
  final wakeTime = DateTime(now.year, now.month, now.day, settings.wakeHour!, settings.wakeMinute!);
  
  return List.generate(10, (i) => wakeTime.add(Duration(minutes: i * 90)));
}

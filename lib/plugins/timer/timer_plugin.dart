import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'providers/timer_provider.dart';
import 'ui/clock_tab_view.dart';
import 'ui/timer_tab_view.dart';
import 'ui/unix_tab_view.dart';
import 'ui/counter_tab_view.dart';
import '../../core/models/sqa_plugin.dart';
import '../../core/services/audio_service.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';

class TimerPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.timer';
  @override
  String get name => 'Timer';
  @override
  String get description => 'A simple timer and stopwatch.';
  @override
  IconData get icon => Symbols.schedule;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _TimerPluginView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Timer Settings'));
  }

  @override
  Future<void> initialize() async {
    // Only pre-load the alarm when the timer plugin is actually accessed.
    unawaited(AudioService.instance.preLoad('sounds/alarm.mp3'));
  }

  @override
  Future<void> dispose() async {}
}

class _TimerPluginView extends ConsumerWidget {
  const _TimerPluginView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTimerRunning = ref.watch(timerProvider).isRunning;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 4,
      child: SqaPluginLayout(
        icon: Symbols.schedule,
        title: 'Timer & Tools',
        description: 'Clock, timer, Unix tools, and simple counter.',
        tabs: [
          const Tab(icon: Icon(Symbols.schedule), text: 'Clock'),
          Tab(
            icon: Icon(
              Symbols.timer,
              color: isTimerRunning ? theme.colorScheme.primary : null,
            ),
            text: isTimerRunning ? 'Timer •' : 'Timer',
          ),
          const Tab(icon: Icon(Symbols.data_object), text: 'Unix'),
          const Tab(icon: Icon(Symbols.exposure_plus_1), text: 'Counter'),
        ],
        child: const TabBarView(
          children: [
            ClockTabView(),
            TimerTabView(),
            UnixTabView(),
            CounterTabView(),
          ],
        ),
      ),
    );
  }
}

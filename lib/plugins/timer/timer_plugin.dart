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
import '../../core/models/sqa_coachmark_step.dart';
import '../../core/providers/coachmark_provider.dart';
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
    unawaited(AudioService.instance.preLoad('sounds/alarm.mp3'));
  }

  @override
  Future<void> dispose() async {}

  @override
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: _TimerPluginView.clockTabKey,
        title: 'Four Tools in One',
        description:
            'Switch between the Clock, a countdown Timer, Unix timestamp converter, and a manual Counter — each in its own tab.',
        contentAlign: CoachmarkContentAlign.bottom,
      ),
      SqaCoachmarkStep(
        targetKey: _TimerPluginView.timerTabKey,
        title: 'Countdown or Stopwatch',
        description:
            'Set a duration first, then press Start for a countdown. Leave it at 0:00 and press Start to use it as a stopwatch instead.',
        contentAlign: CoachmarkContentAlign.bottom,
        beforeStepAction: (ref) async {
          _TimerPluginView.tabController?.animateTo(1);
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
      ),
      SqaCoachmarkStep(
        targetKey: _TimerPluginView.counterTabKey,
        title: 'Track Anything, Manually',
        description:
            'The Counter tab lets you tally test cases, bugs found, or any event count. Reset requires confirmation so you never lose your tally.',
        contentAlign: CoachmarkContentAlign.bottom,
        beforeStepAction: (ref) async {
          _TimerPluginView.tabController?.animateTo(3);
          await Future<void>.delayed(const Duration(milliseconds: 350));
        },
      ),
    ];
  }
}

class _TimerPluginView extends ConsumerStatefulWidget {
  const _TimerPluginView();

  /// Stable GlobalKeys for the tabs — targeted by coachmark steps.
  static final clockTabKey = GlobalKey(debugLabel: 'timer.clock_tab');
  static final timerTabKey = GlobalKey(debugLabel: 'timer.timer_tab');
  static final counterTabKey = GlobalKey(debugLabel: 'timer.counter_tab');

  /// Shared TabController reference — populated on mount, cleared on dispose.
  /// Used by coachmark steps' beforeStepAction closures.
  static TabController? tabController;

  @override
  ConsumerState<_TimerPluginView> createState() => _TimerPluginViewState();
}

class _TimerPluginViewState extends ConsumerState<_TimerPluginView> {
  @override
  void initState() {
    super.initState();
    // Capture DefaultTabController after SqaPluginLayout has built it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _TimerPluginView.tabController = DefaultTabController.of(context);
      }
    });
  }

  @override
  void dispose() {
    _TimerPluginView.tabController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTimerRunning = ref.watch(timerProvider).isRunning;
    final theme = Theme.of(context);

    return SqaPluginLayout(
      icon: Symbols.schedule,
      title: 'Timer & Tools',
      description: 'Clock, timer, Unix tools, and simple counter.',
      onShowCoachmark: () {
        ref
            .read(coachmarkServiceProvider.notifier)
            .requestPluginTour('com.sqa.timer');
      },
      tabs: [
        Tab(
          key: _TimerPluginView.clockTabKey,
          icon: const Icon(Symbols.schedule),
          text: 'Clock',
        ),
        Tab(
          key: _TimerPluginView.timerTabKey,
          icon: Icon(
            Symbols.timer,
            color: isTimerRunning ? theme.colorScheme.primary : null,
          ),
          text: isTimerRunning ? 'Timer •' : 'Timer',
        ),
        const Tab(icon: Icon(Symbols.data_object), text: 'Unix'),
        Tab(
          key: _TimerPluginView.counterTabKey,
          icon: const Icon(Symbols.exposure_plus_1),
          text: 'Counter',
        ),
      ],
      child: const TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ClockTabView(),
          TimerTabView(),
          UnixTabView(),
          CounterTabView(),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'providers/timer_provider.dart';
import 'ui/interactive_time_segment.dart';
import 'providers/unix_provider.dart';
import 'providers/counter_provider.dart';
import 'ui/interactive_date_segment.dart';
import '../../core/models/sqa_plugin.dart';
import '../../core/services/audio_service.dart';
import '../../ui/widgets/sqa_icon_container.dart';
import '../../ui/widgets/sqa_field.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_button.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';

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

class _TimerPluginView extends StatelessWidget {
  const _TimerPluginView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SqaPluginLayout(
        icon: Symbols.schedule,
        title: 'Timer & Tools',
        description: 'Clock, timer, Unix tools, and simple counter.',
        tabs: const [
          Tab(icon: Icon(Symbols.schedule), text: 'Clock'),
          Tab(icon: Icon(Symbols.timer), text: 'Timer'),
          Tab(icon: Icon(Symbols.data_object), text: 'Unix'),
          Tab(icon: Icon(Symbols.exposure_plus_1), text: 'Counter'),
        ],
        child: const TabBarView(
          children: [
            _ClockTabView(),
            _TimerTabView(),
            _UnixTabView(),
            _CounterTabView(),
          ],
        ),
      ),
    );
  }
}

class _ClockTabView extends StatefulWidget {
  const _ClockTabView();

  @override
  State<_ClockTabView> createState() => _ClockTabViewState();
}

class _ClockTabViewState extends State<_ClockTabView> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SqaPluginScrollableContent(
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TimeDisplay(
              label: 'LOCAL TIME',
              time: _formatTime(_now),
              icon: Symbols.location_on,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            _TimeDisplay(
              label: 'UTC+0 TIME',
              time: _formatTime(_now.toUtc()),
              icon: Symbols.public,
              color: theme.colorScheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeDisplay({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaIconContainer(icon: icon, color: color, size: 36, iconSize: 20),
          const SizedBox(width: 16),
          Container(
            width: 1,
            height: 28,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                time,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerTabView extends ConsumerWidget {
  const _TimerTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    final duration = state.remaining;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final ms = duration.inMilliseconds.remainder(1000); // 3 digits

    return SqaPluginScrollableContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                state.initialDuration == Duration.zero
                    ? (state.isRunning ? 'STOPWATCH ACTIVE' : 'STOPWATCH READY')
                    : (state.isRunning
                          ? 'COUNTDOWN ACTIVE'
                          : 'COUNTDOWN READY'),
                key: ValueKey(
                  '${state.initialDuration == Duration.zero}_${state.isRunning}',
                ),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InteractiveTimeSegment(
                value: hours,
                maxValue: 99,
                isEnabled: !state.isRunning,
                onChanged: (v) {
                  final newDur = Duration(
                    hours: v,
                    minutes: state.initialDuration.inMinutes.remainder(60),
                    seconds: state.initialDuration.inSeconds.remainder(60),
                  );
                  notifier.setDuration(newDur);
                },
              ),
              _buildColon(theme),
              InteractiveTimeSegment(
                value: minutes,
                maxValue: 59,
                isEnabled: !state.isRunning,
                onChanged: (v) {
                  final newDur = Duration(
                    hours: state.initialDuration.inHours,
                    minutes: v,
                    seconds: state.initialDuration.inSeconds.remainder(60),
                  );
                  notifier.setDuration(newDur);
                },
              ),
              _buildColon(theme),
              InteractiveTimeSegment(
                value: seconds,
                maxValue: 59,
                isEnabled: !state.isRunning,
                onChanged: (v) {
                  final newDur = Duration(
                    hours: state.initialDuration.inHours,
                    minutes: state.initialDuration.inMinutes.remainder(60),
                    seconds: v,
                  );
                  notifier.setDuration(newDur);
                },
              ),
              // Milliseconds (non-interactive display)
              // Milliseconds (non-interactive display)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24), // Match top arrow height
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      '.${ms.toString().padLeft(3, '0')}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Match bottom arrow height
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SqaButton.tonal(
                onPressed: notifier.toggle,
                icon: state.isRunning ? Symbols.pause : Symbols.play_arrow,
                label: state.isRunning ? 'Pause' : 'Start',
                width: 100,
              ),
              const SizedBox(width: 12),
              SqaButton.outlined(
                onPressed: notifier.reset,
                icon: Symbols.restart_alt,
                label: 'Reset',
                width: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColon(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        ':',
        style: theme.textTheme.displaySmall?.copyWith(
          fontFamily: 'monospace',
          color: theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _UnixTabView extends ConsumerStatefulWidget {
  const _UnixTabView();

  @override
  ConsumerState<_UnixTabView> createState() => _UnixTabViewState();
}

class _UnixTabViewState extends ConsumerState<_UnixTabView> {
  late TextEditingController _unixController;

  @override
  void initState() {
    super.initState();
    final initialTs = ref.read(unixProvider).manualTimestampString;
    _unixController = TextEditingController(text: initialTs);
  }

  @override
  void dispose() {
    _unixController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unixProvider);
    final notifier = ref.read(unixProvider.notifier);
    final theme = Theme.of(context);

    // Sync controller if state changed from outside (e.g. ticking or conversion)
    if (_unixController.text != state.manualTimestampString) {
      _unixController.text = state.manualTimestampString;
    }

    final dt = state.manualDateTime;

    return SqaPluginScrollableContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Human Readable Section
          Row(
            children: [
              Icon(
                Symbols.calendar_today,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'HUMAN READABLE',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: theme.colorScheme.primary,
                ),
              ),
              const Spacer(),
              // UTC Offset next to LIVE label
              Text(
                '${dt.timeZoneOffset.inHours >= 0 ? '+' : ''}${dt.timeZoneOffset.inHours}h ',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.isLive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.fiber_manual_record,
                        size: 10,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDateTimeInput(dt, state.isLive, notifier),

          const SizedBox(height: 20),

          // Conversion & Reset Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SqaButton.tonal(
                onPressed: notifier.convert,
                icon: state.lastInteractionWasDateTime
                    ? Symbols.arrow_downward
                    : Symbols.arrow_upward,
                label: state.lastInteractionWasDateTime
                    ? 'Generate Unix'
                    : 'Sync Date Time',
              ),
              if (!state.isLive) ...[
                const SizedBox(width: 12),
                SqaButton.outlined(
                  onPressed: notifier.resetToNow,
                  icon: Symbols.restore,
                  label: 'Now',
                ),
              ],
            ],
          ),

          const SizedBox(height: 20),

          // Unix Section
          SqaField(
            label: 'Unix Timestamp (Seconds)',
            controller: _unixController,
            icon: Symbols.data_object,
            isMonospace: true,
            onChanged: (val) => notifier.setTimestampString(val),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeInput(DateTime dt, bool isLive, UnixNotifier notifier) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InteractiveDateSegment(
          label: 'Year',
          value: dt.year,
          minValue: 1970,
          maxValue: 2100,
          digits: 4,
          isEnabled: true,
          onChanged: (v) => notifier.setDateTime(
            DateTime(v, dt.month, dt.day, dt.hour, dt.minute, dt.second),
          ),
        ),
        _buildDivider(),
        InteractiveDateSegment(
          label: 'Month',
          value: dt.month,
          minValue: 1,
          maxValue: 12,
          onChanged: (v) => notifier.setDateTime(
            DateTime(dt.year, v, dt.day, dt.hour, dt.minute, dt.second),
          ),
        ),
        _buildDivider(),
        InteractiveDateSegment(
          label: 'Day',
          value: dt.day,
          minValue: 1,
          maxValue: 31,
          onChanged: (v) => notifier.setDateTime(
            DateTime(dt.year, dt.month, v, dt.hour, dt.minute, dt.second),
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 24, color: Colors.grey.withAlpha(50)),
        const SizedBox(width: 8),
        InteractiveDateSegment(
          label: 'Hour',
          value: dt.hour,
          minValue: 0,
          maxValue: 23,
          onChanged: (v) => notifier.setDateTime(
            DateTime(dt.year, dt.month, dt.day, v, dt.minute, dt.second),
          ),
        ),
        _buildDivider(),
        InteractiveDateSegment(
          label: 'Min',
          value: dt.minute,
          minValue: 0,
          maxValue: 59,
          onChanged: (v) => notifier.setDateTime(
            DateTime(dt.year, dt.month, dt.day, dt.hour, v, dt.second),
          ),
        ),
        _buildDivider(),
        InteractiveDateSegment(
          label: 'Sec',
          value: dt.second,
          minValue: 0,
          maxValue: 59,
          onChanged: (v) => notifier.setDateTime(
            DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, v),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Text(
        '/',
        style: TextStyle(color: Colors.grey.withAlpha(50), fontSize: 10),
      ),
    );
  }
}

class _CounterTabView extends ConsumerWidget {
  const _CounterTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final notifier = ref.read(counterProvider.notifier);
    final theme = Theme.of(context);

    return SqaPluginScrollableContent(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SqaButton.tonal(
                onPressed: notifier.decrement,
                icon: Symbols.remove,
                label: '',
                width: 56,
              ),
              const SizedBox(width: 32),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    '$count',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              SqaButton.tonal(
                onPressed: notifier.increment,
                icon: Symbols.add,
                label: '',
                width: 56,
              ),
            ],
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: count != 0
                ? SqaButton.outlined(
                    key: const ValueKey('reset'),
                    onPressed: notifier.reset,
                    icon: Symbols.restart_alt,
                    label: 'Reset',
                    width: 120,
                  )
                : const SizedBox(height: 32, key: ValueKey('empty')),
          ),
        ],
      ),
    );
  }
}

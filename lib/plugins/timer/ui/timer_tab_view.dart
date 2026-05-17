import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/timer_provider.dart';
import 'interactive_time_segment.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';


class TimerTabView extends ConsumerWidget {
  const TimerTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    final duration = state.remaining;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final ms = duration.inMilliseconds.remainder(1000);

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
                style: SqaTextStyles.bodySecondary(context).copyWith(
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: SqaTokens.spacingMedium),
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
              _buildColon(context, theme, state.isRunning),
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
              _buildColon(context, theme, state.isRunning),
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
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: SqaTokens.spacingXLarge),
                  Padding(
                    padding: const EdgeInsets.only(left: SqaTokens.spacingXSmall),
                    child: Text(
                      '.${ms.toString().padLeft(3, '0')}',
                        style: SqaTextStyles.mono(
                          context,
                          fontSize: SqaTokens.spacingXLarge,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ).copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                    ),
                  ),
                  const SizedBox(height: SqaTokens.spacingXLarge),
                ],
              ),
            ],
          ),
          const SizedBox(height: SqaTokens.spacingXLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SqaButton.primary(
                onPressed: notifier.toggle,
                icon: state.isRunning ? Symbols.pause : Symbols.play_arrow,
                label: state.isRunning ? 'Pause' : 'Start',
                width: SqaTokens.spacingXXXLarge * 2.5, // 120px standardized
              ),
              const SizedBox(width: SqaTokens.spacingMedium),
              Builder(
                builder: (context) {
                  final isAtInitial =
                      state.remaining == state.initialDuration &&
                      !state.isRunning;
                  final isCountdown = state.initialDuration > Duration.zero;
                  final showStopwatchMode = isCountdown && isAtInitial;

                  return SqaButton.tonal(
                    onPressed: () async {
                      if (showStopwatchMode) {
                        notifier.setDuration(Duration.zero);
                        return;
                      }

                      // Safety: Confirmation for Reset if progress was made or it's running
                      if (state.remaining != state.initialDuration ||
                          state.isRunning) {
                        final confirmed = await SqaModal.showDanger(
                          context,
                          title: 'Reset Timer',
                          message:
                              'Are you sure you want to reset the timer? Current progress will be lost.',
                          confirmLabel: 'Reset',
                        );
                        if (confirmed != true) return;
                      }
                      notifier.reset();
                    },
                    icon: showStopwatchMode
                        ? Symbols.timer
                        : Symbols.restart_alt,
                    label: showStopwatchMode ? 'Stopwatch' : 'Reset',
                    width: SqaTokens.spacingXXXLarge * 2.5, // 120px standardized
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColon(BuildContext context, ThemeData theme, bool isRunning) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: SqaTokens.spacingXLarge),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SqaTokens.spacingXSmall,
            0,
            SqaTokens.spacingXSmall,
            SqaTokens.spacingXSmall,
          ),
          child: Text(
            ':',
            style: SqaTextStyles.mono(context, fontSize: SqaTokens.spacingXXLarge).copyWith(
              color: isRunning
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                  : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: SqaTokens.spacingXLarge),
      ],
    );
  }
}

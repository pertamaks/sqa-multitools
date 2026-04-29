import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/unix_provider.dart';
import 'interactive_date_segment.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_field.dart';

class UnixTabView extends ConsumerStatefulWidget {
  const UnixTabView({super.key});

  @override
  ConsumerState<UnixTabView> createState() => _UnixTabViewState();
}

class _UnixTabViewState extends ConsumerState<UnixTabView> {
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
              SqaButton.primary(
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
                SqaButton.tonal(
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

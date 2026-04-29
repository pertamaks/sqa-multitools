import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_icon_container.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';

class ClockTabView extends StatefulWidget {
  const ClockTabView({super.key});

  @override
  State<ClockTabView> createState() => _ClockTabViewState();
}

class _ClockTabViewState extends State<ClockTabView> {
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
            TimeDisplay(
              label: 'LOCAL TIME',
              time: _formatTime(_now),
              icon: Symbols.location_on,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            TimeDisplay(
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

class TimeDisplay extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const TimeDisplay({
    super.key,
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
              _buildClockTime(theme, time),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClockTime(ThemeData theme, String time) {
    final parts = time.split(':');
    final style = theme.textTheme.headlineMedium?.copyWith(
      fontFamily: 'monospace',
      fontWeight: FontWeight.w600,
      color: theme.colorScheme.onSurface,
    );

    if (parts.length != 3) {
      return Text(time, style: style);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(parts[0], style: style),
        _buildClockColon(style),
        Text(parts[1], style: style),
        _buildClockColon(style),
        Text(parts[2], style: style),
      ],
    );
  }

  Widget _buildClockColon(TextStyle? style) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0), // Nudge up slightly to center
      child: Text(
        ':',
        style: style,
      ),
    );
  }
}

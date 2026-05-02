import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'providers/todo_provider.dart';
import 'services/todo_storage_service.dart';
import 'ui/todo_view.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_switch.dart';

class TodoPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.todo';

  @override
  String get name => 'Focus Block';

  @override
  String get description => 'Task management with cognitive energy cycles.';

  @override
  IconData get icon => Symbols.blur_on;

  @override
  String? get badge => null;

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const TodoView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const _TodoSettings();
  }

  @override
  Future<void> initialize() async {
    // Eagerly load storage data to prevent UI stutter on first open
    final storage = TodoStorageService();
    await Future.wait([
      storage.loadSettings(),
      storage.loadAllTodos(),
      storage.loadRecurringTodos(),
    ]);
  }

  @override
  Future<void> dispose() async {
    // Cleanup logic
  }

  @override
  List<PermissionRequirement> get requiredPermissions => [];
}

class _TodoSettings extends ConsumerWidget {
  const _TodoSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(todoSettingsProvider);
    final theme = Theme.of(context);

    return settingsAsync.when(
      data: (settings) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Cognitive Energy Configuration',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 1.0,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SqaCard(
            padding: EdgeInsets.zero,
            margin: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                SqaSettingsTile(
                  icon: Symbols.alarm,
                  title: 'Wake Anchor',
                  subtitle: settings.wakeHour != null
                      ? '${settings.wakeHour.toString().padLeft(2, '0')}:${settings.wakeMinute.toString().padLeft(2, '0')}'
                      : 'Not set',
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Symbols.info,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 1),
                SqaSettingsTile(
                  icon: Symbols.calendar_today,
                  title: 'Ask Wake Time Daily',
                  subtitle: 'Prompt every morning to align cycles',
                  trailing: SqaSwitch(
                    value: settings.askWakeTimeDaily,
                    onChanged: (v) => ref
                        .read(todoSettingsProvider.notifier)
                        .updateSettings(settings.copyWith(askWakeTimeDaily: v)),
                  ),
                ),
                const Divider(height: 1),
                SqaSettingsTile(
                  icon: Symbols.open_in_new,
                  title: 'Auto-Open on Reminder',
                  subtitle: 'Jump to focus block list when a block starts',
                  trailing: SqaSwitch(
                    value: settings.autoOpenOnReminder,
                    onChanged: (v) => ref
                        .read(todoSettingsProvider.notifier)
                        .updateSettings(
                          settings.copyWith(autoOpenOnReminder: v),
                        ),
                  ),
                ),
                const Divider(height: 1),
                SqaSettingsTile(
                  icon: Symbols.history,
                  title: 'History Retention',
                  subtitle:
                      'Keep tasks for ${settings.historyRetentionDays} days',
                  trailing: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Text(
                      '${settings.historyRetentionDays}d',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading settings: $e')),
    );
  }
}

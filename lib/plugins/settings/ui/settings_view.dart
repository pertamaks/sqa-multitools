import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../core/providers/plugin_provider.dart';
import '../providers/settings_debug_provider.dart';
import 'general_settings_view.dart';
import 'plugins_settings_view.dart';
import 'coffee_shop_view.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialTab = ref.watch(settingsTabProvider);
    final history = ref.watch(navigationHistoryProvider);
    final navService = ref.read(navigationServiceProvider);

    return SqaPluginLayout(
      icon: Symbols.settings,
      title: 'System Settings',
      description: 'Personalize your SQA-Multitools experience.',
      onBack: history != null ? () => navService.goBack() : null,
      useMask: false, // Handle internal fading for specific tabs
      initialTabIndex: initialTab,
      tabs: const [
        Tab(icon: Icon(Symbols.settings), text: 'General'),
        Tab(icon: Icon(Symbols.extension), text: 'Plugins'),
        Tab(icon: Icon(Symbols.coffee), text: 'Coffee Shop'),
      ],
      child: const TabBarView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          SqaFadeWrapper(child: GeneralSettingsView()),
          PluginsSettingsView(),
          SqaFadeWrapper(child: CoffeeShopView()),
        ],
      ),
    );
  }
}

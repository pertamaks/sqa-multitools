import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../core/providers/plugin_provider.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_icon_container.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_safe_plugin_builder.dart';
import '../../../ui/widgets/sqa_design_tokens.dart';

class PluginsSettingsView extends ConsumerStatefulWidget {
  const PluginsSettingsView({super.key});

  @override
  ConsumerState<PluginsSettingsView> createState() =>
      _PluginsSettingsViewState();
}

class _PluginsSettingsViewState extends ConsumerState<PluginsSettingsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToFocused();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocused() {
    final history = ref.read(navigationHistoryProvider);
    if (history == null) return;

    final allPlugins = ref.read(orderedAvailablePluginsProvider);
    final index = allPlugins.indexWhere((p) => p.id == history);

    if (index != -1 && _scrollController.hasClients) {
      // Estimate position: each collapsed card is ~72px high + 8px margin
      const itemHeight = 80.0;
      final targetOffset = (index * itemHeight).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allPlugins = ref.watch(orderedAvailablePluginsProvider);
    final enabledPlugins = ref.watch(enabledPluginsProvider);
    final history = ref.watch(navigationHistoryProvider);
    final editMode = ref.watch(pluginEditModeProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(SqaTokens.spacingLarge, SqaTokens.spacingSmall, SqaTokens.spacingLarge, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                editMode ? 'Rearrange Plugins' : 'Manage Plugins',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SqaButton(
                label: editMode ? 'Done' : 'Sort',
                icon: editMode ? Symbols.check : Symbols.sort,
                onPressed: () {
                  ref.read(pluginEditModeProvider.notifier).toggle();
                },
                width: 85,
              ),
            ],
          ),
        ),
        Expanded(
          child: SqaFadeWrapper(
            child: Scrollbar(
              controller: _scrollController,
              child: ReorderableListView.builder(
                onReorder: (oldIndex, newIndex) {
                  ref
                      .read(enabledPluginsProvider.notifier)
                      .reorder(oldIndex, newIndex);
                },
                scrollController: _scrollController,
                padding: const EdgeInsets.all(SqaTokens.spacingLarge),
                itemCount: allPlugins.length,
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return AnimatedBuilder(
                    animation: animation,
                    builder: (context, child) {
                      final animValue = Curves.easeInOut.transform(
                        animation.value,
                      );
                      final elevation = lerpDouble(0, 6, animValue)!;
                      return Material(
                        elevation: elevation,
                        color: Colors.transparent,
                        shadowColor: Colors.black26,
                        borderRadius: SqaStyles.radiusLarge,
                        child: child,
                      );
                    },
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final plugin = allPlugins[index];
                  final isEnabled = enabledPlugins.any(
                    (p) => p.id == plugin.id,
                  );
                  final isFocused = !editMode && history == plugin.id;

                  return SqaCard(
                    // Use a dynamic key to force rebuild and collapse when toggling editMode
                    key: ValueKey('${plugin.id}_$editMode'),
                    margin: const EdgeInsets.only(bottom: SqaTokens.spacingSmall),
                    padding: EdgeInsets.zero,
                    borderSide: isFocused
                        ? BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1.5,
                          )
                        : null,
                    child: ExpansionTile(
                      collapsedShape: const Border(),
                      shape: const Border(),
                      // Disable expansion interactions in Edit Mode
                      enabled: !editMode,
                      initiallyExpanded: isFocused,
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (editMode)
                            ReorderableDragStartListener(
                              index: index,
                              child: Padding(
                                padding: const EdgeInsets.only(right: SqaTokens.spacingMedium),
                                child: Icon(
                                  Symbols.drag_indicator,
                                  size: SqaTokens.spacingXLarge,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                          SqaIconContainer(
                            icon: plugin.icon,
                            size: SqaTokens.spacingXXLarge,
                            iconSize: SqaTokens.spacingLarge + SqaTokens.spacingTiny,
                          ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Text(
                            plugin.name,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (plugin.badge != null) ...[
                            const SizedBox(width: SqaTokens.spacingSmall),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: plugin.badge == 'ALPHA'
                                    ? Colors.amber
                                    : plugin.badge == 'BETA'
                                    ? Colors.blue
                                    : Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(SqaTokens.spacingXSmall),
                              ),
                              child: Text(
                                plugin.badge!,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      plugin.badge == 'ALPHA' ||
                                          plugin.badge == 'BETA'
                                      ? Colors.white
                                      : Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        plugin.description,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      // Hide toggle switches in Edit Mode to reduce clutter
                      trailing: editMode
                          ? const SizedBox.shrink()
                          : SqaSwitch(
                              value: isEnabled,
                              onChanged: (v) {
                                ref
                                    .read(enabledPluginsProvider.notifier)
                                    .togglePlugin(plugin.id, v);
                              },
                            ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(SqaTokens.spacingLarge),
                          child: SizedBox(
                            width: double.infinity,
                            child: SqaSafePluginBuilder(
                              pluginId: plugin.id,
                              pluginName: '${plugin.name} Settings',
                              builder: (context) => plugin.buildSettingsPanel(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../core/models/sqa_plugin.dart';
import 'package:sqa_multitools/plugins/color_picker/providers/color_picker_provider.dart';
import 'package:sqa_multitools/plugins/color_picker/widgets/color_format_card.dart';
import 'package:sqa_multitools/plugins/color_picker/widgets/shades_sidebar.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_button.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';

class ColorPickerPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.color_picker';
  @override
  String get name => 'Color Picker';
  @override
  String get description => 'Pick colors from screen.';
  @override
  IconData get icon => Symbols.color_lens;
  @override
  String? get badge => 'ALPHA';
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _ColorPickerView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Color Picker Settings'));
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _ColorPickerView extends ConsumerWidget {
  const _ColorPickerView();

  String _toHex(Color color) =>
      color.toARGB32().toRadixString(16).substring(2).toUpperCase();

  String _toRgb(Color color) =>
      'rgb(${(color.r * 255).toInt()}, ${(color.g * 255).toInt()}, ${(color.b * 255).toInt()})';

  String _toHsl(Color color) {
    final hsl = HSLColor.fromColor(color);
    return 'hsl(${(hsl.hue).toInt()}, ${(hsl.saturation * 100).toInt()}%, ${(hsl.lightness * 100).toInt()}%)';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(colorPickerProvider);
    final theme = Theme.of(context);

    return SqaPluginLayout(
      icon: Symbols.colorize,
      title: 'Color Picker',
      description: 'Analyze screen colors and convert formats.',
      trailing: SqaButton.tonal(
        onPressed: () {
          // Color picking logic would go here
        },
        icon: Symbols.colorize,
        label: 'Pick',
        width: 80,
      ),
      child: SqaPluginScrollableContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color History Bubbles
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  ...state.history
                      .take(5)
                      .map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => ref
                                .read(colorPickerProvider.notifier)
                                .updateColor(c),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant,
                                  width: 2,
                                ),
                                boxShadow: [
                                  if (c == state.activeColor)
                                    BoxShadow(
                                      color: c.withValues(alpha: 100 / 255),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShadesSidebar(color: state.activeColor),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      ColorFormatCard(
                        label: 'HEX',
                        value: _toHex(state.activeColor),
                      ),
                      ColorFormatCard(
                        label: 'RGB',
                        value: _toRgb(state.activeColor),
                      ),
                      ColorFormatCard(
                        label: 'HSL',
                        value: _toHsl(state.activeColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

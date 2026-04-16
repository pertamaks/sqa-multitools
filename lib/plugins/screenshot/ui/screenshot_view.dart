import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_settings_tile.dart';
import '../../../ui/widgets/sqa_switch.dart';
import '../../../ui/widgets/sqa_dropdown.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../../core/models/capture_mode.dart';
import '../providers/screenshot_provider.dart';

class ScreenshotView extends ConsumerWidget {
  const ScreenshotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(screenshotProvider);
    final notifier = ref.read(screenshotProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SqaPluginLayout(
      icon: Symbols.crop,
      title: 'Screenshot',
      description: 'Capture a region and draw directly on it.',
      color: colorScheme.primary,
      trailing: SqaButton.tonal(
        onPressed: state.isCapturing || state.isOverlayVisible
            ? null
            : notifier.capture,
        icon: state.isCapturing ? null : Symbols.camera_enhance,
        label: state.isCapturing ? 'Saving...' : 'Start Capture',
        isLoading: state.isCapturing,
        width: 130,
      ),
      child: SqaPluginScrollableContent(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture Mode',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SqaSegmentedButton<CaptureMode>(
              segments: const [
                ButtonSegment(
                  value: CaptureMode.fullScreen,
                  label: Text('Full Screen'),
                  icon: Icon(Symbols.fullscreen, size: 18),
                ),
                ButtonSegment(
                  value: CaptureMode.area,
                  label: Text('Area'),
                  icon: Icon(Symbols.crop_free, size: 18),
                ),
                ButtonSegment(
                  value: CaptureMode.window,
                  label: Text('Window'),
                  icon: Icon(Symbols.window, size: 18),
                ),
              ],
              selected: {state.captureMode},
              onSelectionChanged: (Set<CaptureMode> selected) {
                notifier.setCaptureMode(selected.first);
              },
            ),
            const SizedBox(height: 24),
            SqaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuration',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SqaSettingsTile(
                    title: 'Include Cursor',
                    subtitle: 'Show the mouse pointer in the screenshot',
                    trailing: SqaSwitch(
                      value: state.includeCursor,
                      onChanged: notifier.toggleIncludeCursor,
                    ),
                  ),
                  const Divider(height: 1),
                  SqaSettingsTile(
                    title: 'Format',
                    subtitle: 'Selection image file format',
                    trailing: SqaDropdown<String>(
                      value: state.format,
                      onChanged: (val) => notifier.setFormat(val!),
                      items: ['PNG', 'JPG', 'WEBP']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'dart:async';
import 'dart:math';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_toast.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_dropdown.dart';
import '../../ui/widgets/sqa_card.dart';
import 'providers/magic_8ball_provider.dart';

class QaOraclePlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.magic8ball';
  @override
  String get name => 'QA Oracle';
  @override
  String get description =>
      'Get sarcastic but honest answers to your toughest QA questions.';
  @override
  IconData get icon => Symbols.auto_awesome;
  @override
  String? get badge => 'FUN';
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _QaOracleWindow();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const _QaOracleSettingsPanel();
  }

  @override
  Future<void> initialize() async {
    // Warm up the 8-ball image asset to ensure the first "shake" animation is smooth
    final ImageStream stream =
        const AssetImage('assets/8ball.png').resolve(ImageConfiguration.empty);
    final completer = Completer<void>();
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool sync) {
        completer.complete();
        stream.removeListener(listener!);
      },
      onError: (Object e, StackTrace? s) {
        completer.completeError(e);
        stream.removeListener(listener!);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }
  @override
  Future<void> dispose() async {}
}

class _QaOracleSettingsPanel extends ConsumerWidget {
  const _QaOracleSettingsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(oracleSettingsProvider);

    return SqaCard(
      padding: EdgeInsets.zero,
      child: SqaSettingsTile(
        icon: Symbols.psychology,
        title: 'Oracle Personality',
        subtitle: 'Choose how the Oracle communicates with you.',
        trailing: SqaDropdown<OracleMode>(
          value: settings.mode,
          items: OracleMode.values.map((mode) {
            return DropdownMenuItem<OracleMode>(
              value: mode,
              child: Text(mode.label),
            );
          }).toList(),
          onChanged: (OracleMode? mode) {
            if (mode != null) {
              ref.read(oracleSettingsProvider.notifier).setMode(mode);
            }
          },
        ),
      ),
    );
  }
}

class _QaOracleWindow extends ConsumerStatefulWidget {
  const _QaOracleWindow();

  @override
  ConsumerState<_QaOracleWindow> createState() => _QaOracleWindowState();
}

class _QaOracleWindowState extends ConsumerState<_QaOracleWindow>
    with SingleTickerProviderStateMixin {
  String _currentResponse = 'Ask your question and shake...';
  late AnimationController _controller;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shake() {
    if (_controller.isAnimating) return;

    _controller.forward(from: 0).then((_) => _controller.reverse());
    final responses = ref.read(oracleResponsesProvider);
    setState(() {
      _currentResponse = responses[_random.nextInt(responses.length)];
    });
  }

  void _copyToClipboard() {
    if (_currentResponse == 'Ask your question and shake...') return;

    Clipboard.setData(ClipboardData(text: _currentResponse));
    SqaToast.show(
      context,
      'Advice copied to clipboard!',
      type: SqaToastType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _shake,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final offset = sin(_controller.value * pi * 4) * 8;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: child,
                );
              },
              child: Image.asset('assets/8ball.png', width: 120, height: 120),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _copyToClipboard,
            child: Tooltip(
              message: 'Click to copy advice',
              child: Text(
                _currentResponse,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap the Oracle to consult or text to copy',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

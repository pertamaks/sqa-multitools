import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'dart:math';
import '../../core/models/sqa_plugin.dart';

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

  final List<String> _responses = [
    'Works on my machine™',
    'Have you tried deleting node_modules?',
    'Ship it. YOLO.',
    'That\'s not a bug, it\'s a feature request.',
    'Did you check the logs? ...me neither.',
    'It\'s definitely a DNS issue.',
    'LGTM, ship it.',
    'Cannot reproduce. Closing.',
    'It worked in staging...',
    'Who wrote this? Oh, it was me.',
    'Complexity: High. Confidence: Low.',
    'Retesting won\'t fix it, but try anyway.',
    'The requirements were ambiguous.',
    'It\'s a caching issue. Probably.',
    'The AI said it was fine.',
    'I feel a P1 coming on.',
    'Refresh and hope for the best.',
    'The backend is down.',
    'Have you tried turning it off and on?',
    'It\'s fine. Everything is fine. 🔥',
  ];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return _QaOracleWindow(responses: _responses);
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Consult the Oracle for guidance.'));
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _QaOracleWindow extends StatefulWidget {
  final List<String> responses;
  const _QaOracleWindow({required this.responses});

  @override
  State<_QaOracleWindow> createState() => _QaOracleWindowState();
}

class _QaOracleWindowState extends State<_QaOracleWindow>
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
    setState(() {
      _currentResponse =
          widget.responses[_random.nextInt(widget.responses.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _shake,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        alignment: Alignment.center, // Center horizontally and vertically
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Horizontal center
          children: [
            AnimatedBuilder(
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
            const SizedBox(height: 32),
            Text(
              _currentResponse,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap to consult the Oracle',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

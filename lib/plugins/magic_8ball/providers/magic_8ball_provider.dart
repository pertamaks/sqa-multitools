import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/preferences_service.dart';

enum OracleMode {
  savage('Savage'),
  corporate('Corporate'),
  mystic('Mystic');

  final String label;
  const OracleMode(this.label);
}

class OracleSettings {
  final OracleMode mode;

  const OracleSettings({required this.mode});

  OracleSettings copyWith({OracleMode? mode}) {
    return OracleSettings(mode: mode ?? this.mode);
  }
}

class OracleSettingsNotifier extends Notifier<OracleSettings> {
  @override
  OracleSettings build() {
    final service = ref.watch(preferencesServiceProvider);
    final index = service.getOracleModeIndex();
    return OracleSettings(mode: OracleMode.values[index]);
  }

  void setMode(OracleMode mode) {
    state = state.copyWith(mode: mode);
    ref.read(preferencesServiceProvider).setOracleModeIndex(mode.index);
  }
}

final oracleSettingsProvider =
    NotifierProvider<OracleSettingsNotifier, OracleSettings>(() {
      return OracleSettingsNotifier();
    });

final oracleResponsesProvider = Provider<List<String>>((ref) {
  final mode = ref.watch(oracleSettingsProvider).mode;

  switch (mode) {
    case OracleMode.corporate:
      return [
        'Let\'s take this offline.',
        'Circling back to this later.',
        'Pending stakeholder alignment.',
        'Leveraging cross-functional synergies.',
        'Pivot to a more strategic approach.',
        'Low-hanging fruit identified.',
        'In the interest of bandwidth, no.',
        'Let\'s "parking lot" that idea.',
        'Synergize and touch base.',
        'Actionable insights pending.',
      ];
    case OracleMode.mystic:
      return [
        'It is certain.',
        'It is decidedly so.',
        'Without a doubt.',
        'Yes, definitely.',
        'You may rely on it.',
        'As I see it, yes.',
        'Reply hazy, try again.',
        'Ask again later.',
        'Better not tell you now.',
        'Cannot predict now.',
        'Concentrate and ask again.',
        'Don\'t count on it.',
        'My reply is no.',
        'My sources say no.',
        'Outlook not so good.',
        'Very doubtful.',
      ];
    case OracleMode.savage:
      return [
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
  }
});

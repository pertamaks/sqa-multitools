import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/environment.dart';
import '../../../core/services/preferences_service.dart';

part 'environments_provider.g.dart';

@Riverpod(keepAlive: true)
class Environments extends _$Environments {
  @override
  List<Environment> build() {
    try {
      final prefs = ref.read(preferencesServiceProvider);
      final envsJson = prefs.rawPrefs.getString(
        PreferencesService.keyCurlEnvironments,
      );

      if (envsJson != null) {
        final decoded = jsonDecode(envsJson) as List;
        return decoded
            .map((e) => Environment.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    // Default empty environment
    return [const Environment(id: 'default', name: 'Global', variables: {})];
  }

  void addEnvironment(Environment env) {
    state = [...state, env];
    _save();
  }

  void updateEnvironment(Environment env) {
    state = [
      for (final e in state)
        if (e.id == env.id) env else e,
    ];
    _save();
  }

  void removeEnvironment(String id) {
    state = state.where((e) => e.id != id).toList();
    if (state.isEmpty) {
      state = [const Environment(id: 'default', name: 'Global', variables: {})];
    }
    _save();
  }

  void _save() {
    final prefs = ref.read(preferencesServiceProvider);
    final json = jsonEncode(state.map((e) => e.toJson()).toList());
    prefs.rawPrefs.setString(PreferencesService.keyCurlEnvironments, json);
  }
}

@Riverpod(keepAlive: true)
class ActiveEnvironmentId extends _$ActiveEnvironmentId {
  @override
  String build() {
    final prefs = ref.read(preferencesServiceProvider);
    return prefs.rawPrefs.getString(
          '${PreferencesService.keyCurlEnvironments}_active_id',
        ) ??
        'default';
  }

  void setActiveId(String id) {
    state = id;
    ref
        .read(preferencesServiceProvider)
        .rawPrefs
        .setString('${PreferencesService.keyCurlEnvironments}_active_id', id);
  }
}

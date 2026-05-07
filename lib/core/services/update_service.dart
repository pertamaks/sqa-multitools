import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/update_info.dart';

part 'update_service.g.dart';

@riverpod
UpdateService updateService(Ref ref) {
  return UpdateService();
}

class UpdateService {
  static const String _updateUrl =
      'https://sqa-multitools.pages.dev/version.json';

  Future<UpdateInfo?> checkForUpdates(String currentVersion) async {
    try {
      final response = await http
          .get(Uri.parse(_updateUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final latestVersion = data['version'] as String;

        if (_isNewer(latestVersion, currentVersion)) {
          return UpdateInfo.fromJson(data);
        }
      }
    } catch (e) {
      // Log error or handle silently as per UX guidelines
    }
    return null;
  }

  bool _isNewer(String latest, String current) {
    final latestParts = latest.split('.').map(int.tryParse).toList();
    final currentParts = current.split('.').map(int.tryParse).toList();

    for (var i = 0; i < 3; i++) {
      final l = latestParts.length > i ? (latestParts[i] ?? 0) : 0;
      final c = currentParts.length > i ? (currentParts[i] ?? 0) : 0;
      if (l > c) return true;
      if (l < c) return false;
    }
    return false;
  }
}

import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/update_service.dart';
import '../models/update_info.dart';

part 'version_provider.g.dart';

@riverpod
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}

@riverpod
class UpdateState extends _$UpdateState {
  @override
  AsyncValue<UpdateInfo?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> checkForUpdates() async {
    state = const AsyncValue.loading();

    try {
      final currentVersion = await ref.read(appVersionProvider.future);
      final updateService = ref.read<UpdateService>(updateServiceProvider);

      final update = await updateService.checkForUpdates(currentVersion);
      state = AsyncValue.data(update);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}

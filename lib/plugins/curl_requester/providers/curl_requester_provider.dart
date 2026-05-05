import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/curl_command.dart';
import '../models/curl_requester_state.dart';

part 'curl_requester_provider.g.dart';

@riverpod
class CurlRequester extends _$CurlRequester {
  @override
  CurlRequesterState build() {
    return const CurlRequesterState();
  }

  void updateCommand(CurlCommand command) {
    // TODO(Logic): Implement command update
  }

  void updateFromCurl(String curl) {
    // TODO(Logic): Implement cURL parser integration
  }

  Future<void> execute() async {
    // TODO(Logic): Implement network request execution and history persistence
    // TODO(Logic): Preserve history up to a maximum of 50 requests using FIFO order (evict oldest)
  }
}

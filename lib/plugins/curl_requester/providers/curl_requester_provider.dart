import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/curl_command.dart';
import '../models/curl_requester_state.dart';
import '../services/curl_parser_service.dart';

part 'curl_requester_provider.g.dart';

@riverpod
class CurlRequester extends _$CurlRequester {
  @override
  CurlRequesterState build() {
    return const CurlRequesterState();
  }

  void updateCommand(CurlCommand command) {
    state = state.copyWith(currentCommand: command);
  }

  void updateFromCurl(String curl) {
    final parsed = CurlParserService.parse(curl);
    state = state.copyWith(currentCommand: parsed);
  }

  void clearCommand() {
    state = state.copyWith(currentCommand: const CurlCommand());
  }

  void updateQueryParam(String oldKey, String newKey, String value) {
    final params = Map<String, String>.from(state.currentCommand.queryParameters);
    if (oldKey != newKey) params.remove(oldKey);
    params[newKey] = value;
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(queryParameters: params),
    );
  }

  void addQueryParam() {
    final params = Map<String, String>.from(state.currentCommand.queryParameters);
    params['new_param_${params.length}'] = '';
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(queryParameters: params),
    );
  }

  void removeQueryParam(String key) {
    final params = Map<String, String>.from(state.currentCommand.queryParameters);
    final inactive = Set<String>.from(state.currentCommand.inactiveQueryParameters);
    params.remove(key);
    inactive.remove(key);
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(
        queryParameters: params,
        inactiveQueryParameters: inactive,
      ),
    );
  }

  void toggleQueryParam(String key, bool isActive) {
    final inactive = Set<String>.from(state.currentCommand.inactiveQueryParameters);
    if (isActive) {
      inactive.remove(key);
    } else {
      inactive.add(key);
    }
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(inactiveQueryParameters: inactive),
    );
  }

  void updateHeader(String oldKey, String newKey, String value) {
    final headers = Map<String, String>.from(state.currentCommand.headers);
    final inactive = Set<String>.from(state.currentCommand.inactiveHeaders);
    if (oldKey != newKey) {
      headers.remove(oldKey);
      if (inactive.remove(oldKey)) inactive.add(newKey);
    }
    headers[newKey] = value;
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(
        headers: headers,
        inactiveHeaders: inactive,
      ),
    );
  }

  void addHeader() {
    final headers = Map<String, String>.from(state.currentCommand.headers);
    headers['New-Header'] = '';
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(headers: headers),
    );
  }

  void removeHeader(String key) {
    final headers = Map<String, String>.from(state.currentCommand.headers);
    final inactive = Set<String>.from(state.currentCommand.inactiveHeaders);
    headers.remove(key);
    inactive.remove(key);
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(
        headers: headers,
        inactiveHeaders: inactive,
      ),
    );
  }

  void toggleHeader(String key, bool isActive) {
    final inactive = Set<String>.from(state.currentCommand.inactiveHeaders);
    if (isActive) {
      inactive.remove(key);
    } else {
      inactive.add(key);
    }
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(inactiveHeaders: inactive),
    );
  }

  void updateBody(String body) {
    state = state.copyWith(
      currentCommand: state.currentCommand.copyWith(body: body),
    );
  }

  Future<void> execute() async {
    // TODO(Logic): Implement network request execution and history persistence
    // TODO(Logic): Preserve history up to a maximum of 50 requests using FIFO order (evict oldest)
  }
}

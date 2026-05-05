import 'package:freezed_annotation/freezed_annotation.dart';
import 'curl_command.dart';
import 'curl_transaction.dart';

part 'curl_requester_state.freezed.dart';

@freezed
class CurlRequesterState with _$CurlRequesterState {
  const factory CurlRequesterState({
    @Default(CurlCommand()) CurlCommand currentCommand,
    @Default([]) List<CurlTransaction> history,
    @Default(false) bool isLoading,
    String? lastError,
  }) = _CurlRequesterState;
}

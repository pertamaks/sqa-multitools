import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/curl_command.dart';
import '../models/curl_requester_state.dart';
import '../models/curl_transaction.dart';
import '../services/curl_parser_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/services/faker_resolution_service.dart';

part 'curl_requester_provider.g.dart';

@Riverpod(keepAlive: true)
class CurlRequester extends _$CurlRequester {
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    validateStatus: (_) => true, // Capture all status codes
  ));

  @override
  CurlRequesterState build() {
    try {
      // Load history on build
      final prefs = ref.read(preferencesServiceProvider);
      final historyJson = prefs.rawPrefs.getString(PreferencesService.keyCurlHistory);
      
      if (historyJson != null) {
        final decoded = jsonDecode(historyJson) as List;
        final history = decoded
            .map((e) => CurlTransaction.fromJson(e as Map<String, dynamic>))
            .toList();
            
        // "shown as last curl in the request" - If history exists, populate current command
        final lastCommand = history.isNotEmpty ? history.first.request : const CurlCommand();
        
        return CurlRequesterState(
          history: history,
          currentCommand: lastCommand,
        );
      }
    } catch (e) {
      // Fallback on error or incompatible data
      return const CurlRequesterState();
    }
    
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
    await executeCommand(state.currentCommand);
  }

  Future<void> executeCommand(CurlCommand command) async {
    if (state.isLoading) return;
    if (command.url.isEmpty) return;

    state = state.copyWith(isLoading: true);
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Resolve Placeholders (Faker Integration)
      final prefs = ref.read(preferencesServiceProvider);
      final resolvedCommand = FakerResolutionService.resolveCommand(command, prefs);

      // 2. Prepare URL & Params
      String finalUrl = resolvedCommand.url;
      if (!finalUrl.startsWith('http')) finalUrl = 'http://$finalUrl';
      
      final activeParams = Map<String, String>.from(resolvedCommand.queryParameters)
        ..removeWhere((k, _) => command.inactiveQueryParameters.contains(k));
      
      // 3. Prepare Headers
      final activeHeaders = Map<String, dynamic>.from(resolvedCommand.headers)
        ..removeWhere((k, _) => command.inactiveHeaders.contains(k));

      // 4. Send Request via Dio
      final response = await _dio.request(
        finalUrl,
        queryParameters: activeParams,
        data: resolvedCommand.body.isNotEmpty ? resolvedCommand.body : null,
        options: Options(
          method: command.method,
          headers: activeHeaders,
          responseType: ResponseType.plain, // Keep body as string for inspector
        ),
      );

      stopwatch.stop();

      // 5. Create Transaction
      final transaction = CurlTransaction(
        id: const Uuid().v4(),
        request: command, 
        resolvedRequest: resolvedCommand, 
        statusCode: response.statusCode ?? 0,
        responseBody: response.data?.toString() ?? '',
        latency: stopwatch.elapsed,
        responseSize: (response.data?.toString().length ?? 0),
        timestamp: DateTime.now(),
      );

      _updateHistory(transaction);
    } on DioException catch (e) {
      stopwatch.stop();
      final transaction = CurlTransaction(
        id: const Uuid().v4(),
        request: command,
        statusCode: e.response?.statusCode ?? 0,
        responseBody: 'Error [${e.type.name}]: ${e.message}\n\n${e.response?.data ?? ""}',
        latency: stopwatch.elapsed,
        responseSize: 0,
        timestamp: DateTime.now(),
      );
      _updateHistory(transaction);
    } catch (e) {
      stopwatch.stop();
      final transaction = CurlTransaction(
        id: const Uuid().v4(),
        request: command,
        statusCode: 0,
        responseBody: 'System Error: ${e.toString()}',
        latency: stopwatch.elapsed,
        responseSize: 0,
        timestamp: DateTime.now(),
      );
      _updateHistory(transaction);
    }
  }

  void _updateHistory(CurlTransaction transaction) {
    final newHistory = [transaction, ...state.history];
    if (newHistory.length > 50) newHistory.removeRange(50, newHistory.length);
    state = state.copyWith(isLoading: false, history: newHistory);
    _saveHistory();
  }

  void _saveHistory() {
    final prefs = ref.read(preferencesServiceProvider);
    final historyJson = jsonEncode(state.history.map((e) => e.toJson()).toList());
    prefs.rawPrefs.setString(PreferencesService.keyCurlHistory, historyJson);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
    _saveHistory();
  }
}

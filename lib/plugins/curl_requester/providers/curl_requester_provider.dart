import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/curl_command.dart';
import '../models/curl_requester_state.dart';
import '../models/curl_transaction.dart';
import '../services/curl_parser_service.dart';
import '../../../core/services/preferences_service.dart';

part 'curl_requester_provider.g.dart';

@Riverpod(keepAlive: true)
class CurlRequester extends _$CurlRequester {
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
    if (state.isLoading) return;
    final command = state.currentCommand;
    if (command.url.isEmpty) return;

    state = state.copyWith(isLoading: true);
    final stopwatch = Stopwatch()..start();

    try {
      // 1. Prepare URL & Params
      var uri = Uri.parse(command.url);
      if (!uri.hasScheme) uri = Uri.parse('http://${command.url}');
      
      final activeParams = Map<String, String>.from(command.queryParameters)
        ..removeWhere((k, _) => command.inactiveQueryParameters.contains(k));
      
      if (activeParams.isNotEmpty) {
        final newParams = {...uri.queryParameters, ...activeParams};
        uri = uri.replace(queryParameters: newParams);
      }

      // 2. Prepare Headers
      final activeHeaders = Map<String, String>.from(command.headers)
        ..removeWhere((k, _) => command.inactiveHeaders.contains(k));

      // 3. Prepare and Send Request
      final request = http.Request(command.method, uri);
      request.headers.addAll(activeHeaders);
      if (command.body.isNotEmpty) request.body = command.body;

      final client = http.Client();
      final streamedResponse = await client.send(request).timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);
      client.close();
      stopwatch.stop();

      // 4. Create Transaction
      final transaction = CurlTransaction(
        id: const Uuid().v4(),
        request: command,
        statusCode: response.statusCode,
        responseBody: response.body,
        latency: stopwatch.elapsed,
        responseSize: response.bodyBytes.length,
        timestamp: DateTime.now(),
      );

      _updateHistory(transaction);
    } catch (e) {
      stopwatch.stop();
      final transaction = CurlTransaction(
        id: const Uuid().v4(),
        request: command,
        statusCode: 0,
        responseBody: 'Error: ${e.toString()}',
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

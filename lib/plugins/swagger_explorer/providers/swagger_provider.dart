import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/logging_service.dart';
import '../models/swagger_state.dart';
import '../services/swagger_parser_service.dart';

part 'swagger_provider.g.dart';

@Riverpod(keepAlive: true)
class SwaggerNotifier extends _$SwaggerNotifier {
  /// Shared Dio instance with sensible timeouts.
  /// Not made top-level to avoid issues with Riverpod code generation.
  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  @override
  SwaggerState build() => const SwaggerState();

  void setViewMode(SwaggerViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  void setActiveEndpoint(SwaggerEndpoint endpoint) {
    state = state.copyWith(activeEndpoint: endpoint);
  }

  Future<void> fetchFromUrl(String url) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _dio.get<dynamic>(url);

      Map<String, dynamic> jsonMap;
      if (response.data is String) {
        jsonMap = jsonDecode(response.data as String) as Map<String, dynamic>;
      } else {
        jsonMap = response.data as Map<String, dynamic>;
      }

      final schemaInfo = await compute(parseSwaggerJsonIsolate, {
        'json': jsonMap,
        'sourceUrl': url,
      });

      _addToHistory(schemaInfo, url: url);
      state = state.copyWith(
        isLoading: false,
        activeSchema: schemaInfo,
        viewMode: SwaggerViewMode.detail,
      );
    } catch (e, stack) {
      ref
          .read(loggingServiceProvider.notifier)
          .logError(
            'Failed to fetch Swagger JSON from URL: $e',
            'SwaggerExplorer',
            e,
            stack,
          );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch Swagger JSON: $e',
      );
    }
  }

  Future<void> fetchFromFile(String filePath) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      final Map<String, dynamic> jsonMap =
          jsonDecode(content) as Map<String, dynamic>;
      final schemaInfo = await compute(parseSwaggerJsonIsolate, {
        'json': jsonMap,
      });

      _addToHistory(schemaInfo, filePath: filePath);
      state = state.copyWith(
        isLoading: false,
        activeSchema: schemaInfo,
        viewMode: SwaggerViewMode.detail,
      );
    } catch (e, stack) {
      ref
          .read(loggingServiceProvider.notifier)
          .logError(
            'Failed to parse Swagger JSON from file: $e',
            'SwaggerExplorer',
            e,
            stack,
          );
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to parse Swagger JSON from file: $e',
      );
    }
  }

  void deleteFromHistory(String id) {
    final newHistory = state.history.where((item) => item.id != id).toList();
    state = state.copyWith(history: newHistory);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }

  void loadDummySchema() {
    state = state.copyWith(
      activeSchema: const SwaggerSchemaInfo(
        title: 'Demo API',
        version: '1.0.0',
        description: 'This is a demo API generated for the coachmark tour.',
        endpoints: [
          SwaggerEndpoint(
            path: '/users',
            method: 'GET',
            summary: 'Get all users',
            tags: ['Users'],
            parameters: [],
            responses: {},
          ),
          SwaggerEndpoint(
            path: '/users/{id}',
            method: 'POST',
            summary: 'Create a user',
            tags: ['Users'],
            parameters: [],
            responses: {},
          ),
        ],
        securitySchemes: {},
        baseUrl: 'http://localhost:8080',
      ),
      viewMode: SwaggerViewMode.detail,
    );
  }

  void setSecurityValue(String key, String value) {
    final newValues = Map<String, String>.from(state.activeSecurityValues);
    newValues[key] = value;
    state = state.copyWith(activeSecurityValues: newValues);
  }

  void removeSecurityValue(String key) {
    final newValues = Map<String, String>.from(state.activeSecurityValues);
    newValues.remove(key);
    state = state.copyWith(activeSecurityValues: newValues);
  }

  // ── Private helpers ──────────────────────────────────────────────────

  void _addToHistory(
    SwaggerSchemaInfo schemaInfo, {
    String? url,
    String? filePath,
  }) {
    final historyItem = SwaggerHistoryItem(
      id: const Uuid().v4(),
      name: schemaInfo.title,
      url: url,
      filePath: filePath,
      lastAccessed: DateTime.now(),
    );
    state = state.copyWith(
      history: [
        historyItem,
        ...state.history.where(
          (item) => item.url != url && item.filePath != filePath,
        ),
      ],
    );
  }
}

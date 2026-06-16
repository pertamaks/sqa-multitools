import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/core/services/logging_service.dart';
import 'package:sqa_multitools/plugins/swagger_explorer/providers/swagger_provider.dart';
import 'package:sqa_multitools/plugins/swagger_explorer/models/swagger_state.dart';

class MockLoggingService extends LoggingService {
  @override
  void build() {}
  @override
  void logInfo(String message, [String? name]) {}
  @override
  void logError(
    String message, [
    String? name,
    Object? error,
    StackTrace? stackTrace,
  ]) {}
  @override
  void logWarning(
    String message, [
    String? name,
    Object? error,
    StackTrace? stackTrace,
  ]) {}
  @override
  void logDebug(String message, [String? name]) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SwaggerNotifier — state mutations', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          loggingServiceProvider.overrideWith(() => MockLoggingService()),
        ],
      );
      addTearDown(container.dispose);
    });

    test('initial state has default values', () {
      final state = container.read(swaggerProvider);
      expect(state.viewMode, SwaggerViewMode.list);
      expect(state.history, isEmpty);
      expect(state.activeSchema, isNull);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.activeEndpoint, isNull);
      expect(state.activeSecurityValues, isEmpty);
    });

    test('setViewMode updates view mode', () {
      final notifier = container.read(swaggerProvider.notifier);

      notifier.setViewMode(SwaggerViewMode.detail);
      expect(container.read(swaggerProvider).viewMode, SwaggerViewMode.detail);

      notifier.setViewMode(SwaggerViewMode.list);
      expect(container.read(swaggerProvider).viewMode, SwaggerViewMode.list);
    });

    test('setActiveEndpoint stores the endpoint reference', () {
      final notifier = container.read(swaggerProvider.notifier);
      final endpoint = SwaggerEndpoint(
        path: '/users',
        method: 'GET',
        summary: 'List users',
        tags: ['Users'],
      );

      notifier.setActiveEndpoint(endpoint);
      final active = container.read(swaggerProvider).activeEndpoint;
      expect(active, isNotNull);
      expect(active!.path, '/users');
      expect(active.method, 'GET');
      expect(active.summary, 'List users');
    });

    test('clearHistory empties the history list', () {
      final notifier = container.read(swaggerProvider.notifier);

      // Seed some history items by calling fetchFromFile (separate test group)
      // then verify clear works on an empty state:
      notifier.clearHistory();
      expect(container.read(swaggerProvider).history, isEmpty);

      // Verify idempotency
      notifier.clearHistory();
      expect(container.read(swaggerProvider).history, isEmpty);
    });

    test('setSecurityValue stores and updates values', () {
      final notifier = container.read(swaggerProvider.notifier);

      notifier.setSecurityValue('BearerAuth', 'my-token');
      var values = container.read(swaggerProvider).activeSecurityValues;
      expect(values, containsPair('BearerAuth', 'my-token'));

      // Update existing
      notifier.setSecurityValue('BearerAuth', 'new-token');
      values = container.read(swaggerProvider).activeSecurityValues;
      expect(values, containsPair('BearerAuth', 'new-token'));
    });

    test('removeSecurityValue removes the key', () {
      final notifier = container.read(swaggerProvider.notifier);

      notifier.setSecurityValue('ApiKey', 'abc123');
      expect(
        container.read(swaggerProvider).activeSecurityValues,
        containsPair('ApiKey', 'abc123'),
      );

      notifier.removeSecurityValue('ApiKey');
      expect(
        container.read(swaggerProvider).activeSecurityValues,
        isNot(contains('ApiKey')),
      );
    });

    test('multiple security values coexist independently', () {
      final notifier = container.read(swaggerProvider.notifier);

      notifier.setSecurityValue('BearerAuth', 'bearer-token');
      notifier.setSecurityValue('ApiKey', 'api-key');
      notifier.setSecurityValue('X-Custom', 'custom-val');

      final values = container.read(swaggerProvider).activeSecurityValues;
      expect(values, hasLength(3));
      expect(values, containsPair('BearerAuth', 'bearer-token'));
      expect(values, containsPair('ApiKey', 'api-key'));
      expect(values, containsPair('X-Custom', 'custom-val'));

      // Remove one
      notifier.removeSecurityValue('ApiKey');
      expect(
        container.read(swaggerProvider).activeSecurityValues,
        hasLength(2),
      );
    });
  });

  group('SwaggerNotifier — fetchFromFile integration', () {
    late ProviderContainer container;
    late Directory tmpDir;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          loggingServiceProvider.overrideWith(() => MockLoggingService()),
        ],
      );
      addTearDown(container.dispose);
      tmpDir = Directory.systemTemp.createTempSync('swagger_test_');
      addTearDown(() => tmpDir.deleteSync(recursive: true));
    });

    test('loads a valid OpenAPI JSON file and updates state', () async {
      final file = File('${tmpDir.path}/api.json');
      file.writeAsStringSync(
        jsonEncode({
          'openapi': '3.0.0',
          'info': {'title': 'Test File API', 'version': '1.0.0'},
          'servers': [
            {'url': 'http://localhost'},
          ],
          'paths': {
            '/ping': {
              'get': {
                'tags': ['System'],
                'summary': 'Ping',
                'responses': {
                  '200': {'description': 'OK'},
                },
              },
            },
          },
        }),
      );

      final notifier = container.read(swaggerProvider.notifier);
      await notifier.fetchFromFile(file.path);

      final state = container.read(swaggerProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, isNull);
      expect(state.activeSchema, isNotNull);
      expect(state.activeSchema!.title, 'Test File API');
      expect(state.activeSchema!.endpoints, hasLength(1));
      expect(state.viewMode, SwaggerViewMode.detail);
      // Should be added to history
      expect(state.history, hasLength(1));
      expect(state.history.first.name, 'Test File API');
    });

    test('sets errorMessage for invalid JSON file', () async {
      final file = File('${tmpDir.path}/invalid.json');
      file.writeAsStringSync('not valid json');

      final notifier = container.read(swaggerProvider.notifier);
      await notifier.fetchFromFile(file.path);

      final state = container.read(swaggerProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('Failed to parse'));
      expect(state.activeSchema, isNull);
    });

    test('sets errorMessage for non-existent file', () async {
      final notifier = container.read(swaggerProvider.notifier);
      await notifier.fetchFromFile('/nonexistent/path.json');

      final state = container.read(swaggerProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('Failed to parse'));
    });

    test('deduplicates history by file path', () async {
      final file = File('${tmpDir.path}/dedup.json');
      file.writeAsStringSync(
        jsonEncode({
          'openapi': '3.0.0',
          'info': {'title': 'Dedup Test', 'version': '1.0'},
          'servers': [
            {'url': 'http://localhost'},
          ],
          'paths': <String, dynamic>{},
        }),
      );

      final notifier = container.read(swaggerProvider.notifier);

      // Load twice
      await notifier.fetchFromFile(file.path);
      expect(container.read(swaggerProvider).history, hasLength(1));

      await notifier.fetchFromFile(file.path);
      // Should still be 1, not 2 (deduped)
      expect(container.read(swaggerProvider).history, hasLength(1));
    });
  });
}

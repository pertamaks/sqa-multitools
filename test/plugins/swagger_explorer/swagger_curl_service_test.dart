import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/plugins/swagger_explorer/models/swagger_state.dart';
import 'package:sqa_multitools/plugins/swagger_explorer/providers/swagger_curl_service.dart';

void main() {
  late SwaggerCurlService service;

  setUp(() {
    service = SwaggerCurlService();
  });

  /// Helper: build a minimal schema with the given [name].
  SwaggerSchemaInfo createSchema({
    String baseUrl = 'http://localhost:8080',
    Map<String, SwaggerSecurityScheme> securitySchemes = const {},
    List<Map<String, List<String>>> security = const [],
  }) => SwaggerSchemaInfo(
    title: 'Test API',
    version: '1.0',
    baseUrl: baseUrl,
    securitySchemes: securitySchemes,
    security: security,
  );

  /// Helper: build an endpoint.
  SwaggerEndpoint createEndpoint({
    String path = '/test',
    String method = 'GET',
    String summary = 'Test endpoint',
    List<Map<String, dynamic>>? parameters,
    Map<String, dynamic>? requestBody,
    Map<String, dynamic>? responses,
    List<Map<String, List<String>>>? security,
  }) => SwaggerEndpoint(
    path: path,
    method: method,
    summary: summary,
    tags: const ['default'],
    parameters: parameters,
    requestBody: requestBody,
    responses: responses,
    security: security,
  );

  group('SwaggerCurlService.generateCommand()', () {
    test('generates a simple GET command', () {
      final schema = createSchema();
      final ep = createEndpoint();
      final cmd = service.generateCommand(ep, schema, {});

      expect(cmd.url, 'http://localhost:8080/test');
      expect(cmd.method, 'GET');
      expect(cmd.headers, containsPair('Accept', 'application/json'));
      expect(cmd.body, isEmpty);
    });

    test('injects path parameters into CurlCommand.pathParameters', () {
      final schema = createSchema();
      final ep = createEndpoint(
        path: '/users/{userId}/posts/{postId}',
        method: 'GET',
        parameters: [
          {'name': 'userId', 'in': 'path', 'required': true, 'type': 'integer'},
          {'name': 'postId', 'in': 'path', 'required': true, 'type': 'integer'},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {});

      expect(cmd.pathParameters, hasLength(2));
      expect(cmd.pathParameters, containsPair('userId', '0'));
      expect(cmd.pathParameters, containsPair('postId', '0'));
      // URL should still be the template — path substitution happens at execution
      expect(cmd.url, 'http://localhost:8080/users/{userId}/posts/{postId}');
    });

    test('appends query parameters to the URL', () {
      final schema = createSchema();
      final ep = createEndpoint(
        path: '/search',
        method: 'GET',
        parameters: [
          {'name': 'q', 'in': 'query', 'type': 'string'},
          {'name': 'limit', 'in': 'query', 'type': 'integer'},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {});

      expect(cmd.queryParameters, hasLength(2));
      expect(cmd.queryParameters, containsPair('q', 'string'));
      expect(cmd.queryParameters, containsPair('limit', '0'));
      expect(cmd.url, 'http://localhost:8080/search?q=string&limit=0');
    });

    test('injects header parameters', () {
      final schema = createSchema();
      final ep = createEndpoint(
        path: '/data',
        method: 'GET',
        parameters: [
          {'name': 'X-Request-ID', 'in': 'header', 'type': 'string'},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {});

      expect(cmd.headers, containsPair('X-Request-ID', 'string'));
      expect(cmd.headers, containsPair('Accept', 'application/json'));
    });

    test('generates POST with JSON request body', () {
      final schema = createSchema();
      final ep = createEndpoint(
        path: '/items',
        method: 'POST',
        summary: 'Create item',
        requestBody: {
          'content': {
            'application/json': {
              'schema': {
                'type': 'object',
                'properties': {
                  'name': {'type': 'string'},
                  'price': {'type': 'number'},
                  'available': {'type': 'boolean'},
                },
              },
            },
          },
        },
      );
      final cmd = service.generateCommand(ep, schema, {});

      expect(cmd.headers, containsPair('Content-Type', 'application/json'));
      expect(cmd.body, contains('"name"'));
      expect(cmd.body, contains('"price"'));
      expect(cmd.body, contains('"available"'));
      expect(cmd.body, contains('0'));
      expect(cmd.body, contains('true'));
    });

    test('generates POST with form-urlencoded body', () {
      final schema = createSchema();
      final ep = createEndpoint(
        path: '/login',
        method: 'POST',
        requestBody: {
          'content': {
            'application/x-www-form-urlencoded': {
              'schema': {
                'type': 'object',
                'properties': {
                  'username': {'type': 'string'},
                  'password': {'type': 'string'},
                },
              },
            },
          },
        },
      );
      final cmd = service.generateCommand(ep, schema, {});

      expect(
        cmd.headers,
        containsPair('Content-Type', 'application/x-www-form-urlencoded'),
      );
      expect(cmd.body, contains('username=string'));
      expect(cmd.body, contains('password=string'));
    });

    test('injects Bearer token from http/bearer security scheme', () {
      final schema = createSchema(
        securitySchemes: {
          'BearerAuth': SwaggerSecurityScheme(type: 'http', scheme: 'bearer'),
        },
      );
      final ep = createEndpoint(
        method: 'GET',
        security: [
          {'BearerAuth': []},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {
        'BearerAuth': 'my-jwt-token',
      });

      expect(cmd.headers, containsPair('Authorization', 'Bearer my-jwt-token'));
    });

    test('injects API key in header from apiKey scheme', () {
      final schema = createSchema(
        securitySchemes: {
          'ApiKeyAuth': SwaggerSecurityScheme(
            type: 'apiKey',
            inLocation: 'header',
            name: 'X-API-Key',
          ),
        },
      );
      final ep = createEndpoint(
        method: 'GET',
        security: [
          {'ApiKeyAuth': []},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {'ApiKeyAuth': 'abc123'});

      expect(cmd.headers, containsPair('X-API-Key', 'abc123'));
    });

    test('injects API key in query from apiKey scheme', () {
      final schema = createSchema(
        securitySchemes: {
          'ApiKeyAuth': SwaggerSecurityScheme(
            type: 'apiKey',
            inLocation: 'query',
            name: 'api_key',
          ),
        },
      );
      final ep = createEndpoint(
        method: 'GET',
        security: [
          {'ApiKeyAuth': []},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {'ApiKeyAuth': 'secret'});

      expect(cmd.queryParameters, containsPair('api_key', 'secret'));
    });

    test('injects Basic auth token', () {
      final schema = createSchema(
        securitySchemes: {
          'BasicAuth': SwaggerSecurityScheme(type: 'http', scheme: 'basic'),
        },
      );
      final ep = createEndpoint(
        method: 'GET',
        security: [
          {'BasicAuth': []},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {
        'BasicAuth': 'base64encodedcreds',
      });

      expect(
        cmd.headers,
        containsPair('Authorization', 'Basic base64encodedcreds'),
      );
    });

    test('skips security when no values provided', () {
      final schema = createSchema(
        securitySchemes: {
          'BearerAuth': SwaggerSecurityScheme(type: 'http', scheme: 'bearer'),
        },
      );
      final ep = createEndpoint(
        method: 'GET',
        security: [
          {'BearerAuth': []},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {});

      // Should NOT have added Authorization header
      expect(cmd.headers, isNot(contains('Authorization')));
    });

    test('uses endpoint-level security before global schema security', () {
      final schema = createSchema(
        securitySchemes: {
          'EndpointAuth': SwaggerSecurityScheme(type: 'http', scheme: 'bearer'),
          'GlobalAuth': SwaggerSecurityScheme(
            type: 'apiKey',
            inLocation: 'header',
            name: 'X-Global',
          ),
        },
        security: [
          {'GlobalAuth': []},
        ],
      );
      final ep = createEndpoint(
        method: 'GET',
        security: [
          {'EndpointAuth': []},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {
        'EndpointAuth': 'ep-token',
        'GlobalAuth': 'global-key',
      });

      // Should use endpoint-level BearerAuth, not global
      expect(cmd.headers, containsPair('Authorization', 'Bearer ep-token'));
      expect(cmd.headers, isNot(contains('X-Global')));
    });

    test('falls back to global security when endpoint has none', () {
      final schema = createSchema(
        securitySchemes: {
          'GlobalAuth': SwaggerSecurityScheme(type: 'http', scheme: 'bearer'),
        },
        security: [
          {'GlobalAuth': []},
        ],
      );
      final ep = createEndpoint(method: 'GET'); // no endpoint security
      final cmd = service.generateCommand(ep, schema, {
        'GlobalAuth': 'global-token',
      });

      expect(cmd.headers, containsPair('Authorization', 'Bearer global-token'));
    });

    test('handles formData parameters (multipart)', () {
      final schema = createSchema();
      final ep = createEndpoint(
        path: '/upload',
        method: 'POST',
        parameters: [
          {'name': 'file', 'in': 'formData', 'type': 'file'},
          {'name': 'description', 'in': 'formData', 'type': 'string'},
        ],
      );
      final cmd = service.generateCommand(ep, schema, {});

      expect(cmd.headers['Content-Type'], 'multipart/form-data');
      // For multipart, form fields are kept in the body as URL-encoded pairs
      expect(cmd.body, contains('file=@dummy_file.txt'));
      expect(cmd.body, contains('description=string'));
    });
  });

  group('SwaggerCurlService.generateExampleFromSchema()', () {
    test('returns example when present', () {
      final result = service.generateExampleFromSchema({
        'type': 'string',
        'example': 'hello',
      });
      expect(result, 'hello');
    });

    test('generates example from object properties', () {
      final result = service.generateExampleFromSchema({
        'type': 'object',
        'properties': {
          'name': {'type': 'string'},
          'count': {'type': 'integer'},
          'active': {'type': 'boolean'},
        },
      });
      expect(result, isA<Map<String, dynamic>>());
      expect((result as Map<String, dynamic>)['name'], 'string');
      expect(result['count'], 0);
      expect(result['active'], true);
    });

    test('generates nested object example', () {
      final result = service.generateExampleFromSchema({
        'type': 'object',
        'properties': {
          'metadata': {
            'type': 'object',
            'properties': {
              'key': {'type': 'string'},
            },
          },
        },
      });
      expect(result, isA<Map<String, dynamic>>());
      expect((result as Map<String, dynamic>)['metadata']['key'], 'string');
    });

    test('generates array example from items schema', () {
      final result = service.generateExampleFromSchema({
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'id': {'type': 'integer'},
          },
        },
      });
      expect(result, isA<List<dynamic>>());
      expect((result as List<dynamic>), hasLength(1));
      expect(result[0]['id'], 0);
    });

    test('returns schema as-is for unknown types', () {
      final result = service.generateExampleFromSchema({
        'type': 'unknown_format',
      });
      expect(result, isA<Map<String, dynamic>>());
      expect((result as Map<String, dynamic>)['type'], 'unknown_format');
    });
  });
}

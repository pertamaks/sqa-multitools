import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/plugins/swagger_explorer/services/swagger_parser_service.dart';

void main() {
  group('SwaggerParserService.parse() — OpenAPI 3.0', () {
    test('parses a basic OpenAPI 3.0 spec with title, version, endpoints', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {
          'title': 'Petstore API',
          'version': '1.0.0',
          'description': 'A sample pet store API',
        },
        'servers': [
          {'url': 'https://api.petstore.com/v1'},
        ],
        'paths': {
          '/pets': {
            'get': {
              'tags': ['Pets'],
              'summary': 'List all pets',
              'responses': {
                '200': {'description': 'A list of pets'},
              },
            },
            'post': {
              'tags': ['Pets'],
              'summary': 'Create a pet',
              'requestBody': {
                'required': true,
                'content': {
                  'application/json': {
                    'schema': {
                      'type': 'object',
                      'properties': {
                        'name': {'type': 'string'},
                      },
                    },
                  },
                },
              },
              'responses': {
                '201': {'description': 'Created'},
              },
            },
          },
          '/pets/{id}': {
            'get': {
              'tags': ['Pets'],
              'summary': 'Get pet by ID',
              'parameters': [
                {
                  'name': 'id',
                  'in': 'path',
                  'required': true,
                  'schema': {'type': 'integer'},
                },
              ],
              'responses': {
                '200': {'description': 'Pet details'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.parse(json);

      expect(result.title, 'Petstore API');
      expect(result.version, '1.0.0');
      expect(result.description, 'A sample pet store API');
      expect(result.baseUrl, 'https://api.petstore.com/v1');
      expect(result.endpoints.length, 3);

      // Verify endpoints by method+path
      final petsGet = result.endpoints
          .where((e) => e.path == '/pets' && e.method == 'GET')
          .first;
      expect(petsGet.summary, 'List all pets');
      expect(petsGet.tags, contains('Pets'));

      final petsPost = result.endpoints
          .where((e) => e.path == '/pets' && e.method == 'POST')
          .first;
      expect(petsPost.summary, 'Create a pet');
      expect(petsPost.requestBody, isNotNull);

      final petById = result.endpoints
          .where((e) => e.path == '/pets/{id}' && e.method == 'GET')
          .first;
      expect(petById.parameters, hasLength(1));
      expect(petById.parameters!.first['name'], 'id');
      expect(petById.parameters!.first['in'], 'path');
    });

    test('resolves relative server URL when sourceUrl is provided', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'Relative', 'version': '1.0'},
        'servers': [
          {'url': '/api/v2'},
        ],
        'paths': {
          '/health': {
            'get': {
              'tags': ['System'],
              'summary': 'Health check',
              'responses': {
                '200': {'description': 'OK'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.parse(
        json,
        sourceUrl: 'http://localhost:8080/swagger.json',
      );

      expect(result.baseUrl, 'http://localhost:8080/api/v2');
    });

    test('parses OAS 3.0 security schemes (apiKey + http/bearer)', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'Secured API', 'version': '1.0'},
        'servers': [
          {'url': 'https://api.example.com'},
        ],
        'paths': {
          '/me': {
            'get': {
              'tags': ['User'],
              'summary': 'Get profile',
              'security': [
                {'ApiKeyAuth': <String>[]},
              ],
              'responses': {
                '200': {'description': 'Profile'},
              },
            },
          },
        },
        'components': {
          'securitySchemes': {
            'ApiKeyAuth': {
              'type': 'apiKey',
              'in': 'header',
              'name': 'X-API-Key',
              'description': 'Your API key',
            },
            'BearerAuth': {
              'type': 'http',
              'scheme': 'bearer',
              'bearerFormat': 'JWT',
            },
          },
        },
      };

      final result = SwaggerParserService.parse(json);

      expect(result.securitySchemes, hasLength(2));
      final apiKey = result.securitySchemes['ApiKeyAuth']!;
      expect(apiKey.type, 'apiKey');
      expect(apiKey.inLocation, 'header');
      expect(apiKey.name, 'X-API-Key');

      final bearer = result.securitySchemes['BearerAuth']!;
      expect(bearer.type, 'http');
      expect(bearer.scheme, 'bearer');
      expect(bearer.bearerFormat, 'JWT');
    });

    test('parses global security requirements', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'Global Security', 'version': '1.0'},
        'servers': [
          {'url': 'https://api.example.com'},
        ],
        'security': [
          {
            'BearerAuth': ['read', 'write'],
          },
          {'ApiKeyAuth': <String>[]},
        ],
        'paths': {
          '/items': {
            'get': {
              'tags': ['Items'],
              'summary': 'List items',
              'responses': {
                '200': {'description': 'Items'},
              },
            },
          },
        },
        'components': {
          'securitySchemes': {
            'BearerAuth': {'type': 'http', 'scheme': 'bearer'},
            'ApiKeyAuth': {'type': 'apiKey', 'in': 'header', 'name': 'X-Key'},
          },
        },
      };

      final result = SwaggerParserService.parse(json);

      expect(result.security, hasLength(2));
      expect(result.security[0], contains('BearerAuth'));
      expect(result.security[0]['BearerAuth'], containsAll(['read', 'write']));
      expect(result.security[1], contains('ApiKeyAuth'));
    });
  });

  group('SwaggerParserService.parse() — Swagger 2.0', () {
    test('parses Swagger 2.0 spec with host/basePath', () {
      final json = <String, dynamic>{
        'swagger': '2.0',
        'info': {'title': 'Legacy API', 'version': '2.0.0'},
        'host': 'api.legacy.com',
        'basePath': '/v2',
        'schemes': ['https'],
        'paths': {
          '/users': {
            'get': {
              'tags': ['Users'],
              'summary': 'List users',
              'responses': {
                '200': {'description': 'Users'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.parse(json);

      expect(result.title, 'Legacy API');
      expect(result.version, '2.0.0');
      expect(result.baseUrl, 'https://api.legacy.com/v2');
      expect(result.endpoints, hasLength(1));
    });

    test('converts Swagger 2.0 body parameter to requestBody', () {
      final json = <String, dynamic>{
        'swagger': '2.0',
        'info': {'title': 'Body Param', 'version': '1.0'},
        'host': 'api.example.com',
        'paths': {
          '/items': {
            'post': {
              'tags': ['Items'],
              'summary': 'Create item',
              'parameters': [
                {
                  'name': 'body',
                  'in': 'body',
                  'required': true,
                  'schema': {
                    'type': 'object',
                    'properties': {
                      'name': {'type': 'string'},
                    },
                  },
                },
              ],
              'responses': {
                '201': {'description': 'Created'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.parse(json);

      final ep = result.endpoints.first;
      expect(ep.requestBody, isNotNull);
      expect(
        ep.requestBody!['content']['application/json']['schema']['type'],
        'object',
      );
    });

    test('parses Swagger 2.0 securityDefinitions', () {
      final json = <String, dynamic>{
        'swagger': '2.0',
        'info': {'title': 'Legacy Auth', 'version': '1.0'},
        'host': 'api.example.com',
        'securityDefinitions': {
          'api_key': {'type': 'apiKey', 'in': 'query', 'name': 'api_key'},
        },
        'paths': {
          '/data': {
            'get': {
              'tags': ['Data'],
              'summary': 'Get data',
              'responses': {
                '200': {'description': 'OK'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.parse(json);

      expect(result.securitySchemes, hasLength(1));
      expect(result.securitySchemes['api_key']!.type, 'apiKey');
      expect(result.securitySchemes['api_key']!.inLocation, 'query');
    });
  });

  group('SwaggerParserService.parse() — Edge cases', () {
    test('handles empty paths section', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'Empty', 'version': '1.0'},
        'servers': [
          {'url': 'http://localhost'},
        ],
        'paths': <String, dynamic>{},
      };

      final result = SwaggerParserService.parse(json);
      expect(result.endpoints, isEmpty);
    });

    test('handles missing info section', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'paths': <String, dynamic>{},
      };

      final result = SwaggerParserService.parse(json);
      expect(result.title, 'Unknown API');
      expect(result.version, '1.0');
    });

    test('handles missing servers/host gracefully', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'No Server', 'version': '1.0'},
        'paths': <String, dynamic>{},
      };

      final result = SwaggerParserService.parse(json);
      expect(result.baseUrl, isNull);
    });

    test('ignores non-map path entries', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'Filtered', 'version': '1.0'},
        'servers': [
          {'url': 'http://localhost'},
        ],
        'paths': {
          '/valid': {
            'get': {
              'tags': ['Test'],
              'summary': 'Valid endpoint',
              'responses': {
                '200': {'description': 'OK'},
              },
            },
          },
          '/invalid': 'not a map',
        },
      };

      final result = SwaggerParserService.parse(json);
      expect(result.endpoints, hasLength(1));
      expect(result.endpoints.first.path, '/valid');
    });

    test('uses operationId as summary fallback', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'OpId', 'version': '1.0'},
        'servers': [
          {'url': 'http://localhost'},
        ],
        'paths': {
          '/items': {
            'get': {
              'tags': ['Items'],
              'operationId': 'listItems',
              'responses': {
                '200': {'description': 'OK'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.parse(json);
      expect(result.endpoints.first.summary, 'listItems');
    });

    test('tags default to [default] when missing', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'No Tags', 'version': '1.0'},
        'servers': [
          {'url': 'http://localhost'},
        ],
        'paths': {
          '/ping': {
            'get': {
              'summary': 'Ping',
              'responses': {
                '200': {'description': 'OK'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.parse(json);
      expect(result.endpoints.first.tags, contains('default'));
    });

    test('handles method case normalization to uppercase', () {
      final json = <String, dynamic>{
        'openapi': '3.0.0',
        'info': {'title': 'Case Test', 'version': '1.0'},
        'servers': [
          {'url': 'http://localhost'},
        ],
        'paths': {
          '/item': {
            'patch': {
              'tags': ['Items'],
              'summary': 'Patch item',
              'responses': {
                '200': {'description': 'OK'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.parse(json);
      expect(result.endpoints.first.method, 'PATCH');
    });
  });

  group('SwaggerParserService.resolveRefs()', () {
    test('resolves a simple \$ref pointer', () {
      final root = <String, dynamic>{
        'components': {
          'schemas': {
            'Error': {
              'type': 'object',
              'properties': {
                'message': {'type': 'string'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.resolveRefs({
        '\$ref': '#/components/schemas/Error',
      }, root);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['type'], 'object');
      expect(result['properties']['message']['type'], 'string');
    });

    test('prevents infinite recursion on circular \$ref', () {
      final root = <String, dynamic>{
        'components': {
          'schemas': {
            'Node': {
              'type': 'object',
              'properties': {
                'next': {'\$ref': '#/components/schemas/Node'},
              },
            },
          },
        },
      };

      final result = SwaggerParserService.resolveRefs({
        '\$ref': '#/components/schemas/Node',
      }, root);

      // Should resolve without stack overflow and return the ref stub
      expect(result, isA<Map<String, dynamic>>());
      expect(result['type'], 'object');
      expect(
        result['properties']['next']['\$ref'],
        '#/components/schemas/Node',
      );
    });

    test('preserves non-ref nodes as-is', () {
      final root = <String, dynamic>{};
      final result = SwaggerParserService.resolveRefs({'type': 'string'}, root);

      expect(result['type'], 'string');
    });

    test('resolves refs inside arrays', () {
      final root = <String, dynamic>{
        'definitions': {
          'Tag': {
            'type': 'object',
            'properties': {
              'name': {'type': 'string'},
            },
          },
        },
      };

      final result = SwaggerParserService.resolveRefs([
        {'type': 'string'},
        {'\$ref': '#/definitions/Tag'},
      ], root);

      expect(result, hasLength(2));
      expect(result[0]['type'], 'string');
      expect(result[1]['type'], 'object');
      expect(result[1]['properties']['name']['type'], 'string');
    });
  });
}

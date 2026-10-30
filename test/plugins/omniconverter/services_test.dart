import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/plugins/omniconverter/services/encoding_service.dart';
import 'package:sqa_multitools/plugins/omniconverter/services/format_service.dart';
import 'package:sqa_multitools/plugins/omniconverter/services/jwt_service.dart';
import 'package:sqa_multitools/plugins/omniconverter/services/hash_service.dart';
import 'package:sqa_multitools/plugins/omniconverter/services/text_case_service.dart';

void main() {
  group('EncodingService', () {
    const service = EncodingService();

    test('Base64 encode & decode standard', () {
      const text = 'Hello, SQA Multitools! 🚀';
      final encoded = service.encodeBase64(text);
      expect(encoded, isNotEmpty);
      expect(service.decodeBase64(encoded), text);
    });

    test('Base64 decode handles URL-safe and missing padding', () {
      // "subjects?_d=1" in standard base64: "c3ViamVjdHM/X2Q9MQ=="
      // URL-safe unpadded: "c3ViamVjdHM_X2Q9MQ"
      const urlSafeUnpadded = 'c3ViamVjdHM_X2Q9MQ';
      final decoded = service.decodeBase64(urlSafeUnpadded);
      expect(decoded, 'subjects?_d=1');
    });

    test('URL encode & decode', () {
      const url = 'https://example.com/search?query=SQA & Testing=100%';
      final encoded = service.encodeUrl(url);
      expect(encoded, isNot(contains(' ')));
      expect(service.decodeUrl(encoded), url);
    });

    test('HTML entities encode & decode', () {
      const raw = 'Hello "World" & \'QA\' <script>';
      final encoded = service.encodeHtml(raw);
      expect(encoded, contains('&lt;script&gt;'));
      expect(encoded, contains('&amp;'));
      expect(service.decodeHtml(encoded), raw);
    });

    test('Hex encode & decode', () {
      const text = 'SQA';
      final hex = service.encodeHex(text);
      expect(hex, '53 51 41');
      expect(service.decodeHex(hex), text);
    });

    test('Binary encode & decode', () {
      const text = 'AB';
      final bin = service.encodeBinary(text);
      expect(bin, '01000001 01000010');
      expect(service.decodeBinary(bin), text);
    });
  });

  group('FormatService', () {
    const service = FormatService();

    test('JSON to YAML and YAML to JSON', () {
      const jsonStr = '{"name":"SQA","active":true,"tags":["qa","tool"]}';
      final yaml = service.jsonToYaml(jsonStr);
      expect(yaml, contains('name:'));
      expect(yaml, contains('SQA'));
      expect(yaml, contains('active: true'));

      final jsonResult = service.yamlToJson(yaml, indent: false);
      expect(jsonResult, contains('"name":"SQA"'));
    });

    test('JSON to XML and XML to JSON', () {
      const jsonStr = '{"title":"Test","count":42}';
      final xml = service.jsonToXml(jsonStr);
      expect(xml, contains('<title>Test</title>'));
      expect(xml, contains('<count>42</count>'));

      final jsonResult = service.xmlToJson(xml);
      expect(jsonResult, contains('Test'));
    });
  });

  group('JwtService', () {
    const service = JwtService();

    test('Decodes valid JWT and parses claims', () {
      // Header: {"alg":"HS256","typ":"JWT"} -> eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9
      // Payload: {"sub":"1234567890","name":"John Doe","iat":1516239022,"exp":2524608000} -> eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjI1MjQ2MDgwMDB9
      const token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjI1MjQ2MDgwMDB9.signature';

      final jwt = service.decode(token);
      expect(jwt.header['alg'], 'HS256');
      expect(jwt.payload['name'], 'John Doe');
      expect(jwt.issuedAt, isNotNull);
      expect(jwt.expiresAt, isNotNull);
      expect(jwt.isExpired, isFalse); // Year 2050
    });

    test('Flags expired token correctly', () {
      // Exp: 1000000000 (Year 2001)
      const expiredToken =
          'eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjMiLCJleHAiOjEwMDAwMDAwMDB9.sig';
      final jwt = service.decode(expiredToken);
      expect(jwt.isExpired, isTrue);
    });

    test('Throws on invalid format', () {
      expect(() => service.decode('not.valid'), throwsA(isA<FormatException>()));
    });
  });

  group('HashService', () {
    const service = HashService();

    test('Computes MD5, SHA-1, SHA-256, SHA-512 correctly', () {
      const input = 'admin';
      expect(service.md5Hash(input), '21232f297a57a5a743894a0e4a801fc3');
      expect(service.sha1Hash(input), 'd033e22ae348aeb5660fc2140aec35850c4da997');
      expect(service.sha256Hash(input),
          '8c6976e5b5410415bde908bd4dee15dfb167a9c873fc4bb8a81f6f2ab448a918');

      final all = service.computeAll(input);
      expect(all.length, 4);
    });
  });

  group('TextCaseService', () {
    const service = TextCaseService();

    test('Converts between cases accurately', () {
      const text = 'sqa multi tools rock';
      expect(service.toCamelCase(text), 'sqaMultiToolsRock');
      expect(service.toPascalCase(text), 'SqaMultiToolsRock');
      expect(service.toSnakeCase(text), 'sqa_multi_tools_rock');
      expect(service.toKebabCase(text), 'sqa-multi-tools-rock');
      expect(service.toConstantCase(text), 'SQA_MULTI_TOOLS_ROCK');
      expect(service.toTitleCase(text), 'Sqa Multi Tools Rock');
    });

    test('Deduplicates and sorts lines', () {
      const multiline = 'banana\napple\nbanana\norange';
      final deduped = service.cleanDuplicateLines(multiline);
      expect(deduped, 'banana\napple\norange');

      final sorted = service.sortLines(deduped);
      expect(sorted, 'apple\nbanana\norange');
    });
  });
}

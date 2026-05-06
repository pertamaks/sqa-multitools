import 'package:faker_dart/faker_dart.dart';
import 'package:uuid/uuid.dart';
import '../utils/faker_fix.dart';
import '../../plugins/curl_requester/models/curl_command.dart';

class FakerResolutionService {
  static final Faker _faker = Faker.instance;
  static const _uuid = Uuid();

  /// Resolves all placeholders in a CurlCommand.
  static CurlCommand resolveCommand(CurlCommand command) {
    final resolvedUrl = resolve(command.url);
    final resolvedBody = resolve(command.body);

    final resolvedHeaders = Map<String, String>.from(command.headers).map(
      (k, v) => MapEntry(k, resolve(v)),
    );

    final resolvedParams = Map<String, String>.from(command.queryParameters).map(
      (k, v) => MapEntry(k, resolve(v)),
    );

    return command.copyWith(
      url: resolvedUrl,
      body: resolvedBody,
      headers: resolvedHeaders,
      queryParameters: resolvedParams,
    );
  }

  /// Resolves placeholders in the format {{faker.type}} within a string.
  static String resolve(String input) {
    if (!input.contains('{{faker.')) return input;

    return input.replaceAllMapped(RegExp(r'\{\{faker\.(\w+)\}\}'), (match) {
      final type = match.group(1);
      return _generateValue(type);
    });
  }

  static String _generateValue(String? type) {
    String result;
    switch (type) {
      case 'name':
        result = _faker.name.fullName();
        break;
      case 'email':
        result = _faker.internet.email();
        break;
      case 'city':
        result = _faker.address.city();
        break;
      case 'guid':
      case 'uuid':
        result = _uuid.v4();
        break;
      case 'phone':
        result = _faker.phoneNumber.phoneNumber();
        break;
      case 'company':
        result = _faker.company.companyName();
        break;
      case 'word':
        result = _faker.lorem.word();
        break;
      case 'sentence':
        result = _faker.lorem.sentence();
        break;
      default:
        return '{{faker.$type}}'; // Return as is if unknown
    }

    return FakerFix.fix(result);
  }
}

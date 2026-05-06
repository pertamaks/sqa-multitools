import 'package:faker_dart/faker_dart.dart';
import 'package:uuid/uuid.dart';
import '../utils/faker_fix.dart';
import '../../plugins/curl_requester/models/curl_command.dart';
import 'preferences_service.dart';

class FakerResolutionService {
  static final Faker _faker = Faker.instance;
  static const _uuid = Uuid();

  /// Resolves all placeholders in a CurlCommand.
  static CurlCommand resolveCommand(CurlCommand command, PreferencesService prefs) {
    // Sync locale from preferences
    final localeName = prefs.getFakerLocale();
    final locale = FakerLocaleType.values.firstWhere(
      (e) => e.name == localeName,
      orElse: () => FakerLocaleType.en_US,
    );
    _faker.setLocale(locale);

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

  /// Regex supporting {{type}} and {{faker.type}}
  static final RegExp _placeholderRegex = RegExp(r'\{\{(?:faker\.)?([a-zA-Z0-9_]+)\}\}');

  static String resolve(String input) {
    if (input.isEmpty) return input;
    
    return input.replaceAllMapped(_placeholderRegex, (match) {
      final type = match.group(1) ?? '';
      return _generateValue(type);
    });
  }

  static String _generateValue(String type) {
    try {
      String result;
      switch (type) {
        case 'name':
          result = _faker.name.fullName();
          break;
        case 'firstName':
          result = _faker.name.firstName();
          break;
        case 'lastName':
          result = _faker.name.lastName();
          break;
        case 'jobTitle':
          result = _faker.name.jobTitle();
          break;
        case 'email':
          result = _faker.internet.email();
          break;
        case 'username':
          result = _faker.fake('{{internet.userName}}');
          break;
        case 'password':
          result = _faker.fake('{{internet.password}}');
          break;
        case 'url':
          result = _faker.internet.url();
          break;
        case 'color':
          result = _faker.fake('{{internet.color}}');
          break;
        case 'ipv4':
          result = _faker.internet.ip();
          break;
        case 'city':
          result = _faker.address.city();
          break;
        case 'street':
          result = _faker.address.streetAddress();
          break;
        case 'country':
          result = _faker.address.country();
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
        case 'product':
          result = _faker.commerce.productName();
          break;
        case 'price':
          result = _faker.commerce.price();
          break;
        case 'creditCard':
          // Manual implementation as faker_dart 0.2.3 lacks finance
          final rand = _faker.datatype;
          result = '${rand.number(min: 4000, max: 4999)}-${rand.number(min: 1000, max: 9999)}-${rand.number(min: 1000, max: 9999)}-${rand.number(min: 1000, max: 9999)}';
          break;
        case 'currency':
          final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD', 'AUD', 'IDR'];
          result = currencies[_faker.datatype.number(max: currencies.length - 1)];
          break;
        case 'amount':
          result = _faker.commerce.price(symbol: '');
          break;
        case 'account':
          result = _faker.datatype.number(min: 10000000, max: 99999999).toString();
          break;
        case 'pastDate':
          final days = _faker.datatype.number(min: 1, max: 3650);
          result = DateTime.now().subtract(Duration(days: days)).toIso8601String();
          break;
        case 'futureDate':
          final days = _faker.datatype.number(min: 1, max: 3650);
          result = DateTime.now().add(Duration(days: days)).toIso8601String();
          break;
        case 'recentDate':
          final days = _faker.datatype.number(min: 1, max: 30);
          result = DateTime.now().subtract(Duration(days: days)).toIso8601String();
          break;
        case 'month':
          result = _faker.date.month();
          break;
        case 'weekday':
          result = _faker.date.weekday();
          break;
        case 'word':
          result = _faker.lorem.word();
          break;
        case 'sentence':
          result = _faker.lorem.sentence();
          break;
        case 'paragraph':
          result = _faker.lorem.paragraph();
          break;
        default:
          return '{{faker.$type}}';
      }
      return FakerFix.fix(result);
    } catch (_) {
      return '{{faker.$type}}';
    }
  }
}

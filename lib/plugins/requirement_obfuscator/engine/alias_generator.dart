import 'dart:math';
import 'package:faker_dart/faker_dart.dart';
import '../models/dictionary_entry.dart';
import '../models/obfuscator_workspace.dart';

class AliasGenerator {
  static final Faker _faker = Faker.instance;
  static final Random _rand = Random();

  static const List<String> _animals = [
    'Eagle',
    'Falcon',
    'Hawk',
    'Panther',
    'Tiger',
    'Lion',
    'Wolf',
    'Bear',
    'Shark',
    'Orca',
    'Raven',
    'Cobra',
    'Cheetah',
    'Jaguar',
    'Viper',
    'Condor',
  ];

  static const List<String> _metals = [
    'Gold',
    'Silver',
    'Bronze',
    'Iron',
    'Steel',
    'Copper',
    'Titanium',
    'Platinum',
    'Cobalt',
    'Silicon',
    'Carbon',
    'Chrome',
    'Nickel',
    'Zinc',
  ];

  /// Generates a randomized replacement alias according to the strategy and category.
  static String generate({
    required String original,
    required EntryCategory category,
    required SubstitutionStrategy strategy,
    int index = 1,
  }) {
    switch (strategy) {
      case SubstitutionStrategy.token:
        final prefix = category.name.toUpperCase();
        return '[$prefix-$index]';

      case SubstitutionStrategy.codename:
        final prefix = _metals[_rand.nextInt(_metals.length)];
        final suffix = _animals[_rand.nextInt(_animals.length)];
        return '$prefix$suffix';

      case SubstitutionStrategy.semantic:
        switch (category) {
          case EntryCategory.model:
            // e.g. Product, Account, Invoice
            try {
              final type = _faker.database.type();
              if (type.isNotEmpty) return type;
            } catch (_) {}
            return 'ModelAlias${_rand.nextInt(100)}';

          case EntryCategory.field:
            // e.g. price, firstName, password
            try {
              final col = _faker.database.column();
              if (col.isNotEmpty) return col;
            } catch (_) {}
            return 'field_alias_${_rand.nextInt(100)}';

          case EntryCategory.endpoint:
            // e.g. /users, /orders
            try {
              final word1 = _faker.lorem.word().toLowerCase();
              final word2 = _faker.lorem.word().toLowerCase();
              if (word1.isNotEmpty && word2.isNotEmpty) {
                return '/$word1/$word2';
              }
            } catch (_) {}
            return '/route/endpoint_${_rand.nextInt(100)}';

          case EntryCategory.service:
            // e.g. PaymentGateway, EmailNotifier
            try {
              final comp = _faker.company.companyName().replaceAll(
                RegExp(r'[^a-zA-Z]'),
                '',
              );
              if (comp.isNotEmpty) return '${comp}Service';
            } catch (_) {}
            return 'ServiceAlias${_rand.nextInt(100)}';

          case EntryCategory.config:
            // e.g. PORT, HOST
            try {
              final word = _faker.lorem.word().toUpperCase();
              if (word.isNotEmpty) return 'CONF_${word}_${_rand.nextInt(100)}';
            } catch (_) {}
            return 'CONFIG_VAR_${_rand.nextInt(1000)}';

          case EntryCategory.general:
            try {
              final word = _faker.lorem.word();
              if (word.isNotEmpty) return word;
            } catch (_) {}
            return 'alias_${_rand.nextInt(1000)}';
        }
    }
  }
}

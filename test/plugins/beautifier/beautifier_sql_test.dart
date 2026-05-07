import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/plugins/beautifier/providers/beautifier_provider.dart';
import 'package:sqa_multitools/plugins/beautifier/widgets/beautifier_highlighter.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  group('SQL Formatter Tests', () {
    test('formats simple select query', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.sql);
      notifier.updateInput('select * from users where id = 1');
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(state.output, contains('SELECT'));
      expect(state.output, contains('  *'));
      expect(state.output, contains('FROM'));
      expect(state.output, contains('  users'));
      expect(state.output, contains('WHERE'));
      expect(state.output, contains('  id = 1'));
    });

    test('capitalizes keywords and normalizes spacing', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.sql);
      notifier.updateInput(
        '  select   col1,  col2 from   table1   order by col1  ',
      );
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(state.output, contains('SELECT'));
      expect(state.output, contains('  col1,'));
      expect(state.output, contains('FROM'));
      expect(state.output, contains('  table1'));
      expect(state.output, contains('ORDER BY'));
      expect(state.output, contains('  col1'));
    });

    test('handles subqueries with indentation', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.sql);
      notifier.updateInput('SELECT * FROM (SELECT id FROM users) AS t1');
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(state.output, contains('FROM'));
      expect(state.output, contains('  ('));
      expect(state.output, contains('SELECT'));
      expect(state.output, contains('    id'));
    });

    test('handles JOIN and ON clauses', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.sql);
      notifier.updateInput(
        'SELECT t1.* FROM table1 t1 JOIN table2 t2 ON t1.id = t2.ref_id',
      );
      notifier.format();

      final state = container.read(beautifierProvider);
      expect(state.output, contains('JOIN'));
      expect(state.output, contains('  ON'));
    });

    test('formats complex multi-statement SQL with custom indentation', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.sql);
      notifier.setIndentWidth(4);

      const complexSql =
          "CREATE TABLE inventory(id INT PRIMARY KEY, name VARCHAR(255)); "
          "INSERT INTO inventory(id, name) VALUES(1, 'Processor'), (2, 'Motherboard');";

      notifier.updateInput(complexSql);
      notifier.format();

      final state = container.read(beautifierProvider);

      // Verify structure
      expect(state.output, contains('CREATE TABLE'));
      expect(state.output, contains('    id INT PRIMARY KEY'));
      expect(state.output, contains('INSERT INTO'));
      expect(state.output, contains('VALUES'));
      expect(state.output, contains("    (1, 'Processor')"));
      expect(state.output, contains("    (2, 'Motherboard')"));
    });

    test('respects indentWidth parameter', () {
      final notifier = container.read(beautifierProvider.notifier);
      notifier.setLanguage(BeautifierLanguage.sql);

      const sql = 'SELECT id, name FROM users';

      // Test with 2 spaces
      notifier.setIndentWidth(2);
      notifier.updateInput(sql);
      notifier.format();
      expect(container.read(beautifierProvider).output, contains('\n  id,'));
      expect(container.read(beautifierProvider).output, contains('\n  name'));

      // Test with 8 spaces
      notifier.setIndentWidth(8);
      notifier.format(); // Trigger with new setting
      expect(
        container.read(beautifierProvider).output,
        contains('\n        id,'),
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqa_multitools/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqa_multitools/core/services/preferences_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SqaMultitoolsApp(),
      ),
    );

    expect(find.byType(SqaMultitoolsApp), findsOneWidget);
  });
}

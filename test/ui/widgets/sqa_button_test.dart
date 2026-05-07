import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/ui/widgets/sqa_button.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('SqaButton Widget Tests', () {
    testWidgets('displays label and icon for primary button', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SqaButton.primary(
              label: 'Primary Action',
              icon: Symbols.add,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Primary Action'), findsOneWidget);
      expect(find.byIcon(Symbols.add), findsOneWidget);

      await tester.tap(find.byType(SqaButton));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading state when set', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SqaButton.tonal(
              label: 'Loading Button',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      // Label should be hidden during loading
      expect(find.text('Loading Button'), findsNothing);
      // Loader should be present
      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SqaButton.outlined(label: 'Disabled Button', onPressed: null),
          ),
        ),
      );

      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('respects custom width and height', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SqaButton.primary(
              label: 'Custom Size',
              width: 250,
              onPressed: null,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 250);
      expect(sizedBox.height, 32); // SqaButton has fixed height of 32
    });
  });
}

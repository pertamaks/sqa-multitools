import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/ui/widgets/sqa_toast.dart';

void main() {
  testWidgets('SqaToast shows message and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    SqaToast.show(
                      context,
                      'Test Message',
                      type: SqaToastType.success,
                    );
                  },
                  child: const Text('Show Toast'),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Tap the button to show the toast
    await tester.tap(find.text('Show Toast'));
    await tester.pump(); // Start animation
    await tester.pump(
      const Duration(milliseconds: 500),
    ); // Wait for it to be visible

    // Verify message is present
    expect(find.text('Test Message'), findsOneWidget);

    // Verify icon is present (success uses check_circle)
    expect(find.byType(Icon), findsOneWidget);

    // Wait for the toast to dismiss to clear pending timers
    await tester.pumpAndSettle();
  });
}

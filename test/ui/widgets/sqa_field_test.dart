import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqa_multitools/ui/widgets/sqa_field.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  group('SqaField Widget Tests', () {
    testWidgets('displays label and initial value in read-only mode', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SqaField(
              label: 'Test Label',
              initialValue: 'Initial Value',
              readOnly: true,
            ),
          ),
        ),
      );

      // Label is rendered exactly as passed
      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Initial Value'), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isTrue);
      expect(textField.style?.height, 1.5);
    });

    testWidgets('allows typing in input mode with controller', (
      WidgetTester tester,
    ) async {
      final controller = TextEditingController();
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SqaField(
              label: 'Input Label',
              controller: controller,
              onChanged: (val) => changedValue = val,
              readOnly: false,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello World');
      expect(controller.text, 'Hello World');
      expect(changedValue, 'Hello World');

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.readOnly, isFalse);
    });

    testWidgets('handles multiline configuration correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SqaField(
              label: 'Multiline Label',
              initialValue: 'Line 1\nLine 2',
              isMultiline: true,
              maxLines: 5,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 5);
    });

    testWidgets('shows icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SqaField(
              label: 'Icon Label',
              initialValue: 'Value',
              icon: Symbols.search,
            ),
          ),
        ),
      );

      expect(find.byIcon(Symbols.search), findsOneWidget);
    });

    testWidgets('shows copy button and it is clickable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SqaField(
              label: 'Copy Label',
              initialValue: 'Text to copy',
              showCopyButton: true,
            ),
          ),
        ),
      );

      final copyButton = find.byType(IconButton);
      expect(copyButton, findsOneWidget);
      expect(find.byIcon(Symbols.content_copy), findsOneWidget);

      await tester.tap(copyButton);
      await tester.pump();
      // Clipboard interaction is hard to test in pure widget tests without mocks,
      // but we verified the button is present and hittable.
    });

    testWidgets('handles expansion when collapsedMaxLines is set', (
      WidgetTester tester,
    ) async {
      const longText = 'Line 1\nLine 2\nLine 3\nLine 4\nLine 5';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SqaField(
              label: 'Expandable Field',
              initialValue: longText,
              collapsedMaxLines: 2,
            ),
          ),
        ),
      );

      // Initially should show expansion footer
      expect(find.textContaining('More Lines'), findsOneWidget);

      // TextField should have limited maxLines initially
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 2);

      // Tap to expand
      await tester.tap(find.textContaining('More Lines'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Footer should change text
      expect(find.text('Show Less'), findsOneWidget);

      // TextField should now have null maxLines (or the default multiline maxLines)
      final expandedField = tester.widget<TextField>(find.byType(TextField));
      expect(expandedField.maxLines, isNot(2));
    });

    testWidgets('handles horizontal scroll with no wrap', (
      WidgetTester tester,
    ) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SqaField(
              label: 'No Wrap Field',
              initialValue: 'Very long text that should not wrap',
              wrap: false,
              horizontalScrollController: scrollController,
            ),
          ),
        ),
      );

      // Should find a SingleChildScrollView for horizontal scrolling
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.scrollDirection, Axis.horizontal);
      expect(scrollView.controller, scrollController);
    });

    testWidgets('has reserved right margin when copy button is shown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SqaField(label: 'Padding Test', showCopyButton: true),
          ),
        ),
      );

      // Find the row that contains the main content (prefix, numbers, text)
      // We look for the Padding that is a direct child of the Stack
      final paddingFinder = find
          .descendant(of: find.byType(Stack), matching: find.byType(Padding))
          .first;
      final paddingWidget = tester.widget<Padding>(paddingFinder);

      final padding = paddingWidget.padding as EdgeInsets;
      expect(padding.right, 44.0);

      // TextField should have standard horizontal padding (16)
      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration as InputDecoration;
      expect(decoration.contentPadding?.horizontal, 32.0);
    });
  });
}

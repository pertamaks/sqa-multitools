import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:sqa_multitools/ui/widgets/sqa_modal.dart';

void main() {
  Widget buildTestApp(Widget modal) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () =>
                  showDialog<void>(context: context, builder: (_) => modal),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('SqaModal.tile', () {
    testWidgets('renders tile items with labels and badges', (tester) async {
      final items = ['Monitor A', 'Monitor B'];

      await tester.pumpWidget(
        buildTestApp(
          SqaModal<String>.tile(
            title: 'Select Display',
            items: items,
            tileBuilder: (String item, int index) => SqaPickerTile(
              label: 'Display ${index + 1}',
              badge: index == 0 ? 'PRIMARY' : null,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Select Display'), findsOneWidget);
      expect(find.text('Display 1'), findsOneWidget);
      expect(find.text('Display 2'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('SqaModal.list', () {
    testWidgets('renders list items with icons', (tester) async {
      final items = ['Notepad', 'Chrome'];

      await tester.pumpWidget(
        buildTestApp(
          SqaModal<String>.list(
            title: 'Select Window',
            items: items,
            itemBuilder: (String item, int index) =>
                SqaPickerItem(icon: Symbols.window, label: item),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Select Window'), findsOneWidget);
      expect(find.text('Notepad'), findsOneWidget);
      expect(find.text('Chrome'), findsOneWidget);
    });
  });

  group('SqaModal.confirm', () {
    testWidgets('renders title, message and action buttons', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          const SqaModal<void>.confirm(
            title: 'Confirm Delete',
            message: 'Are you sure?',
            confirmLabel: 'Delete',
            cancelLabel: 'Dismiss',
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('returns true on confirm tap', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await SqaModal.showConfirm(
                      context,
                      title: 'Delete',
                      message: 'Confirm?',
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets('returns false on cancel tap', (tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await SqaModal.showConfirm(
                      context,
                      title: 'Delete',
                      message: 'Confirm?',
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, false);
    });
  });
}

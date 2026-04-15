import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:sqa_multitools/ui/widgets/sqa_picker_dialog.dart';

void main() {
  Widget buildTestApp(Widget dialog) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => dialog,
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
  }

  group('SqaPickerDialog.tile', () {
    testWidgets('renders tile items with labels and badges', (tester) async {
      final items = ['Monitor A', 'Monitor B'];

      await tester.pumpWidget(buildTestApp(
        SqaPickerDialog<String>.tile(
          title: 'Select Display',
          items: items,
          tileBuilder: (item, index) => SqaPickerTile(
            label: 'Display ${index + 1}',
            badge: index == 0 ? 'PRIMARY' : null,
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Select Display'), findsOneWidget);
      expect(find.text('Display 1'), findsOneWidget);
      expect(find.text('Display 2'), findsOneWidget);
      expect(find.text('PRIMARY'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('pops with correct item on tap', (tester) async {
      String? result;
      final items = ['A', 'B'];

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (_) => SqaPickerDialog<String>.tile(
                      title: 'Pick',
                      items: items,
                      tileBuilder: (item, index) =>
                          SqaPickerTile(label: 'Item $item'),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Tap the card area that contains 'Item B'
      // The SqaCard's InkWell wraps the entire card content.
      final itemBFinder = find.ancestor(
        of: find.text('Item B'),
        matching: find.byType(InkWell),
      );
      await tester.tap(itemBFinder.first);
      await tester.pumpAndSettle();

      expect(result, 'B');
    });

    testWidgets('shows refresh button when onRefresh is provided',
        (tester) async {
      bool refreshed = false;

      await tester.pumpWidget(buildTestApp(
        SqaPickerDialog<String>.tile(
          title: 'Pick',
          items: const ['x'],
          tileBuilder: (item, index) => SqaPickerTile(label: item),
          onRefresh: () => refreshed = true,
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      expect(refreshed, true);
    });

    testWidgets('shows empty state when items list is empty', (tester) async {
      await tester.pumpWidget(buildTestApp(
        SqaPickerDialog<String>.tile(
          title: 'Pick',
          items: const [],
          tileBuilder: (item, index) => SqaPickerTile(label: item),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
    });
  });

  group('SqaPickerDialog.list', () {
    testWidgets('renders list items with icons', (tester) async {
      final items = ['Notepad', 'Chrome'];

      await tester.pumpWidget(buildTestApp(
        SqaPickerDialog<String>.list(
          title: 'Select Window',
          items: items,
          itemBuilder: (item, index) => SqaPickerItem(
            icon: Symbols.window,
            label: item,
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Select Window'), findsOneWidget);
      expect(find.text('Notepad'), findsOneWidget);
      expect(find.text('Chrome'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(buildTestApp(
        SqaPickerDialog<String>.list(
          title: 'Loading',
          items: const [],
          isLoading: true,
          itemBuilder: (item, index) => SqaPickerItem(
            icon: Symbols.window,
            label: item,
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pump(); // Don't use pumpAndSettle: spinner never settles
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows custom empty state', (tester) async {
      await tester.pumpWidget(buildTestApp(
        SqaPickerDialog<String>.list(
          title: 'Empty',
          items: const [],
          emptyIcon: Symbols.search_off,
          emptyLabel: 'Nothing here',
          itemBuilder: (item, index) => SqaPickerItem(
            icon: Symbols.window,
            label: item,
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('pops with correct item on list tap', (tester) async {
      String? result;

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (_) => SqaPickerDialog<String>.list(
                      title: 'Pick',
                      items: const ['Alpha', 'Beta'],
                      itemBuilder: (item, index) => SqaPickerItem(
                        icon: Symbols.window,
                        label: item,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();

      expect(result, 'Beta');
    });

    testWidgets('Cancel button pops with null', (tester) async {
      String? result = 'initial';

      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDialog<String>(
                    context: context,
                    builder: (_) => SqaPickerDialog<String>.list(
                      title: 'Pick',
                      items: const ['X'],
                      itemBuilder: (item, index) => SqaPickerItem(
                        icon: Symbols.window,
                        label: item,
                      ),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}

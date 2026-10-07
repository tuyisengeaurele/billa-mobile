import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/documents/presentation/widgets/item_search_field.dart';
import 'package:billa_mobile/features/items/domain/item.dart';
import '../../../../support/tall_screen.dart';

const _printing = Item(id: 'i1', description: 'Printing', unitPrice: 5000, unit: 'page', taxRate: 18, isActive: true);
const _paper = Item(id: 'i2', description: 'Paper', unitPrice: 300, unit: 'sheet', taxRate: 18, isActive: true);

void main() {
  late TextEditingController controller;
  late List<String> queries;
  late List<Item> selected;
  late List<String> typed;

  setUp(() {
    controller = TextEditingController();
    queries = [];
    selected = [];
    typed = [];
  });

  tearDown(() => controller.dispose());

  Widget host(Future<List<Item>> Function(String query) search, {String? errorText}) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ItemSearchField(
              controller: controller,
              fieldKey: const Key('field'),
              errorText: errorText,
              searchItems: (query) {
                queries.add(query);
                return search(query);
              },
              onItemSelected: selected.add,
              onTextChanged: typed.add,
            ),
          ),
        ),
      );

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const Key('field')), text);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
  }

  testWidgets('shows matching items with their unit and price after the debounce', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(host((query) async => [_printing, _paper]));
    await type(tester, 'pa');

    expect(find.text('Printing'), findsOneWidget);
    expect(find.text('page'), findsOneWidget);
    expect(find.text('RWF 5,000'), findsOneWidget);
    expect(find.text('Paper'), findsOneWidget);
    expect(queries, ['pa']);
  });

  testWidgets('selecting an item reports it and fills the field', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(host((query) async => [_printing]));
    await type(tester, 'pri');
    await tester.tap(find.byKey(const Key('item-option-i1')));
    await tester.pumpAndSettle();

    await tester.pump(const Duration(milliseconds: 400));

    expect(selected, [_printing]);
    expect(controller.text, 'Printing');
    expect(queries, ['pri']);
  });

  testWidgets('typed text is reported as free text and can be kept as a custom line', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(host((query) async => []));
    await type(tester, 'Delivery to Huye');

    expect(typed.last, 'Delivery to Huye');
    expect(find.text('Use "Delivery to Huye" as the description'), findsOneWidget);

    await tester.tap(find.byKey(const Key('item-option-free-text')));
    await tester.pumpAndSettle();

    expect(selected, isEmpty);
    expect(controller.text, 'Delivery to Huye');
  });

  testWidgets('a fast typist triggers a single search for the final text', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(host((query) async => [_printing]));
    for (final partial in ['p', 'pr', 'pri']) {
      await tester.enterText(find.byKey(const Key('field')), partial);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(queries, ['pri']);
  });

  testWidgets('a slower earlier response never replaces a newer one', (tester) async {
    useTallScreen(tester);
    final slow = Completer<List<Item>>();
    await tester.pumpWidget(host((query) => query == 'pa' ? slow.future : Future.value([_printing])));

    await tester.enterText(find.byKey(const Key('field')), 'pa');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.enterText(find.byKey(const Key('field')), 'pri');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    slow.complete([_paper]);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('item-option-i1')), findsOneWidget);
    expect(find.byKey(const Key('item-option-i2')), findsNothing);
  });

  testWidgets('a failed search says so, keeps the custom line available, and the next keystroke retries', (tester) async {
    useTallScreen(tester);
    var failing = true;
    await tester.pumpWidget(host((query) async {
      if (failing) throw Exception('offline');
      return [_printing];
    }));
    await type(tester, 'pri');

    expect(find.text("Couldn't load your items"), findsOneWidget);
    expect(find.byKey(const Key('item-option-free-text')), findsOneWidget);

    failing = false;
    await type(tester, 'prin');

    expect(find.byKey(const Key('item-option-i1')), findsOneWidget);
    expect(find.text("Couldn't load your items"), findsNothing);
  });

  testWidgets('focusing an empty field on a business with no items explains what to do', (tester) async {
    useTallScreen(tester);
    await tester.pumpWidget(host((query) async => []));
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('No items yet'), findsOneWidget);
    expect(find.text('Type a description to add a custom line'), findsOneWidget);
  });

  testWidgets('a validation message sits under the field and never overlaps what follows', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Column(
          children: [
            ItemSearchField(
              controller: controller,
              fieldKey: const Key('field'),
              errorText: 'Enter a description',
              searchItems: (query) async => [],
              onItemSelected: (_) {},
              onTextChanged: (_) {},
            ),
            const SizedBox(height: 12),
            const TextField(key: Key('next'), decoration: InputDecoration(labelText: 'Qty')),
          ],
        ),
      ),
    ));

    final errorBottom = tester.getBottomLeft(find.text('Enter a description')).dy;
    final nextTop = tester.getTopLeft(find.byKey(const Key('next'))).dy;

    expect(errorBottom, lessThanOrEqualTo(nextTop));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/widgets/swipe_row.dart';

void main() {
  var contacted = 0;
  var paid = 0;

  setUp(() {
    contacted = 0;
    paid = 0;
  });

  Widget host() => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: SwipeRow(
            startActions: [
              SwipeAction(key: const Key('swipe-contact'), label: 'Contact', icon: Icons.chat_outlined, onPressed: () => contacted++),
            ],
            endActions: [
              SwipeAction(key: const Key('swipe-pay'), label: 'Record payment', icon: Icons.payments_outlined, onPressed: () => paid++),
            ],
            child: const ListTile(title: Text('Acme')),
          ),
        ),
      );

  testWidgets('dragging right reveals the start action and tapping it runs it', (tester) async {
    await tester.pumpWidget(host());

    await tester.drag(find.text('Acme'), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('swipe-contact')));
    await tester.pumpAndSettle();

    expect(contacted, 1);
    expect(paid, 0);
  });

  testWidgets('dragging left reveals the end action and tapping it runs it', (tester) async {
    await tester.pumpWidget(host());

    await tester.drag(find.text('Acme'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('swipe-pay')));
    await tester.pumpAndSettle();

    expect(paid, 1);
  });

  testWidgets('every action is also offered to screen readers', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host());

    final data = tester.getSemantics(find.text('Acme')).getSemanticsData();
    final labels = data.customSemanticsActionIds!.map((id) => CustomSemanticsAction.getAction(id)!.label);

    expect(labels, containsAll(['Contact', 'Record payment']));
    handle.dispose();
  });

  testWidgets('a row with no actions is just its child', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: SwipeRow(child: ListTile(title: Text('Plain')))),
    ));

    expect(find.text('Plain'), findsOneWidget);
    expect(find.byType(SwipeRow), findsOneWidget);
  });
}

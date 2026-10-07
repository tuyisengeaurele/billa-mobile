import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/core/widgets/fade_switcher.dart';

void main() {
  testWidgets('cross-fades between views that have different keys', (tester) async {
    Widget host(String view) => MaterialApp(
          home: FadeSwitcher(child: Text(view, key: ValueKey(view))),
        );

    await tester.pumpWidget(host('loading'));
    await tester.pumpWidget(host('data'));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('loading'), findsOneWidget);
    expect(find.text('data'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('loading'), findsNothing);
  });

  test('asyncViewKind names the four views and ignores paging', () {
    bool isEmpty(List<int> items) => items.isEmpty;

    expect(asyncViewKind<List<int>>(const AsyncLoading(), isEmpty: isEmpty), 'loading');
    expect(asyncViewKind<List<int>>(AsyncError(Exception('x'), StackTrace.empty), isEmpty: isEmpty), 'error');
    expect(asyncViewKind<List<int>>(const AsyncData([]), isEmpty: isEmpty), 'empty');
    expect(asyncViewKind<List<int>>(const AsyncData([1]), isEmpty: isEmpty), 'data');
    expect(asyncViewKind<List<int>>(const AsyncData([1, 2, 3]), isEmpty: isEmpty), 'data');
  });
}

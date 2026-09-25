import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/app/shell/glass_nav_bar.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';

const _destinations = [
  NavDestination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
  NavDestination(icon: Icons.description_outlined, selectedIcon: Icons.description, label: 'Documents'),
  NavDestination(icon: Icons.people_outline, selectedIcon: Icons.people, label: 'Customers'),
  NavDestination(icon: Icons.payments_outlined, selectedIcon: Icons.payments, label: 'Payments', badge: 3),
  NavDestination(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
];

Widget _host({required int index, required ValueChanged<int> onSelected, List<NavDestination> items = _destinations}) =>
    ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GlassNavBar(destinations: items, currentIndex: index, onSelected: onSelected),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('shows a label for every destination and marks only the selected one', (tester) async {
    await tester.pumpWidget(_host(index: 1, onSelected: (_) {}));

    for (final label in ['Home', 'Documents', 'Customers', 'Payments', 'Profile']) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byIcon(Icons.description), findsOneWidget);
    expect(find.byIcon(Icons.description_outlined), findsNothing);
    expect(find.byIcon(Icons.home_outlined), findsOneWidget);
  });

  testWidgets('tapping a tab reports its index', (tester) async {
    final taps = <int>[];
    await tester.pumpWidget(_host(index: 0, onSelected: taps.add));

    await tester.tap(find.byKey(const Key('nav-tab-2')));
    await tester.tap(find.byKey(const Key('nav-tab-0')));

    expect(taps, [2, 0]);
  });

  testWidgets('the highlight capsule slides under the newly selected tab', (tester) async {
    await tester.pumpWidget(_host(index: 0, onSelected: (_) {}));
    final startX = tester.getCenter(find.byKey(const Key('nav-highlight'))).dx;

    await tester.pumpWidget(_host(index: 3, onSelected: (_) {}));
    await tester.pump(const Duration(milliseconds: 100));
    final midX = tester.getCenter(find.byKey(const Key('nav-highlight'))).dx;
    await tester.pumpAndSettle();
    final endX = tester.getCenter(find.byKey(const Key('nav-highlight'))).dx;

    expect(midX, greaterThan(startX));
    expect(endX, greaterThan(midX));
    expect(endX, closeTo(tester.getCenter(find.byKey(const Key('nav-tab-3'))).dx, 1));
  });

  testWidgets('a badge shows the count and is announced with the label', (tester) async {
    await tester.pumpWidget(_host(index: 0, onSelected: (_) {}));

    expect(find.descendant(of: find.byKey(const Key('nav-tab-3')), matching: find.text('3')), findsOneWidget);
    expect(tester.getSemantics(find.byKey(const Key('nav-tab-3'))).label, 'Payments, 3 overdue');
  });

  testWidgets('no badge is drawn for a zero count', (tester) async {
    await tester.pumpWidget(_host(index: 0, onSelected: (_) {}));

    expect(tester.widget<Badge>(find.descendant(of: find.byKey(const Key('nav-tab-0')), matching: find.byType(Badge))).isLabelVisible, isFalse);
  });

  testWidgets('every tab is at least 48 logical pixels tall and wide', (tester) async {
    await tester.pumpWidget(_host(index: 0, onSelected: (_) {}));

    for (var i = 0; i < 5; i++) {
      final size = tester.getSize(find.byKey(Key('nav-tab-$i')));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
    }
  });
}

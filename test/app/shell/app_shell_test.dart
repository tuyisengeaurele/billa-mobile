import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:billa_mobile/app/shell/app_shell.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/dashboard/presentation/providers/dashboard_provider.dart';

class _Counter extends StatefulWidget {
  const _Counter({required this.label});

  final String label;

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int taps = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            key: Key('counter-${widget.label}'),
            onPressed: () => setState(() => taps++),
            child: Text('${widget.label} $taps'),
          ),
        ),
      );
}

void main() {
  Widget buildApp({int overdue = 0, String initial = '/'}) {
    final router = GoRouter(initialLocation: initial, routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: '/', builder: (context, state) => const _Counter(label: 'home'))]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/documents',
              builder: (context, state) => const _Counter(label: 'documents'),
              routes: [
                GoRoute(path: 'inner', builder: (context, state) => const Scaffold(body: Text('inner screen'))),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [GoRoute(path: '/customers', builder: (context, state) => const _Counter(label: 'customers'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/receivables', builder: (context, state) => const _Counter(label: 'payments'))]),
          StatefulShellBranch(routes: [GoRoute(path: '/settings', builder: (context, state) => const _Counter(label: 'profile'))]),
        ],
      ),
      GoRoute(path: '/pushed', builder: (context, state) => const Scaffold(body: Text('pushed screen'))),
    ]);
    return ProviderScope(
      overrides: [overdueCountProvider.overrideWithValue(overdue)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('shows the five tabs as icons named for screen readers, starting on Home', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    for (final (i, label) in ['Home', 'Documents', 'Customers', 'Payments', 'Profile'].indexed) {
      expect(tester.getSemantics(find.byKey(Key('nav-tab-$i'))).label, label);
      expect(find.descendant(of: find.byKey(Key('nav-tab-$i')), matching: find.byType(Text)), findsNothing);
    }
    expect(find.text('home 0'), findsOneWidget);
  });

  testWidgets('switching tabs shows that tab and each one keeps its own state', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('counter-home')));
    await tester.pump();
    expect(find.text('home 1'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-tab-2')));
    await tester.pumpAndSettle();
    expect(find.text('customers 0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-tab-0')));
    await tester.pumpAndSettle();
    expect(find.text('home 1'), findsOneWidget);
  });

  testWidgets('tapping the selected tab returns it to its root', (tester) async {
    await tester.pumpWidget(buildApp(initial: '/documents/inner'));
    await tester.pumpAndSettle();
    expect(find.text('inner screen'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-tab-1')));
    await tester.pumpAndSettle();

    expect(find.text('inner screen'), findsNothing);
    expect(find.text('documents 0'), findsOneWidget);
  });

  testWidgets('the Payments tab shows the overdue count as a badge and hides it at zero', (tester) async {
    await tester.pumpWidget(buildApp(overdue: 4));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const Key('nav-tab-3')), matching: find.text('4')), findsOneWidget);

    await tester.pumpWidget(buildApp(overdue: 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Badge>(find.descendant(of: find.byKey(const Key('nav-tab-3')), matching: find.byType(Badge))).isLabelVisible,
      isFalse,
    );
  });

  testWidgets('the create button shows on the work tabs and not on Profile', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick-create')), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-tab-4')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick-create')), findsNothing);

    await tester.tap(find.byKey(const Key('nav-tab-3')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quick-create')), findsOneWidget);
  });

  testWidgets('the bar is covered by a screen pushed on top and comes back after popping', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(AppShell));
    GoRouter.of(context).push('/pushed');
    await tester.pumpAndSettle();

    expect(find.text('pushed screen'), findsOneWidget);
    expect(find.byKey(const Key('nav-tab-0')).hitTestable(), findsNothing);

    GoRouter.of(context).pop();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nav-tab-0')).hitTestable(), findsOneWidget);
  });

  testWidgets('screens are told the bar footprint so their last row can stay clear of it', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    final padding = MediaQuery.of(tester.element(find.byKey(const Key('counter-home')))).padding.bottom;

    expect(padding, greaterThanOrEqualTo(64));
  });

  testWidgets('the bar slides out of the way while the keyboard is open', (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    final before = tester.getTopLeft(find.byKey(const Key('nav-tab-0'))).dy;

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.byKey(const Key('nav-tab-0'))).dy, greaterThan(before));
  });
}

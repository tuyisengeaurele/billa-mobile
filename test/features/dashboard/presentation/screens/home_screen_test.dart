import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/businesses/presentation/providers/my_businesses_provider.dart';
import 'package:billa_mobile/features/dashboard/domain/dashboard_repository.dart';
import 'package:billa_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:billa_mobile/features/dashboard/domain/revenue_summary.dart';
import 'package:billa_mobile/features/dashboard/presentation/providers/dashboard_repository_provider.dart';
import 'package:billa_mobile/features/dashboard/presentation/screens/home_screen.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_page.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_repository.dart';
import 'package:billa_mobile/features/notifications/presentation/providers/notifications_repository_provider.dart';
import '../../../account/support.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

class _MockNotificationsRepository extends Mock implements NotificationsRepository {}

const _summary = DashboardSummary(
  draftCount: 3,
  overdueInvoiceCount: 0,
  expiringQuoteCount: 2,
  recentDocuments: [
    RecentDocument(
      id: 'd1',
      type: DocumentType.invoice,
      number: 'INV-0001',
      status: DocumentStatus.finalized,
      customerName: 'Acme Ltd',
      issueDate: '2026-03-01T00:00:00.000Z',
      paymentStatus: PaymentStatus.unpaid,
    ),
  ],
  documentsThisMonth: 4,
  documentsLastMonth: 2,
  customerCount: 5,
);

RevenueSummary _revenue({int thisMonth = 120000, int lastMonth = 100000}) => RevenueSummary(
      invoicedThisMonth: thisMonth,
      invoicedLastMonth: lastMonth,
      invoicedYearToDate: 500000,
      creditedYearToDate: 0,
      netYearToDate: 500000,
      totalCollected: 300000,
      totalOutstanding: 180000,
      monthlyRevenue: const [
        MonthlyRevenue(month: '2026-01', invoiced: 50000, credited: 0, net: 50000),
        MonthlyRevenue(month: '2026-02', invoiced: 100000, credited: 0, net: 100000),
      ],
      topCustomers: const [],
    );

DioException _error() => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': 'server_error'}),
    );

void main() {
  late _MockDashboardRepository dashboard;
  late _MockNotificationsRepository notifications;

  setUp(() {
    dashboard = _MockDashboardRepository();
    notifications = _MockNotificationsRepository();
    when(() => dashboard.summary()).thenAnswer((_) async => _summary);
    when(() => dashboard.revenue()).thenAnswer((_) async => _revenue());
    when(() => notifications.list()).thenAnswer((_) async => const NotificationsPage(results: [], unreadCount: 0));
  });

  Widget buildApp({bool owner = false}) {
    Widget stub(String label) => Scaffold(body: Text(label));
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/documents', builder: (context, state) => stub('documents ${state.uri}')),
      GoRoute(path: '/documents/:id', builder: (context, state) => stub('document ${state.pathParameters['id']}')),
      GoRoute(path: '/receivables', builder: (context, state) => stub('receivables screen')),
      GoRoute(path: '/customers/new', builder: (context, state) => stub('new customer screen')),
      GoRoute(path: '/customers', builder: (context, state) => stub('customers screen')),
      GoRoute(path: '/search', builder: (context, state) => stub('search screen')),
      GoRoute(path: '/notifications', builder: (context, state) => stub('inbox screen')),
      GoRoute(path: '/settings', builder: (context, state) => stub('settings screen')),
      GoRoute(path: '/businesses', builder: (context, state) => stub('businesses screen')),
      GoRoute(path: '/team', builder: (context, state) => stub('team screen')),
    ]);
    return ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(FakeAuthController.new),
        dashboardRepositoryProvider.overrideWithValue(dashboard),
        notificationsRepositoryProvider.overrideWithValue(notifications),
        isOwnerOfActiveBusinessProvider.overrideWith((ref) => owner),
      ],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  Future<void> pumpHome(WidgetTester tester, {bool owner = false}) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(buildApp(owner: owner));
    await tester.pumpAndSettle();
  }

  testWidgets('shows the business name, the invoiced figure, and the month-over-month change', (tester) async {
    await pumpHome(tester);

    expect(find.text('Acme'), findsOneWidget);
    expect(find.text('RWF 120,000'), findsOneWidget);
    expect(find.text('20% more than last month'), findsOneWidget);
    expect(find.text('RWF 300,000'), findsOneWidget);
    expect(find.text('RWF 180,000'), findsOneWidget);
  });

  testWidgets('describes a drop, a flat month, and a first month of invoices', (tester) async {
    for (final (revenue, text) in [
      (_revenue(thisMonth: 80000), '20% less than last month'),
      (_revenue(thisMonth: 100000), 'Same as last month'),
      (_revenue(lastMonth: 0), 'First month of invoices'),
      (_revenue(thisMonth: 0, lastMonth: 0), 'No invoices this month yet'),
    ]) {
      when(() => dashboard.revenue()).thenAnswer((_) async => revenue);
      await pumpHome(tester);

      expect(find.text(text), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('attention cards show counts and open the matching lists', (tester) async {
    await pumpHome(tester);

    expect(find.text('3'), findsOneWidget);
    expect(find.text('None overdue'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-attention-drafts')));
    await tester.pumpAndSettle();
    expect(find.text('documents /documents?status=draft'), findsOneWidget);
  });

  testWidgets('expiring quotes open the documents list filtered to quotes and proformas', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('home-attention-expiring')));
    await tester.pumpAndSettle();

    expect(find.text('documents /documents?types=quote,proforma'), findsOneWidget);
  });

  testWidgets('overdue invoices open receivables', (tester) async {
    when(() => dashboard.summary()).thenAnswer((_) async => _summary.copyWith(overdueInvoiceCount: 4));

    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('home-attention-overdue')));
    await tester.pumpAndSettle();

    expect(find.text('receivables screen'), findsOneWidget);
  });

  testWidgets('a recent document opens its detail', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('home-recent-d1')));
    await tester.pumpAndSettle();

    expect(find.text('document d1'), findsOneWidget);
  });

  testWidgets('a brand-new business sees first steps that lead somewhere', (tester) async {
    when(() => dashboard.summary()).thenAnswer(
      (_) async => _summary.copyWith(recentDocuments: [], customerCount: 0, draftCount: 0, expiringQuoteCount: 0),
    );

    await pumpHome(tester);

    expect(find.text('Start with your first customer'), findsOneWidget);
    expect(find.byKey(const Key('home-attention-drafts')), findsNothing);

    await tester.tap(find.byKey(const Key('home-first-customer')));
    await tester.pumpAndSettle();
    expect(find.text('new customer screen'), findsOneWidget);
  });

  testWidgets('a failing revenue section shows its own retry while the rest still renders', (tester) async {
    var failing = true;
    when(() => dashboard.revenue()).thenAnswer((_) async {
      if (failing) throw _error();
      return _revenue();
    });

    await pumpHome(tester);

    expect(find.text("Couldn't load your revenue"), findsOneWidget);
    expect(find.text('Recent documents'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('RWF 120,000'), findsOneWidget);
  });

  testWidgets('a failing activity section shows its own retry while revenue still renders', (tester) async {
    var failing = true;
    when(() => dashboard.summary()).thenAnswer((_) async {
      if (failing) throw _error();
      return _summary;
    });

    await pumpHome(tester);

    expect(find.text("Couldn't load your activity"), findsOneWidget);
    expect(find.text('RWF 120,000'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Recent documents'), findsOneWidget);
  });

  testWidgets('pulling down reloads both sections', (tester) async {
    await pumpHome(tester);
    clearInteractions(dashboard);

    await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    verify(() => dashboard.summary()).called(1);
    verify(() => dashboard.revenue()).called(1);
  });

  testWidgets('the bell shows the unread count and opens the inbox', (tester) async {
    when(() => notifications.list()).thenAnswer(
      (_) async => const NotificationsPage(results: [], unreadCount: 3),
    );

    await pumpHome(tester);

    expect(find.descendant(of: find.byKey(const Key('home-bell')), matching: find.text('3')), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-bell')));
    await tester.pumpAndSettle();
    expect(find.text('inbox screen'), findsOneWidget);
  });

  testWidgets('the bell shows no badge when nothing is unread', (tester) async {
    await pumpHome(tester);

    expect(find.descendant(of: find.byKey(const Key('home-bell')), matching: find.byType(Badge)), findsOneWidget);
    expect(tester.widget<Badge>(find.descendant(of: find.byKey(const Key('home-bell')), matching: find.byType(Badge))).isLabelVisible, isFalse);
  });

  testWidgets('search, account, and the business switcher open their screens', (tester) async {
    for (final (key, marker) in [
      ('home-search', 'search screen'),
      ('home-account', 'settings screen'),
      ('home-business-switcher', 'businesses screen'),
    ]) {
      await pumpHome(tester);
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();

      expect(find.text(marker), findsOneWidget, reason: key);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('shortcuts open their lists and the Team shortcut is owner-only', (tester) async {
    await pumpHome(tester);
    expect(find.byKey(const Key('home-nav-team')), findsNothing);
    await tester.tap(find.byKey(const Key('home-nav-customers')));
    await tester.pumpAndSettle();
    expect(find.text('customers screen'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await pumpHome(tester, owner: true);
    await tester.tap(find.byKey(const Key('home-nav-team')));
    await tester.pumpAndSettle();
    expect(find.text('team screen'), findsOneWidget);
  });
}

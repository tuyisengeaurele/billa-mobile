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
import 'package:billa_mobile/features/dashboard/presentation/widgets/home_header.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_page.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_repository.dart';
import 'package:billa_mobile/features/notifications/presentation/providers/notifications_repository_provider.dart';
import '../../../account/support.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

class _MockNotificationsRepository extends Mock implements NotificationsRepository {}

class _MockReceivablesRepository extends Mock implements ReceivablesRepository {}

class _MockDocumentRepository extends Mock implements DocumentRepository {}

const _outstanding = OutstandingInvoice(
  id: 'd1',
  number: 'INV-0001',
  customerName: 'Acme Ltd',
  total: 10000,
  amountOwed: 4000,
  dueDate: '2026-04-01',
  daysOverdue: 0,
  agingBucket: 'current',
);

const _document = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-0001',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: DocumentCustomerRef(name: 'Acme Ltd'),
  issueDate: '2026-03-01T00:00:00.000Z',
  subtotal: 10000,
  taxTotal: 0,
  total: 10000,
  amountPaid: 0,
  createdAt: '2026-03-01T00:00:00.000Z',
  updatedAt: '2026-03-01T00:00:00.000Z',
);

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
  late _MockReceivablesRepository receivables;
  late _MockDocumentRepository documents;
  var now = DateTime(2026, 3, 1, 9);

  setUp(() {
    dashboard = _MockDashboardRepository();
    notifications = _MockNotificationsRepository();
    receivables = _MockReceivablesRepository();
    documents = _MockDocumentRepository();
    now = DateTime(2026, 3, 1, 9);
    when(() => receivables.list()).thenAnswer((_) async => [_outstanding]);
    when(() => documents.get('d1')).thenAnswer((_) async => _document);
    when(() => dashboard.summary()).thenAnswer((_) async => _summary);
    when(() => dashboard.revenue()).thenAnswer((_) async => _revenue());
    when(() => notifications.list()).thenAnswer((_) async => const NotificationsPage(results: [], unreadCount: 0));
  });

  Widget buildApp({bool owner = false}) {
    Widget stub(String label) => Scaffold(body: Text(label));
    final router = GoRouter(routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/documents', builder: (context, state) => stub('documents ${state.uri}')),
      GoRoute(path: '/documents/new', builder: (context, state) => stub('new ${(state.extra as DocumentType).name}')),
      GoRoute(path: '/documents/:id/edit', builder: (context, state) => stub('editing ${state.pathParameters['id']}')),
      GoRoute(path: '/documents/:id', builder: (context, state) => stub('document ${state.pathParameters['id']}')),
      GoRoute(path: '/receivables', builder: (context, state) => stub('receivables screen')),
      GoRoute(
        path: '/documents/:id/payments/new',
        builder: (context, state) => stub('payment for ${(state.extra as Document).number}'),
      ),
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
        homeClockProvider.overrideWithValue(() => now),
        receivablesRepositoryProvider.overrideWithValue(receivables),
        documentRepositoryProvider.overrideWithValue(documents),
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

  testWidgets('search and the business switcher open their screens', (tester) async {
    for (final (key, marker) in [
      ('home-search', 'search screen'),
      ('home-business-switcher', 'businesses screen'),
    ]) {
      await pumpHome(tester);
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();

      expect(find.text(marker), findsOneWidget, reason: key);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('the hero actions start an invoice and a customer', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('home-action-invoice')));
    await tester.pumpAndSettle();
    expect(find.text('new invoice'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('home-action-customer')));
    await tester.pumpAndSettle();
    expect(find.text('new customer screen'), findsOneWidget);
  });

  testWidgets('the payment action asks which invoice, then opens the payment screen', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('home-action-payment')));
    await tester.pumpAndSettle();

    expect(find.text('Choose the invoice the customer is paying.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('payment-invoice-d1')));
    await tester.pumpAndSettle();

    expect(find.text('payment for INV-0001'), findsOneWidget);
  });

  testWidgets('the hero actions stay available while revenue fails to load', (tester) async {
    when(() => dashboard.revenue()).thenAnswer((_) async => throw _error());

    await pumpHome(tester);

    expect(find.byKey(const Key('home-action-invoice')), findsOneWidget);
    expect(find.text("Couldn't load your revenue"), findsOneWidget);
  });

  testWidgets('greets by time of day and first name', (tester) async {
    for (final (hour, greeting) in [(8, 'Good morning'), (13, 'Good afternoon'), (19, 'Good evening')]) {
      now = DateTime(2026, 3, 1, hour);
      await pumpHome(tester);

      expect(find.text('$greeting, Ada'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('the avatar shows initials and opens the profile tab', (tester) async {
    await pumpHome(tester);
    expect(find.text('A'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('settings screen'), findsOneWidget);
  });

  testWidgets('the newest draft is offered as Continue draft and opens the editor', (tester) async {
    when(() => dashboard.summary()).thenAnswer(
      (_) async => _summary.copyWith(recentDocuments: [
        const RecentDocument(
          id: 'd9',
          type: DocumentType.quote,
          number: null,
          status: DocumentStatus.draft,
          customerName: 'Beta Co',
          issueDate: '2026-03-02T00:00:00.000Z',
        ),
        ..._summary.recentDocuments,
      ]),
    );

    await pumpHome(tester);

    expect(find.byKey(const Key('home-continue-draft')), findsOneWidget);
    expect(find.text('Quote · Beta Co'), findsWidgets);
    await tester.tap(find.byKey(const Key('home-continue-draft')));
    await tester.pumpAndSettle();
    expect(find.text('editing d9'), findsOneWidget);
  });

  testWidgets('with no draft in the recent list there is no Continue draft card', (tester) async {
    await pumpHome(tester);

    expect(find.byKey(const Key('home-continue-draft')), findsNothing);
  });
}

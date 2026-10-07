import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/core/pagination/paginated_result.dart';
import 'package:billa_mobile/features/account/presentation/screens/settings_screen.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import 'package:billa_mobile/features/customers/domain/customer.dart';
import 'package:billa_mobile/features/customers/domain/customer_repository.dart';
import 'package:billa_mobile/features/customers/presentation/providers/customer_repository_provider.dart';
import 'package:billa_mobile/features/customers/presentation/screens/customer_list_screen.dart';
import 'package:billa_mobile/features/dashboard/domain/dashboard_repository.dart';
import 'package:billa_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:billa_mobile/features/dashboard/domain/revenue_summary.dart';
import 'package:billa_mobile/features/dashboard/presentation/providers/dashboard_repository_provider.dart';
import 'package:billa_mobile/features/dashboard/presentation/screens/home_screen.dart';
import 'package:billa_mobile/features/documents/domain/document.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/document_repository.dart';
import 'package:billa_mobile/features/documents/presentation/providers/document_repository_provider.dart';
import 'package:billa_mobile/features/documents/presentation/screens/document_list_screen.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_page.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_repository.dart';
import 'package:billa_mobile/features/notifications/presentation/providers/notifications_repository_provider.dart';
import 'package:billa_mobile/features/receivables/domain/outstanding_invoice.dart';
import 'package:billa_mobile/features/receivables/domain/receivables_repository.dart';
import 'package:billa_mobile/features/receivables/presentation/providers/receivables_repository_provider.dart';
import 'package:billa_mobile/features/receivables/presentation/screens/receivables_screen.dart';
import '../features/account/support.dart';
import '../support/tall_screen.dart';

class _MockDashboard extends Mock implements DashboardRepository {}

class _MockNotifications extends Mock implements NotificationsRepository {}

class _MockReceivables extends Mock implements ReceivablesRepository {}

class _MockCustomers extends Mock implements CustomerRepository {}

class _MockDocuments extends Mock implements DocumentRepository {}

const _document = Document(
  id: 'd1',
  type: DocumentType.invoice,
  number: 'INV-0001',
  status: DocumentStatus.finalized,
  customerId: 'c1',
  customer: DocumentCustomerRef(name: 'Acme Ltd'),
  issueDate: '2026-01-01T00:00:00.000Z',
  subtotal: 10000,
  taxTotal: 0,
  total: 10000,
  amountPaid: 0,
  paymentStatus: PaymentStatus.unpaid,
  createdAt: '2026-01-01T00:00:00.000Z',
  updatedAt: '2026-01-01T00:00:00.000Z',
);

void main() {
  Future<void> pump(WidgetTester tester, Widget screen, List<Override> overrides, {double textScale = 1}) async {
    useTallScreen(tester);
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (context, state) => screen)]);
    await tester.pumpWidget(ProviderScope(
      overrides: overrides,
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale), size: const Size(800, 2400)),
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    ));
    await tester.pumpAndSettle();
  }

  late _MockDashboard dashboard;
  late _MockNotifications notifications;
  late _MockReceivables receivables;
  late _MockCustomers customers;
  late _MockDocuments documents;

  setUp(() {
    dashboard = _MockDashboard();
    notifications = _MockNotifications();
    receivables = _MockReceivables();
    customers = _MockCustomers();
    documents = _MockDocuments();
    when(() => dashboard.summary()).thenAnswer(
      (_) async => const DashboardSummary(
        draftCount: 1,
        overdueInvoiceCount: 2,
        expiringQuoteCount: 0,
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
        documentsThisMonth: 1,
        documentsLastMonth: 1,
        customerCount: 1,
      ),
    );
    when(() => dashboard.revenue()).thenAnswer(
      (_) async => const RevenueSummary(
        invoicedThisMonth: 120000,
        invoicedLastMonth: 100000,
        invoicedYearToDate: 500000,
        creditedYearToDate: 0,
        netYearToDate: 500000,
        totalCollected: 300000,
        totalOutstanding: 180000,
        monthlyRevenue: [MonthlyRevenue(month: '2026-01', invoiced: 50000, credited: 0, net: 50000)],
        topCustomers: [],
      ),
    );
    when(() => notifications.list()).thenAnswer((_) async => const NotificationsPage(results: [], unreadCount: 0));
    when(() => receivables.list()).thenAnswer(
      (_) async => [
        const OutstandingInvoice(
          id: 'd1',
          number: 'INV-0001',
          customerName: 'Acme Ltd',
          total: 10000,
          amountOwed: 4000,
          dueDate: '2026-01-01',
          daysOverdue: 12,
          agingBucket: '0-30',
        ),
      ],
    );
    when(() => customers.list(search: null, includeInactive: false, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(
        results: [Customer(id: 'c1', name: 'Acme Ltd', phone: '0788123456', isActive: true, createdAt: '2026-01-01T00:00:00.000Z')],
        total: 1,
        page: 1,
        pageSize: 20,
      ),
    );
    when(() => documents.list(types: null, status: null, search: null, page: 1, pageSize: 20)).thenAnswer(
      (_) async => const PaginatedResult(results: [_document], total: 1, page: 1, pageSize: 20),
    );
  });

  List<Override> common() => [
        authControllerProvider.overrideWith(FakeAuthController.new),
        dashboardRepositoryProvider.overrideWithValue(dashboard),
        notificationsRepositoryProvider.overrideWithValue(notifications),
        receivablesRepositoryProvider.overrideWithValue(receivables),
        customerRepositoryProvider.overrideWithValue(customers),
        documentRepositoryProvider.overrideWithValue(documents),
      ];

  final screens = <String, Widget>{
    'Home': const HomeScreen(),
    'Profile': const SettingsScreen(),
    'Payments': const ReceivablesScreen(),
    'Customers': const CustomerListScreen(),
    'Documents': const DocumentListScreen(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key}: every tap target is at least 48 by 48', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, entry.value, common());

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('${entry.key}: every tap target has a label', (tester) async {
      final handle = tester.ensureSemantics();
      await pump(tester, entry.value, common());

      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('${entry.key}: nothing overflows at a large system font size', (tester) async {
      await pump(tester, entry.value, common(), textScale: 1.6);

      // A layout overflow is reported by the framework as a test failure.
    });
  }
}

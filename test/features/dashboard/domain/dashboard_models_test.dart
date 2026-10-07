import 'package:flutter_test/flutter_test.dart';
import 'package:billa_mobile/features/dashboard/domain/dashboard_summary.dart';
import 'package:billa_mobile/features/dashboard/domain/revenue_summary.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

Map<String, dynamic> _summaryJson({List<Map<String, dynamic>> recent = const [], int customers = 0}) => {
      'draftCount': 2,
      'overdueInvoiceCount': 1,
      'expiringQuoteCount': 0,
      'recentDocuments': recent,
      'documentsThisMonth': 5,
      'documentsLastMonth': 3,
      'documentsByType': [],
      'activityByDay': [],
      'customerCount': customers,
      'hasLogo': true,
    };

Map<String, dynamic> _revenueJson({int thisMonth = 120000, int lastMonth = 100000}) => {
      'invoicedThisMonth': thisMonth,
      'invoicedLastMonth': lastMonth,
      'invoicedYearToDate': 500000,
      'creditedYearToDate': 20000,
      'netYearToDate': 480000,
      'totalCollected': 300000,
      'totalOutstanding': 180000,
      'daysSalesOutstanding': null,
      'monthlyRevenue': [
        {'month': '2026-02', 'invoiced': 100000, 'credited': 0, 'net': 100000},
      ],
      'topCustomers': [
        {'customerId': 'c1', 'name': 'Acme', 'total': 90000},
      ],
      'topItems': [],
    };

void main() {
  test('DashboardSummary.fromJson parses counts and recent documents with nullable fields', () {
    final summary = DashboardSummary.fromJson(_summaryJson(recent: [
      {
        'id': 'd1',
        'type': 'INVOICE',
        'number': null,
        'status': 'DRAFT',
        'customerName': 'Acme',
        'issueDate': '2026-03-01T00:00:00.000Z',
        'paymentStatus': null,
      },
      {
        'id': 'd2',
        'type': 'DELIVERY_NOTE',
        'number': 'DN-1',
        'status': 'FINALIZED',
        'customerName': 'Sam',
        'issueDate': '2026-03-02T00:00:00.000Z',
        'paymentStatus': 'PARTIALLY_PAID',
      },
    ]));

    expect(summary.draftCount, 2);
    expect(summary.recentDocuments.first.number, isNull);
    expect(summary.recentDocuments.last.type, DocumentType.deliveryNote);
    expect(summary.recentDocuments.last.paymentStatus, PaymentStatus.partiallyPaid);
  });

  test('isEmptyBusiness is true only with no documents and no customers', () {
    expect(DashboardSummary.fromJson(_summaryJson()).isEmptyBusiness, isTrue);
    expect(DashboardSummary.fromJson(_summaryJson(customers: 1)).isEmptyBusiness, isFalse);
  });

  test('RevenueSummary.fromJson parses a nullable days-sales-outstanding and the lists', () {
    final revenue = RevenueSummary.fromJson(_revenueJson());

    expect(revenue.daysSalesOutstanding, isNull);
    expect(revenue.monthlyRevenue.single.month, '2026-02');
    expect(revenue.topCustomers.single.name, 'Acme');
  });

  test('monthOverMonthPercent is signed and rounded, and null without a last month', () {
    expect(RevenueSummary.fromJson(_revenueJson()).monthOverMonthPercent, 20);
    expect(RevenueSummary.fromJson(_revenueJson(thisMonth: 80000)).monthOverMonthPercent, -20);
    expect(RevenueSummary.fromJson(_revenueJson(lastMonth: 0)).monthOverMonthPercent, isNull);
  });
}

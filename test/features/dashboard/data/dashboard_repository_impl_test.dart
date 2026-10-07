import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/dashboard/data/dashboard_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _ok(Map<String, dynamic> data, String path) =>
    Response(statusCode: 200, data: data, requestOptions: RequestOptions(path: path));

void main() {
  late _MockDio dio;
  late DashboardRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = DashboardRepositoryImpl(dio);
  });

  test('summary reads /dashboard/summary', () async {
    when(() => dio.get<Map<String, dynamic>>('/dashboard/summary')).thenAnswer(
      (_) async => _ok({
        'draftCount': 1,
        'overdueInvoiceCount': 0,
        'expiringQuoteCount': 2,
        'recentDocuments': [],
        'documentsThisMonth': 0,
        'documentsLastMonth': 0,
        'customerCount': 4,
        'hasLogo': false,
      }, '/dashboard/summary'),
    );

    final summary = await repository.summary();

    expect(summary.expiringQuoteCount, 2);
    expect(summary.customerCount, 4);
  });

  test('revenue reads /dashboard/revenue', () async {
    when(() => dio.get<Map<String, dynamic>>('/dashboard/revenue')).thenAnswer(
      (_) async => _ok({
        'invoicedThisMonth': 10,
        'invoicedLastMonth': 5,
        'invoicedYearToDate': 50,
        'creditedYearToDate': 0,
        'netYearToDate': 50,
        'totalCollected': 20,
        'totalOutstanding': 30,
        'daysSalesOutstanding': 12,
        'monthlyRevenue': [],
        'topCustomers': [],
      }, '/dashboard/revenue'),
    );

    final revenue = await repository.revenue();

    expect(revenue.totalOutstanding, 30);
    expect(revenue.daysSalesOutstanding, 12);
  });
}

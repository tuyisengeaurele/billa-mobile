import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/documents/data/document_repository_impl.dart';
import 'package:billa_mobile/features/documents/domain/document_draft_input.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import 'package:billa_mobile/features/documents/domain/payment_input.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _response(int statusCode, Map<String, dynamic> data, RequestOptions options) {
  return Response(statusCode: statusCode, data: data, requestOptions: options);
}

Map<String, dynamic> _documentJson() => {
      'id': 'd1',
      'type': 'INVOICE',
      'number': 'INV-0001',
      'status': 'FINALIZED',
      'customerId': 'c1',
      'customer': {'name': 'Acme', 'email': null},
      'issueDate': '2026-01-01T00:00:00.000Z',
      'dueDate': null,
      'notes': null,
      'customerReference': null,
      'subtotal': 10000,
      'taxTotal': 1800,
      'total': 11800,
      'sentAt': null,
      'amountPaid': 0,
      'paymentStatus': null,
      'writtenOffAt': null,
      'writeOffReason': null,
      'createdAt': '2026-01-01T00:00:00.000Z',
      'updatedAt': '2026-01-01T00:00:00.000Z',
      'convertedFromId': null,
      'referencedDocumentId': null,
    };

void main() {
  late _MockDio dio;
  late DocumentRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = DocumentRepositoryImpl(dio);
  });

  test('list joins multiple types with a comma and maps results', () async {
    final options = RequestOptions(path: '/documents');
    when(() => dio.get<Map<String, dynamic>>('/documents', queryParameters: {
          'type': 'INVOICE,PROFORMA',
          'status': 'DRAFT',
          'search': 'acme',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {
          'results': [_documentJson()],
          'total': 1,
          'page': 1,
          'pageSize': 20,
        }, options));

    final result = await repository.list(
      types: [DocumentType.invoice, DocumentType.proforma],
      status: DocumentStatus.draft,
      search: 'acme',
    );

    expect(result.results.single.id, 'd1');
  });

  test('list omits type/status/search when not provided', () async {
    final options = RequestOptions(path: '/documents');
    when(() => dio.get<Map<String, dynamic>>('/documents', queryParameters: {
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {'results': [], 'total': 0, 'page': 1, 'pageSize': 20}, options));

    final result = await repository.list();

    expect(result.results, isEmpty);
  });

  test('get fetches and unwraps the document envelope', () async {
    final options = RequestOptions(path: '/documents/d1');
    when(() => dio.get<Map<String, dynamic>>('/documents/d1')).thenAnswer(
      (_) async => _response(200, {'document': _documentJson()}, options),
    );

    final document = await repository.get('d1');

    expect(document.id, 'd1');
  });

  test('list includes a customerId filter when provided', () async {
    final options = RequestOptions(path: '/documents');
    when(() => dio.get<Map<String, dynamic>>('/documents', queryParameters: {
          'customerId': 'c1',
          'page': 1,
          'pageSize': 20,
        })).thenAnswer((_) async => _response(200, {'results': [], 'total': 0, 'page': 1, 'pageSize': 20}, options));

    final result = await repository.list(customerId: 'c1');

    expect(result.results, isEmpty);
  });

  test('create posts the draft and returns the created document', () async {
    final options = RequestOptions(path: '/documents');
    const input = DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-08-19',
      lines: [],
    );
    when(() => dio.post<Map<String, dynamic>>('/documents', data: input.toJson())).thenAnswer(
      (_) async => _response(201, {'document': _documentJson()}, options),
    );

    final document = await repository.create(input);

    expect(document.id, 'd1');
  });

  test('update patches the draft and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1');
    const input = DocumentDraftInput(
      type: DocumentType.invoice,
      customerId: 'c1',
      issueDate: '2026-08-20',
      lines: [],
    );
    when(() => dio.patch<Map<String, dynamic>>('/documents/d1', data: input.toJson())).thenAnswer(
      (_) async => _response(200, {'document': _documentJson()}, options),
    );

    final document = await repository.update('d1', input);

    expect(document.id, 'd1');
  });

  test('finalize posts to /finalize and returns the finalized document', () async {
    final options = RequestOptions(path: '/documents/d1/finalize');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/finalize')).thenAnswer(
      (_) async => _response(200, {'document': _documentJson()}, options),
    );

    final document = await repository.finalize('d1');

    expect(document.id, 'd1');
  });

  test('convert posts to /convert and returns the new invoice', () async {
    final options = RequestOptions(path: '/documents/d1/convert');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/convert')).thenAnswer(
      (_) async => _response(201, {'document': _documentJson()}, options),
    );

    final document = await repository.convert('d1');

    expect(document.id, 'd1');
  });

  test('send posts to /send and returns the sentAt timestamp', () async {
    final options = RequestOptions(path: '/documents/d1/send');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/send')).thenAnswer(
      (_) async => _response(200, {'sentAt': '2026-01-02T00:00:00.000Z'}, options),
    );

    final sentAt = await repository.send('d1');

    expect(sentAt, '2026-01-02T00:00:00.000Z');
  });

  test('delete sends a DELETE request', () async {
    final options = RequestOptions(path: '/documents/d1');
    when(() => dio.delete<void>('/documents/d1')).thenAnswer(
      (_) async => Response(statusCode: 204, requestOptions: options),
    );

    await repository.delete('d1');

    verify(() => dio.delete<void>('/documents/d1')).called(1);
  });

  test('fetchPdfBytes requests bytes and returns the raw response', () async {
    final options = RequestOptions(path: '/documents/d1/pdf');
    when(() => dio.get<List<int>>('/documents/d1/pdf', options: any(named: 'options'))).thenAnswer(
      (_) async => Response(statusCode: 200, data: [1, 2, 3], requestOptions: options),
    );

    final bytes = await repository.fetchPdfBytes('d1');

    expect(bytes, [1, 2, 3]);
  });

  test('recordPayment posts to /payments and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1/payments');
    const input = PaymentInput(amount: 5000, method: PaymentMethod.cash, paidOn: '2026-01-05');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/payments', data: input.toJson())).thenAnswer(
      (_) async => _response(201, {
        'payment': {'id': 'pay1'},
        'document': _documentJson(),
      }, options),
    );

    final document = await repository.recordPayment('d1', input);

    expect(document.id, 'd1');
  });

  test('voidPayment posts the void reason and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1/payments/pay1/void');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/payments/pay1/void', data: {'voidReason': 'Mistake'}))
        .thenAnswer((_) async => _response(200, {'document': _documentJson()}, options));

    final document = await repository.voidPayment('d1', 'pay1', 'Mistake');

    expect(document.id, 'd1');
  });

  test('listPayments fetches and maps the payments list', () async {
    final options = RequestOptions(path: '/documents/d1/payments');
    when(() => dio.get<Map<String, dynamic>>('/documents/d1/payments')).thenAnswer(
      (_) async => _response(200, {
        'payments': [
          {
            'id': 'pay1',
            'amount': 5000,
            'method': 'CASH',
            'paidOn': '2026-01-05T00:00:00.000Z',
            'notes': null,
            'referenceNumber': null,
            'payerName': null,
            'receiptImageUrl': null,
            'receiptDocumentId': null,
            'voidedAt': null,
            'voidReason': null,
            'createdAt': '2026-01-05T00:00:00.000Z',
          },
        ],
      }, options),
    );

    final payments = await repository.listPayments('d1');

    expect(payments.single.id, 'pay1');
  });

  test('writeOff posts the reason and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1/write-off');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/write-off', data: {'writeOffReason': 'Bad debt'}))
        .thenAnswer((_) async => _response(200, {'document': _documentJson()}, options));

    final document = await repository.writeOff('d1', 'Bad debt');

    expect(document.id, 'd1');
  });

  test('reactivate posts to /reactivate and returns the updated document', () async {
    final options = RequestOptions(path: '/documents/d1/reactivate');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/reactivate')).thenAnswer(
      (_) async => _response(200, {'document': _documentJson()}, options),
    );

    final document = await repository.reactivate('d1');

    expect(document.id, 'd1');
  });

  test('uploadPaymentReceipt posts multipart form data and returns the url', () async {
    final options = RequestOptions(path: '/documents/payments/receipt');
    when(() => dio.post<Map<String, dynamic>>('/documents/payments/receipt', data: any(named: 'data'))).thenAnswer(
      (_) async => _response(201, {'url': '/uploads/b1/receipt.png'}, options),
    );

    final url = await repository.uploadPaymentReceipt([1, 2, 3], 'receipt.png');

    expect(url, '/uploads/b1/receipt.png');
  });

  test('send with a language posts it in the body', () async {
    final options = RequestOptions(path: '/documents/d1/send');
    when(() => dio.post<Map<String, dynamic>>('/documents/d1/send', data: {'language': 'FR'})).thenAnswer(
      (_) async => _response(200, {'sentAt': '2026-01-02T00:00:00.000Z'}, options),
    );

    final sentAt = await repository.send('d1', language: DocumentLanguage.fr);

    expect(sentAt, '2026-01-02T00:00:00.000Z');
    verify(() => dio.post<Map<String, dynamic>>('/documents/d1/send', data: {'language': 'FR'})).called(1);
  });

  test('fetchPdfBytes with a language asks for it in the query string', () async {
    final options = RequestOptions(path: '/documents/d1/pdf');
    when(
      () => dio.get<List<int>>(
        '/documents/d1/pdf',
        queryParameters: {'language': 'FR'},
        options: any(named: 'options'),
      ),
    ).thenAnswer((_) async => Response(statusCode: 200, data: [9, 9], requestOptions: options));

    final bytes = await repository.fetchPdfBytes('d1', language: DocumentLanguage.fr);

    expect(bytes, [9, 9]);
  });
}

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/business_settings/data/business_settings_repository_impl.dart';
import 'package:billa_mobile/features/business_settings/domain/document_sequence.dart';
import 'package:billa_mobile/features/business_settings/domain/document_template.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';

class _MockDio extends Mock implements Dio {}

Response<Map<String, dynamic>> _ok(Map<String, dynamic> data, String path) =>
    Response(statusCode: 200, data: data, requestOptions: RequestOptions(path: path));

Map<String, dynamic> _business([Map<String, dynamic> extra = const {}]) => {
      'business': {'id': 'b1', 'name': 'Acme', ...extra},
    };

void main() {
  late _MockDio dio;
  late BusinessSettingsRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = BusinessSettingsRepositoryImpl(dio);
  });

  test('get parses the business', () async {
    when(() => dio.get<Map<String, dynamic>>('/business')).thenAnswer((_) async => _ok(_business({'tin': '1'}), '/business'));

    final settings = await repository.get();

    expect(settings.tin, '1');
  });

  test('updateDetails sends every field, with null for a cleared one', () async {
    final expected = {
      'name': 'Acme',
      'tin': null,
      'industry': 'Retail',
      'phone': null,
      'email': 'a@b.com',
      'address': null,
      'rraEbmNumber': null,
    };
    when(() => dio.patch<Map<String, dynamic>>('/business', data: expected))
        .thenAnswer((_) async => _ok(_business({'industry': 'Retail'}), '/business'));

    final settings = await repository.updateDetails(name: 'Acme', industry: 'Retail', email: 'a@b.com');

    expect(settings.industry, 'Retail');
    verify(() => dio.patch<Map<String, dynamic>>('/business', data: expected)).called(1);
  });

  test('updatePayments sends its four fields', () async {
    final expected = {'bankName': 'BK', 'bankAccountNumber': null, 'signatoryName': 'Ada', 'signatoryTitle': null};
    when(() => dio.patch<Map<String, dynamic>>('/business', data: expected))
        .thenAnswer((_) async => _ok(_business({'bankName': 'BK'}), '/business'));

    await repository.updatePayments(bankName: 'BK', signatoryName: 'Ada');

    verify(() => dio.patch<Map<String, dynamic>>('/business', data: expected)).called(1);
  });

  test('updateDocumentSettings sends the template in uppercase', () async {
    final expected = {
      'defaultTemplate': 'CLASSIC',
      'requireApprovalToFinalize': true,
      'remindersEnabled': false,
      'reminderCadenceDays': 14,
    };
    when(() => dio.patch<Map<String, dynamic>>('/business', data: expected))
        .thenAnswer((_) async => _ok(_business(), '/business'));

    await repository.updateDocumentSettings(
      defaultTemplate: DocumentTemplate.classic,
      requireApprovalToFinalize: true,
      remindersEnabled: false,
      reminderCadenceDays: 14,
    );

    verify(() => dio.patch<Map<String, dynamic>>('/business', data: expected)).called(1);
  });

  test('setDefaultTemplate sends only the template, in uppercase', () async {
    when(() => dio.patch<Map<String, dynamic>>('/business', data: {'defaultTemplate': 'PREMIUM'}))
        .thenAnswer((_) async => _ok(_business({'defaultTemplate': 'PREMIUM'}), '/business'));

    final settings = await repository.setDefaultTemplate(DocumentTemplate.premium);

    expect(settings.defaultTemplate, DocumentTemplate.premium);
    verify(() => dio.patch<Map<String, dynamic>>('/business', data: {'defaultTemplate': 'PREMIUM'})).called(1);
  });

  test('uploadSignature posts multipart data and returns the url', () async {
    when(() => dio.post<Map<String, dynamic>>('/business/signature', data: any(named: 'data')))
        .thenAnswer((_) async => _ok({'url': '/uploads/sig.png'}, '/business/signature'));

    final url = await repository.uploadSignature([1, 2], 'sig.png');

    expect(url, '/uploads/sig.png');
    final sent = verify(() => dio.post<Map<String, dynamic>>('/business/signature', data: captureAny(named: 'data')))
        .captured
        .single as FormData;
    expect(sent.files.single.key, 'signature');
  });

  test('setSignature(null) clears it', () async {
    when(() => dio.patch<Map<String, dynamic>>('/business', data: {'signatureUrl': null}))
        .thenAnswer((_) async => _ok(_business(), '/business'));

    final settings = await repository.setSignature(null);

    expect(settings.signatureUrl, isNull);
    verify(() => dio.patch<Map<String, dynamic>>('/business', data: {'signatureUrl': null})).called(1);
  });

  test('sequences parses all types', () async {
    when(() => dio.get<Map<String, dynamic>>('/business/sequences')).thenAnswer(
      (_) async => _ok({
        'sequences': [
          {'type': 'INVOICE', 'prefix': 'INV-', 'nextNumber': 1, 'resetYearly': false},
          {'type': 'DELIVERY_NOTE', 'prefix': 'DN-', 'nextNumber': 4, 'resetYearly': true},
        ],
      }, '/business/sequences'),
    );

    final sequences = await repository.sequences();

    expect(sequences.map((s) => s.type), [DocumentType.invoice, DocumentType.deliveryNote]);
  });

  test('saveSequences PUTs the list with wire type names', () async {
    final expected = [
      {'type': 'INVOICE', 'prefix': 'A-', 'nextNumber': 9, 'resetYearly': true},
    ];
    when(() => dio.put<Map<String, dynamic>>('/business/sequences', data: expected)).thenAnswer(
      (_) async => _ok({'sequences': expected}, '/business/sequences'),
    );

    final saved = await repository.saveSequences(
      [const DocumentSequence(type: DocumentType.invoice, prefix: 'A-', nextNumber: 9, resetYearly: true)],
    );

    expect(saved.single.nextNumber, 9);
    verify(() => dio.put<Map<String, dynamic>>('/business/sequences', data: expected)).called(1);
  });

  test('subscription reads the billing status', () async {
    when(() => dio.get<Map<String, dynamic>>('/billing/status')).thenAnswer(
      (_) async => _ok({
        'plan': 'MONTHLY',
        'trialEndsAt': null,
        'currentPeriodEnd': '2026-04-01T00:00:00.000Z',
        'activeUntil': '2026-04-01T00:00:00.000Z',
      }, '/billing/status'),
    );

    final status = await repository.subscription();

    expect(status.isPaid, isTrue);
    expect(status.plan, 'MONTHLY');
  });
}

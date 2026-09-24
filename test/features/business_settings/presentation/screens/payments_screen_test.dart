import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/core/media/image_picker_provider.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';
import 'package:billa_mobile/features/business_settings/presentation/screens/payments_screen.dart';
import '../../support.dart';

class _MockBusinessSettingsRepository extends Mock implements BusinessSettingsRepository {}

void main() {
  late _MockBusinessSettingsRepository repository;
  PickedImage? picked;
  BusinessSettings loaded = const BusinessSettings(id: 'b1', name: 'Acme', bankName: 'BK');

  setUpAll(() => registerFallbackValue(<int>[]));

  setUp(() {
    repository = _MockBusinessSettingsRepository();
    loaded = const BusinessSettings(id: 'b1', name: 'Acme', bankName: 'BK');
    picked = (bytes: [1, 2], name: 'sig.png');
    when(() => repository.get()).thenAnswer((_) async => loaded);
  });

  Widget buildApp() => businessSettingsApp(
        screen: const PaymentsScreen(),
        path: '/settings/business/payments',
        overrides: [
          businessSettingsRepositoryProvider.overrideWithValue(repository),
          imagePickerProvider.overrideWithValue(() async => picked),
        ],
      );

  testWidgets('saves the four fields with cleared ones as null', (tester) async {
    when(
      () => repository.updatePayments(
        bankName: 'BK',
        bankAccountNumber: '0011',
        signatoryName: null,
        signatoryTitle: null,
      ),
    ).thenAnswer((_) async => loaded);

    await pumpSettings(tester, buildApp());
    await tester.enterText(find.byKey(const Key('pay-account')), ' 0011 ');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('pay-save')));
    await tester.pumpAndSettle();

    verify(
      () => repository.updatePayments(
        bankName: 'BK',
        bankAccountNumber: '0011',
        signatoryName: null,
        signatoryTitle: null,
      ),
    ).called(1);
    expect(find.text('Payment details saved'), findsOneWidget);
  });

  testWidgets('adding a signature uploads it then stores the url', (tester) async {
    when(() => repository.uploadSignature([1, 2], 'sig.png')).thenAnswer((_) async => '/uploads/sig.png');
    when(() => repository.setSignature('/uploads/sig.png')).thenAnswer((_) async => loaded);

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('pay-signature-change')));
    await tester.pumpAndSettle();

    verify(() => repository.uploadSignature([1, 2], 'sig.png')).called(1);
    verify(() => repository.setSignature('/uploads/sig.png')).called(1);
  });

  testWidgets('backing out of the picker changes nothing', (tester) async {
    picked = null;

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('pay-signature-change')));
    await tester.pumpAndSettle();

    verifyNever(() => repository.uploadSignature(any(), any()));
  });

  testWidgets('a rejected signature image shows its message with a retry', (tester) async {
    when(() => repository.uploadSignature([1, 2], 'sig.png')).thenAnswer((_) async => throw apiError('invalid_file_type'));

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('pay-signature-change')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a PNG, JPG, or WebP image'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('removing the signature clears it', (tester) async {
    loaded = const BusinessSettings(id: 'b1', name: 'Acme', signatureUrl: '/uploads/old.png');
    when(() => repository.setSignature(null)).thenAnswer((_) async => loaded);

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('pay-signature-remove')));
    await tester.pumpAndSettle();

    verify(() => repository.setSignature(null)).called(1);
  });
}

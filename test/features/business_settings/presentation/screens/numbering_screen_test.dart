import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/domain/document_sequence.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';
import 'package:billa_mobile/features/business_settings/presentation/screens/numbering_screen.dart';
import 'package:billa_mobile/features/documents/domain/document_enums.dart';
import '../../support.dart';

class _MockBusinessSettingsRepository extends Mock implements BusinessSettingsRepository {}

const _defaults = [
  DocumentSequence(type: DocumentType.invoice, prefix: 'INV-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.proforma, prefix: 'PRO-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.deliveryNote, prefix: 'DN-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.quote, prefix: 'QTE-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.receipt, prefix: 'RCT-', nextNumber: 1, resetYearly: false),
  DocumentSequence(type: DocumentType.creditNote, prefix: 'CN-', nextNumber: 1, resetYearly: false),
];

void main() {
  late _MockBusinessSettingsRepository repository;

  setUp(() {
    repository = _MockBusinessSettingsRepository();
    when(() => repository.sequences()).thenAnswer((_) async => _defaults);
  });

  Widget buildApp() => businessSettingsApp(
        screen: const NumberingScreen(),
        path: '/settings/business/numbering',
        overrides: [businessSettingsRepositoryProvider.overrideWithValue(repository)],
      );

  bool saveEnabled(WidgetTester tester) => tester.widget<FilledButton>(find.byKey(const Key('num-save'))).onPressed != null;

  testWidgets('shows a card for each of the six document types', (tester) async {
    await pumpSettings(tester, buildApp());

    for (final type in DocumentType.values) {
      expect(find.byKey(Key('num-prefix-${documentTypeToJson(type)}')), findsOneWidget);
    }
  });

  testWidgets('saves all six sequences with the edit applied', (tester) async {
    final expected = [
      _defaults[0].copyWith(prefix: 'A-', nextNumber: 9, resetYearly: true),
      ..._defaults.skip(1),
    ];
    when(() => repository.saveSequences(expected)).thenAnswer((_) async => expected);

    await pumpSettings(tester, buildApp());
    await tester.enterText(find.byKey(const Key('num-prefix-INVOICE')), 'A-');
    await tester.enterText(find.byKey(const Key('num-next-INVOICE')), '9');
    await tester.tap(find.byKey(const Key('num-yearly-INVOICE')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('num-save')));
    await tester.pumpAndSettle();

    verify(() => repository.saveSequences(expected)).called(1);
    expect(find.text('Numbering saved'), findsOneWidget);
  });

  testWidgets('a blank prefix blocks Save and says why', (tester) async {
    await pumpSettings(tester, buildApp());
    await tester.enterText(find.byKey(const Key('num-prefix-QUOTE')), '  ');
    await tester.pumpAndSettle();

    expect(find.text('Enter a prefix'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('a prefix over ten characters blocks Save and says why', (tester) async {
    await pumpSettings(tester, buildApp());
    await tester.enterText(find.byKey(const Key('num-prefix-QUOTE')), 'ABCDEFGHIJK');
    await tester.pumpAndSettle();

    expect(find.text('At most 10 characters'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('a next number below one blocks Save and says why', (tester) async {
    await pumpSettings(tester, buildApp());
    await tester.enterText(find.byKey(const Key('num-next-RECEIPT')), '0');
    await tester.pumpAndSettle();

    expect(find.text('At least 1'), findsOneWidget);
    expect(saveEnabled(tester), isFalse);
  });

  testWidgets('a failed save shows its message with a retry', (tester) async {
    when(() => repository.saveSequences(_defaults)).thenAnswer((_) async => throw apiError('not_owner'));

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('num-save')));
    await tester.pumpAndSettle();

    expect(find.text('Only the business owner can change this'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    when(() => repository.sequences()).thenAnswer((_) async => throw apiError('server_error'));

    await pumpSettings(tester, buildApp());

    expect(find.text('Retry'), findsOneWidget);
  });
}

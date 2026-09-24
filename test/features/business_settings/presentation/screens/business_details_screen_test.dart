import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/auth/presentation/providers/active_business_provider.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';
import 'package:billa_mobile/features/business_settings/presentation/screens/business_details_screen.dart';
import '../../support.dart';

class _MockBusinessSettingsRepository extends Mock implements BusinessSettingsRepository {}

void main() {
  late _MockBusinessSettingsRepository repository;

  setUp(() {
    repository = _MockBusinessSettingsRepository();
    when(() => repository.get()).thenAnswer(
      (_) async => const BusinessSettings(id: 'b1', name: 'Acme', tin: '123', industry: 'Retail'),
    );
  });

  Widget buildApp() => businessSettingsApp(
        screen: const BusinessDetailsScreen(),
        path: '/settings/business/details',
        overrides: [businessSettingsRepositoryProvider.overrideWithValue(repository)],
      );

  String fieldText(WidgetTester tester, String key) =>
      tester.widget<TextField>(find.byKey(Key(key))).controller!.text;

  testWidgets('seeds the form from the loaded settings', (tester) async {
    await pumpSettings(tester, buildApp());

    expect(fieldText(tester, 'bd-name'), 'Acme');
    expect(fieldText(tester, 'bd-tin'), '123');
    expect(fieldText(tester, 'bd-phone'), '');
  });

  testWidgets('saves trimmed values, sends cleared fields as null, and reloads', (tester) async {
    when(
      () => repository.updateDetails(
        name: 'Acme Ltd',
        tin: null,
        industry: 'Retail',
        phone: '0788',
        email: null,
        address: null,
        rraEbmNumber: null,
      ),
    ).thenAnswer((_) async => const BusinessSettings(id: 'b1', name: 'Acme Ltd'));

    await pumpSettings(tester, buildApp());
    await tester.enterText(find.byKey(const Key('bd-name')), '  Acme Ltd ');
    await tester.enterText(find.byKey(const Key('bd-tin')), '');
    await tester.enterText(find.byKey(const Key('bd-phone')), '0788');
    await tester.pumpAndSettle();
    clearInteractions(repository);
    await tester.tap(find.byKey(const Key('bd-save')));
    await tester.pumpAndSettle();

    verify(
      () => repository.updateDetails(
        name: 'Acme Ltd',
        tin: null,
        industry: 'Retail',
        phone: '0788',
        email: null,
        address: null,
        rraEbmNumber: null,
      ),
    ).called(1);
    verify(() => repository.get()).called(1);
    expect(find.text('Business details saved'), findsOneWidget);
  });

  testWidgets('a rename is written back to the signed-in business', (tester) async {
    when(
      () => repository.updateDetails(
        name: 'Renamed',
        tin: '123',
        industry: 'Retail',
        phone: null,
        email: null,
        address: null,
        rraEbmNumber: null,
      ),
    ).thenAnswer((_) async => const BusinessSettings(id: 'b1', name: 'Renamed'));

    await pumpSettings(tester, buildApp());
    final container = ProviderScope.containerOf(tester.element(find.byType(BusinessDetailsScreen)));
    await tester.enterText(find.byKey(const Key('bd-name')), 'Renamed');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bd-save')));
    await tester.pumpAndSettle();

    expect(container.read(currentBusinessProvider)!.name, 'Renamed');
  });

  testWidgets('a blank name disables Save', (tester) async {
    await pumpSettings(tester, buildApp());
    await tester.enterText(find.byKey(const Key('bd-name')), '  ');
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(find.byKey(const Key('bd-save'))).onPressed, isNull);
  });

  testWidgets('an invalid email blocks Save and says why', (tester) async {
    await pumpSettings(tester, buildApp());
    await tester.enterText(find.byKey(const Key('bd-email')), 'not-an-email');
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(const Key('bd-save'))).onPressed, isNull);
  });

  testWidgets('a not-owner rejection shows its message with a retry', (tester) async {
    when(
      () => repository.updateDetails(
        name: 'Acme',
        tin: '123',
        industry: 'Retail',
        phone: null,
        email: null,
        address: null,
        rraEbmNumber: null,
      ),
    ).thenAnswer((_) async => throw apiError('not_owner'));

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('bd-save')));
    await tester.pumpAndSettle();

    expect(find.text('Only the business owner can change this'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    when(() => repository.get()).thenAnswer((_) async => throw apiError('server_error'));

    await pumpSettings(tester, buildApp());

    expect(find.text('Retry'), findsOneWidget);
  });
}

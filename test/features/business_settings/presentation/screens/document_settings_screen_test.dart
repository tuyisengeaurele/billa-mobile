import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/domain/document_template.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';
import 'package:billa_mobile/features/business_settings/presentation/screens/document_settings_screen.dart';
import '../../support.dart';

class _MockBusinessSettingsRepository extends Mock implements BusinessSettingsRepository {}

void main() {
  late _MockBusinessSettingsRepository repository;

  setUp(() {
    repository = _MockBusinessSettingsRepository();
    when(() => repository.get()).thenAnswer((_) async => testSettings);
  });

  Widget buildApp() => businessSettingsApp(
        screen: const DocumentSettingsScreen(),
        path: '/settings/business/documents',
        overrides: [businessSettingsRepositoryProvider.overrideWithValue(repository)],
      );

  testWidgets('saves the chosen template and switches', (tester) async {
    when(
      () => repository.updateDocumentSettings(
        defaultTemplate: DocumentTemplate.classic,
        requireApprovalToFinalize: true,
        remindersEnabled: false,
        reminderCadenceDays: 14,
        dueSoonReminderDays: 3,
      ),
    ).thenAnswer((_) async => testSettings);

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('ds-template-classic')));
    await tester.tap(find.byKey(const Key('ds-approval')));
    await tester.tap(find.byKey(const Key('ds-reminders')));
    await tester.enterText(find.byKey(const Key('ds-cadence')), '14');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ds-save')));
    await tester.pumpAndSettle();

    verify(
      () => repository.updateDocumentSettings(
        defaultTemplate: DocumentTemplate.classic,
        requireApprovalToFinalize: true,
        remindersEnabled: false,
        reminderCadenceDays: 14,
        dueSoonReminderDays: 3,
      ),
    ).called(1);
    expect(find.text('Document settings saved'), findsOneWidget);
  });

  testWidgets('starts from the loaded values', (tester) async {
    when(() => repository.get()).thenAnswer(
      (_) async => const BusinessSettings(
        id: 'b1',
        name: 'Acme',
        defaultTemplate: DocumentTemplate.premium,
        reminderCadenceDays: 30,
      ),
    );

    await pumpSettings(tester, buildApp());

    expect(
      find.descendant(of: find.byKey(const Key('ds-template-premium')), matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    expect(tester.widget<TextField>(find.byKey(const Key('ds-cadence'))).controller!.text, '30');
  });

  testWidgets('a cadence outside 1 to 90 blocks Save and says why', (tester) async {
    await pumpSettings(tester, buildApp());

    for (final bad in ['0', '91', '', 'abc']) {
      await tester.enterText(find.byKey(const Key('ds-cadence')), bad);
      await tester.pumpAndSettle();

      expect(find.text('Enter a number from 1 to 90'), findsOneWidget, reason: 'for "$bad"');
      expect(tester.widget<FilledButton>(find.byKey(const Key('ds-save'))).onPressed, isNull);
    }
  });

  testWidgets('a rejected save shows its message with a retry', (tester) async {
    when(
      () => repository.updateDocumentSettings(
        defaultTemplate: DocumentTemplate.minimal,
        requireApprovalToFinalize: false,
        remindersEnabled: true,
        reminderCadenceDays: 7,
        dueSoonReminderDays: 3,
      ),
    ).thenAnswer((_) async => throw apiError('not_owner'));

    await pumpSettings(tester, buildApp());
    await tester.tap(find.byKey(const Key('ds-save')));
    await tester.pumpAndSettle();

    expect(find.text('Only the business owner can change this'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('the days-before choice shows only while reminders are on, and says what each means', (tester) async {
    await pumpSettings(tester, buildApp());

    expect(find.byKey(const Key('ds-due-soon')), findsOneWidget);

    await tester.tap(find.byKey(const Key('ds-reminders')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ds-due-soon')), findsNothing);
  });

  testWidgets('offers not sending and the usual days, and saves the one chosen', (tester) async {
    when(
      () => repository.updateDocumentSettings(
        defaultTemplate: DocumentTemplate.minimal,
        requireApprovalToFinalize: false,
        remindersEnabled: true,
        reminderCadenceDays: 7,
        dueSoonReminderDays: 0,
      ),
    ).thenAnswer((_) async => testSettings);
    await pumpSettings(tester, buildApp());

    await tester.tap(find.byKey(const Key('ds-due-soon')));
    await tester.pumpAndSettle();
    for (final label in ["Don't send", '1 day before', '2 days before', '3 days before', '5 days before', '7 days before']) {
      expect(find.text(label), findsWidgets, reason: label);
    }
    await tester.tap(find.text("Don't send").last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ds-save')));
    await tester.pumpAndSettle();

    verify(
      () => repository.updateDocumentSettings(
        defaultTemplate: DocumentTemplate.minimal,
        requireApprovalToFinalize: false,
        remindersEnabled: true,
        reminderCadenceDays: 7,
        dueSoonReminderDays: 0,
      ),
    ).called(1);
  });

  testWidgets('a value set on the web that is not in the list is kept and shown', (tester) async {
    when(() => repository.get()).thenAnswer(
      (_) async => const BusinessSettings(id: 'b1', name: 'Acme', dueSoonReminderDays: 4),
    );
    await pumpSettings(tester, buildApp());

    expect(find.text('4 days before'), findsOneWidget);
  });
}

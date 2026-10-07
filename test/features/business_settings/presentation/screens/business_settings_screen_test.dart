import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/business_settings/domain/business_settings_repository.dart';
import 'package:billa_mobile/features/business_settings/domain/subscription_status.dart';
import 'package:billa_mobile/features/business_settings/presentation/providers/business_settings_repository_provider.dart';
import 'package:billa_mobile/features/business_settings/presentation/screens/business_settings_screen.dart';
import '../../support.dart';

class _MockBusinessSettingsRepository extends Mock implements BusinessSettingsRepository {}

void main() {
  late _MockBusinessSettingsRepository repository;

  setUp(() {
    repository = _MockBusinessSettingsRepository();
    when(() => repository.subscription()).thenAnswer(
      (_) async => const SubscriptionStatus(trialEndsAt: '2026-03-01T00:00:00.000Z', activeUntil: '2026-03-01T00:00:00.000Z'),
    );
  });

  Widget buildApp() => businessSettingsApp(
        screen: const BusinessSettingsScreen(),
        path: '/settings/business',
        overrides: [businessSettingsRepositoryProvider.overrideWithValue(repository)],
      );

  testWidgets('each section row opens its screen', (tester) async {
    for (final (key, route) in [
      ('bs-details', '/settings/business/details'),
      ('bs-payments', '/settings/business/payments'),
      ('bs-documents', '/settings/business/documents'),
      ('bs-numbering', '/settings/business/numbering'),
      ('bs-logo', '/settings/business/logo'),
    ]) {
      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key(key)));
      await tester.pumpAndSettle();

      expect(find.text('stub $route'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('shows the free trial end date while on a trial', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Free trial until 2026-03-01'), findsOneWidget);
  });

  testWidgets('shows the plan and paid-until date when subscribed', (tester) async {
    when(() => repository.subscription()).thenAnswer(
      (_) async => const SubscriptionStatus(
        plan: 'MONTHLY',
        currentPeriodEnd: '2026-04-01T00:00:00.000Z',
        activeUntil: '2026-04-01T00:00:00.000Z',
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Monthly plan, active until 2026-04-01'), findsOneWidget);
  });

  testWidgets('a failed subscription load keeps the rows and offers a retry that reloads', (tester) async {
    var failing = true;
    when(() => repository.subscription()).thenAnswer((_) async {
      if (failing) throw apiError('server_error');
      return const SubscriptionStatus(trialEndsAt: '2026-03-01T00:00:00.000Z');
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load your subscription"), findsOneWidget);
    expect(find.byKey(const Key('bs-details')), findsOneWidget);

    failing = false;
    await tester.tap(find.byKey(const Key('bs-subscription-retry')));
    await tester.pumpAndSettle();

    expect(find.text('Free trial until 2026-03-01'), findsOneWidget);
  });
}

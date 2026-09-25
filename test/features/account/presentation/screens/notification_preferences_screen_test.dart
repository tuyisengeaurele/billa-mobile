import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/features/account/domain/notification_type.dart';
import 'package:billa_mobile/features/account/domain/profile_repository.dart';
import 'package:billa_mobile/features/account/presentation/providers/profile_repository_provider.dart';
import 'package:billa_mobile/features/account/presentation/screens/notification_preferences_screen.dart';
import 'package:billa_mobile/features/auth/presentation/providers/auth_controller.dart';
import '../../support.dart';

class _MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late _MockProfileRepository repository;

  setUp(() {
    repository = _MockProfileRepository();
    when(() => repository.notificationPreferences()).thenAnswer((_) async => {
          for (final type in NotificationType.values) type: true,
        });
  });

  Widget buildApp() => accountApp(
        screen: const NotificationPreferencesScreen(),
        path: '/settings/notifications',
        overrides: [
          authControllerProvider.overrideWith(FakeAuthController.new),
          profileRepositoryProvider.overrideWithValue(repository),
        ],
      );

  bool switchValue(WidgetTester tester, NotificationType type) =>
      tester.widget<SwitchListTile>(find.byKey(Key('notification-${type.wireName}'))).value;

  testWidgets('shows a labelled switch for every notification type', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(SwitchListTile), findsNWidgets(NotificationType.values.length));
    expect(find.text('Payment received'), findsOneWidget);
  });

  testWidgets('toggling patches one key and shows the merged result', (tester) async {
    when(() => repository.setNotificationPreference(NotificationType.paymentReceived, false)).thenAnswer(
      (_) async => {
        for (final type in NotificationType.values) type: type != NotificationType.paymentReceived,
      },
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification-PAYMENT_RECEIVED')));
    await tester.pumpAndSettle();

    verify(() => repository.setNotificationPreference(NotificationType.paymentReceived, false)).called(1);
    expect(switchValue(tester, NotificationType.paymentReceived), isFalse);
    expect(switchValue(tester, NotificationType.invoiceOverdue), isTrue);
  });

  testWidgets('a failed toggle shows its message with a retry that succeeds', (tester) async {
    var calls = 0;
    when(() => repository.setNotificationPreference(NotificationType.paymentReceived, false)).thenAnswer((_) async {
      calls++;
      if (calls == 1) throw apiError('server_error');
      return {for (final type in NotificationType.values) type: type != NotificationType.paymentReceived};
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification-PAYMENT_RECEIVED')));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong. Try again'), findsOneWidget);
    expect(switchValue(tester, NotificationType.paymentReceived), isTrue);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(switchValue(tester, NotificationType.paymentReceived), isFalse);
  });

  testWidgets('a failed load offers a retry', (tester) async {
    when(() => repository.notificationPreferences()).thenAnswer((_) async => throw apiError('not_found'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Retry'), findsOneWidget);
  });
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:billa_mobile/app/theme/app_theme.dart';
import 'package:billa_mobile/features/account/domain/notification_type.dart';
import 'package:billa_mobile/features/notifications/domain/app_notification.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_page.dart';
import 'package:billa_mobile/features/notifications/domain/notifications_repository.dart';
import 'package:billa_mobile/features/notifications/presentation/providers/notifications_repository_provider.dart';
import 'package:billa_mobile/features/notifications/presentation/screens/notifications_screen.dart';

class _MockNotificationsRepository extends Mock implements NotificationsRepository {}

const _unreadPayment = AppNotification(
  id: 'n1',
  type: NotificationType.paymentReceived,
  title: 'Payment received',
  body: 'RWF 5,000 from Ada',
  link: '/documents/d1',
  createdAt: '2026-01-01T10:00:00.000Z',
);
const _readJoined = AppNotification(
  id: 'n2',
  type: NotificationType.memberJoined,
  title: 'Sam joined your team',
  link: '/settings',
  readAt: '2026-01-02T00:00:00.000Z',
  createdAt: '2026-01-01T09:00:00.000Z',
);
const _adminOnly = AppNotification(
  id: 'n3',
  title: 'New contact message',
  link: '/admin/messages',
  createdAt: '2026-01-01T08:00:00.000Z',
);

DioException _error(String code) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(requestOptions: RequestOptions(path: '/x'), data: {'error': code}),
    );

void main() {
  late _MockNotificationsRepository repository;

  setUp(() {
    repository = _MockNotificationsRepository();
    when(() => repository.list()).thenAnswer(
      (_) async => const NotificationsPage(results: [_unreadPayment, _readJoined, _adminOnly], unreadCount: 2),
    );
  });

  Widget buildApp() {
    final router = GoRouter(initialLocation: '/notifications', routes: [
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/documents/:id', builder: (context, state) => Scaffold(body: Text('document ${state.pathParameters['id']}'))),
      GoRoute(path: '/team', builder: (context, state) => const Scaffold(body: Text('team screen'))),
    ]);
    return ProviderScope(
      overrides: [notificationsRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    );
  }

  testWidgets('lists notifications with titles, bodies, and only mapped rows showing a chevron', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Payment received'), findsOneWidget);
    expect(find.text('Sam joined your team'), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('notification-n1')), matching: find.byIcon(Icons.chevron_right)), findsOneWidget);
    expect(find.descendant(of: find.byKey(const Key('notification-n3')), matching: find.byIcon(Icons.chevron_right)), findsNothing);
  });

  testWidgets('tapping an unread row marks it read and opens its document', (tester) async {
    when(() => repository.markRead('n1')).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification-n1')));
    await tester.pumpAndSettle();

    verify(() => repository.markRead('n1')).called(1);
    expect(find.text('document d1'), findsOneWidget);
  });

  testWidgets('a read row opens its destination without another mark-read call', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification-n2')));
    await tester.pumpAndSettle();

    verifyNever(() => repository.markRead(any()));
    expect(find.text('team screen'), findsOneWidget);
  });

  testWidgets('an unread row with no destination is marked read and stays put', (tester) async {
    when(() => repository.markRead('n3')).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification-n3')));
    await tester.pumpAndSettle();

    verify(() => repository.markRead('n3')).called(1);
    expect(find.text('New contact message'), findsOneWidget);
  });

  testWidgets('Mark all read appears with unread items and calls the endpoint', (tester) async {
    when(() => repository.markAllRead()).thenAnswer((_) async {});

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notifications-mark-all')));
    await tester.pumpAndSettle();

    verify(() => repository.markAllRead()).called(1);
  });

  testWidgets('Mark all read is hidden when everything is read', (tester) async {
    when(() => repository.list()).thenAnswer(
      (_) async => const NotificationsPage(results: [_readJoined], unreadCount: 0),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('notifications-mark-all')), findsNothing);
  });

  testWidgets('an empty inbox explains what will appear here', (tester) async {
    when(() => repository.list()).thenAnswer((_) async => const NotificationsPage(results: [], unreadCount: 0));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.textContaining("You're all caught up"), findsOneWidget);
  });

  testWidgets('a failed mark-read shows its message with a retry', (tester) async {
    when(() => repository.markRead('n1')).thenAnswer((_) async => throw _error('not_found'));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('notification-n1')));
    await tester.pumpAndSettle();

    expect(find.text("We couldn't find that — it may have been removed"), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('a failed load offers a retry that reloads', (tester) async {
    var failing = true;
    when(() => repository.list()).thenAnswer((_) async {
      if (failing) throw _error('server_error');
      return const NotificationsPage(results: [_readJoined], unreadCount: 0);
    });

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load your notifications"), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Sam joined your team'), findsOneWidget);
  });
}
